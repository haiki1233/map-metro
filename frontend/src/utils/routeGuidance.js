/**
 * Logic dẫn đường dùng chung cho RoutePanel / MapView / App.
 *
 * Không chứa React — chỉ hàm thuần, để dễ suy luận và tái dùng.
 *
 * Backend (RoutingService.java) đã trả sẵn `maneuver` + `geometry` cho từng bước. Module này
 * vẫn có đường FALLBACK tự tính khi hai field đó null — dùng cho payload cũ hoặc khi
 * VITE_USE_MOCK=true. Ngưỡng phân loại góc rẽ ở đây GIỐNG HỆT RoutingService.java;
 * sửa bên nào thì sửa cả hai.
 */

// ===== Hằng số dùng chung với RoutingService.java =====
const STRAIGHT_MAX = 20;
const SLIGHT_MAX = 45;
const UTURN_MIN = 135;

/** Các maneuver không phải đi bộ trên hành lang — không vẽ được đường trên bản đồ 2D từng tầng. */
export const TRANSFER_MANEUVERS = new Set(['ELEVATOR', 'ESCALATOR', 'STAIR', 'TRANSFER']);

export const MANEUVER_ICON = {
  DEPART: '↑',
  STRAIGHT: '↑',
  SLIGHT_LEFT: '↖',
  SLIGHT_RIGHT: '↗',
  LEFT: '↰',
  RIGHT: '↱',
  U_TURN: '↺',
  ELEVATOR: '🛗',
  ESCALATOR: '⤢',
  STAIR: '🪜',
  TRANSFER: '⇅',
};

const MANEUVER_LABEL = {
  DEPART: 'Bắt đầu di chuyển',
  STRAIGHT: 'Đi thẳng',
  SLIGHT_LEFT: 'Chếch sang trái',
  SLIGHT_RIGHT: 'Chếch sang phải',
  LEFT: 'Rẽ trái',
  RIGHT: 'Rẽ phải',
  U_TURN: 'Quay đầu',
  ELEVATOR: 'Đi thang máy',
  ESCALATOR: 'Đi thang cuốn',
  STAIR: 'Đi cầu thang bộ',
  TRANSFER: 'Chuyển tầng',
};

export const maneuverIcon = (m) => MANEUVER_ICON[m] || '↑';
export const maneuverLabel = (m) => MANEUVER_LABEL[m] || 'Đi thẳng';
export const isTransferStep = (step) => TRANSFER_MANEUVERS.has(step?.maneuver);

// ===== Định dạng hiển thị =====

export function formatDistance(meters) {
  if (meters == null || Number.isNaN(meters)) return '—';
  if (meters >= 1000) return `${(meters / 1000).toFixed(1)} km`;
  return `${Math.round(meters)} m`;
}

export function formatDuration(seconds) {
  if (seconds == null || Number.isNaN(seconds)) return '—';
  if (seconds < 60) return `${Math.round(seconds)} giây`;
  return `${Math.max(1, Math.round(seconds / 60))} phút`;
}

/** Nhãn độ dài của 1 bước: bước chuyển tầng hiện thời gian, bước đi bộ hiện mét. */
export function stepDistanceLabel(step) {
  if (isTransferStep(step)) return `~${formatDuration(step.duration)}`;
  return formatDistance(step.distance);
}

// ===== Toán hình học =====

const toRad = (d) => (d * Math.PI) / 180;
const toDeg = (r) => (r * 180) / Math.PI;

/** Bearing từ a đến b, độ theo chiều kim đồng hồ từ Bắc (0..360). a/b là [lng, lat]. */
export function bearingBetween(a, b) {
  const lat1 = toRad(a[1]);
  const lat2 = toRad(b[1]);
  const dLon = toRad(b[0] - a[0]);
  const y = Math.sin(dLon) * Math.cos(lat2);
  const x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
  return (toDeg(Math.atan2(y, x)) + 360) % 360;
}

/** Khoảng cách mét giữa 2 điểm [lng, lat] (haversine). */
function distanceBetween(a, b) {
  const R = 6371008.8;
  const dLat = toRad(b[1] - a[1]);
  const dLon = toRad(b[0] - a[0]);
  const s =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(a[1])) * Math.cos(toRad(b[1])) * Math.sin(dLon / 2) ** 2;
  return 2 * R * Math.asin(Math.min(1, Math.sqrt(s)));
}

/** Góc rẽ giữa đoạn vào và đoạn ra. Cùng ngưỡng với RoutingService.classifyManeuver. */
export function classifyManeuver(inBearing, outBearing) {
  // Bearing tăng theo chiều kim đồng hồ => delta dương là rẽ PHẢI.
  const delta = ((outBearing - inBearing + 540) % 360) - 180;
  const magnitude = Math.abs(delta);
  if (magnitude < STRAIGHT_MAX) return 'STRAIGHT';
  if (magnitude < SLIGHT_MAX) return delta > 0 ? 'SLIGHT_RIGHT' : 'SLIGHT_LEFT';
  if (magnitude <= UTURN_MIN) return delta > 0 ? 'RIGHT' : 'LEFT';
  return 'U_TURN';
}

const samePoint = (a, b) => Math.abs(a[0] - b[0]) < 1e-12 && Math.abs(a[1] - b[1]) < 1e-12;

/** Lấy mảng toạ độ từ route.geometry (chấp nhận Feature, geometry trần, hoặc FeatureCollection). */
function extractLine(geometry) {
  if (!geometry) return [];
  if (geometry.type === 'FeatureCollection') {
    return extractLine(geometry.features?.[0]);
  }
  if (geometry.type === 'Feature') return extractLine(geometry.geometry);
  if (geometry.type === 'LineString') return dedupeLine(geometry.coordinates || []);
  return [];
}

function dedupeLine(coords) {
  const out = [];
  for (const c of coords) {
    if (!out.length || !samePoint(out[out.length - 1], c)) out.push(c);
  }
  return out;
}

function cumulativeLengths(line) {
  const cum = [0];
  for (let i = 1; i < line.length; i++) {
    cum.push(cum[i - 1] + distanceBetween(line[i - 1], line[i]));
  }
  return cum;
}

/** Điểm nằm cách đầu line đúng `target` mét (nội suy trong đoạn chứa nó). */
function interpolateAt(line, cum, target) {
  if (line.length === 0) return null;
  if (target <= 0) return line[0];
  const total = cum[cum.length - 1];
  if (target >= total) return line[line.length - 1];
  for (let i = 1; i < cum.length; i++) {
    if (cum[i] >= target) {
      const segLen = cum[i] - cum[i - 1];
      const t = segLen === 0 ? 0 : (target - cum[i - 1]) / segLen;
      return [
        line[i - 1][0] + (line[i][0] - line[i - 1][0]) * t,
        line[i - 1][1] + (line[i][1] - line[i - 1][1]) * t,
      ];
    }
  }
  return line[line.length - 1];
}

/** Cắt 1 đoạn con của line từ `fromM` đến `toM` mét, giữ nguyên các đỉnh nằm trong khoảng. */
function subLine(line, cum, fromM, toM) {
  if (toM <= fromM || line.length < 2) return [];
  const pts = line.filter((_, i) => cum[i] > fromM && cum[i] < toM);
  const start = interpolateAt(line, cum, fromM);
  const end = interpolateAt(line, cum, toM);
  const out = [];
  if (start) out.push(start);
  for (const p of pts) if (!samePoint(out[out.length - 1], p)) out.push(p);
  if (end && !samePoint(out[out.length - 1], end)) out.push(end);
  return out;
}

/** Bearing rời khỏi điểm đầu — bỏ qua các đỉnh trùng nhau. */
function departureBearing(coords) {
  if (coords.length < 2) return null;
  for (let i = 1; i < coords.length; i++) {
    if (!samePoint(coords[0], coords[i])) return bearingBetween(coords[0], coords[i]);
  }
  return null;
}

/** Bearing đến điểm cuối — bỏ qua các đỉnh trùng nhau. */
function arrivalBearing(coords) {
  if (coords.length < 2) return null;
  const last = coords[coords.length - 1];
  for (let i = coords.length - 2; i >= 0; i--) {
    if (!samePoint(last, coords[i])) return bearingBetween(coords[i], last);
  }
  return null;
}

/**
 * Chuẩn hoá route.steps thành mảng bước đầy đủ để render:
 * mỗi bước có `coords` (mảng [lng,lat]) và `maneuver` (luôn khác null).
 *
 * - `coords`: ưu tiên `step.geometry` từ backend; nếu thiếu thì cắt từ `route.geometry`
 *   theo tỉ lệ `step.distance` tích luỹ (chỉ chia cho các bước đi bộ được — bước chuyển
 *   tầng nhận mảng rỗng vì không có đường để vẽ).
 * - `maneuver`: ưu tiên giá trị backend trả; nếu thiếu thì tự suy ra từ góc giữa hai đoạn.
 */
export function enrichSteps(route) {
  const rawSteps = route?.steps;
  if (!Array.isArray(rawSteps) || rawSteps.length === 0) return [];

  const steps = rawSteps.map((s) => ({
    ...s,
    coords: extractLine(s.geometry),
    maneuver: s.maneuver || null,
  }));

  // --- Fallback hình học: cắt polyline tổng theo tỉ lệ ---
  if (steps.some((s) => s.coords.length < 2)) {
    const line = extractLine(route.geometry);
    const cum = cumulativeLengths(line);
    const total = cum[cum.length - 1] || 0;
    // Bước chuyển tầng để dành tỉ lệ riêng, không tính vào phần chia polyline.
    const drawable = steps.filter((s) => !TRANSFER_MANEUVERS.has(s.maneuver) && (s.distance || 0) > 0);
    const sumDist = drawable.reduce((acc, s) => acc + s.distance, 0);

    if (total > 0 && sumDist > 0) {
      let acc = 0;
      for (const s of steps) {
        if (s.coords.length >= 2) continue;
        if (TRANSFER_MANEUVERS.has(s.maneuver) || !(s.distance > 0)) {
          s.coords = [];
          continue;
        }
        const from = (acc / sumDist) * total;
        acc += s.distance;
        const to = (acc / sumDist) * total;
        s.coords = subLine(line, cum, from, to);
      }
    }
  }

  // --- Fallback hướng rẽ: suy ra từ góc giữa đoạn vào và đoạn ra ---
  if (steps.some((s) => !s.maneuver)) {
    let previousArrival = null;
    steps.forEach((s, i) => {
      if (s.maneuver) {
        previousArrival = arrivalBearing(s.coords);
        return;
      }
      const departure = departureBearing(s.coords);
      if (i === 0 || previousArrival == null || departure == null) {
        s.maneuver = i === 0 ? 'DEPART' : 'STRAIGHT';
      } else {
        s.maneuver = classifyManeuver(previousArrival, departure);
      }
      previousArrival = arrivalBearing(s.coords);
    });
  }

  return steps;
}

/** Tổng quãng đường + thời gian còn lại tính từ bước `index` (tính cả bước đó). */
export function remainingAfter(steps, index) {
  const from = Math.max(0, index);
  return steps.slice(from).reduce(
    (acc, s) => ({
      distance: acc.distance + (isTransferStep(s) ? 0 : s.distance || 0),
      duration: acc.duration + (s.duration || 0),
    }),
    { distance: 0, duration: 0 }
  );
}

/**
 * GeoJSON FeatureCollection chỉ gồm các bước thuộc 1 tầng — để MapView vẽ đường của tầng đang xem.
 * Bước chuyển tầng không có `coords` nên bị bỏ qua: đường tự ngắt tại chỗ chuyển tầng, đúng với
 * bản đồ 2D từng tầng.
 */
export function routeLineForFloor(steps, floorId, activeStepIndex = -1) {
  const features = steps
    .map((s, index) => ({
      step: s,
      progress: activeStepIndex < 0
        ? 'upcoming'
        : index < activeStepIndex
          ? 'completed'
          : index === activeStepIndex
            ? 'active'
            : 'upcoming',
    }))
    .filter(({ step }) => step.floorId === floorId && step.coords.length >= 2)
    .map(({ step, progress }) => ({
      type: 'Feature',
      geometry: { type: 'LineString', coordinates: step.coords },
      properties: {
        order: step.order,
        maneuver: step.maneuver,
        floorId: step.floorId,
        progress,
      },
    }));
  return { type: 'FeatureCollection', features };
}

/** FeatureCollection cho riêng đoạn đường của bước đang đi — dùng để highlight. */
export function stepGeometryFeature(step) {
  if (!step || step.coords.length < 2) return null;
  return {
    type: 'Feature',
    geometry: { type: 'LineString', coordinates: step.coords },
    properties: {},
  };
}

/** Bounding box [minLng, minLat, maxLng, maxLat] của toàn tuyến, hoặc null nếu không có gì. */
export function routeBounds(steps) {
  const all = steps.flatMap((s) => s.coords);
  if (all.length === 0) return null;
  let minLng = Infinity, minLat = Infinity, maxLng = -Infinity, maxLat = -Infinity;
  for (const [lng, lat] of all) {
    if (lng < minLng) minLng = lng;
    if (lat < minLat) minLat = lat;
    if (lng > maxLng) maxLng = lng;
    if (lat > maxLat) maxLat = lat;
  }
  return [minLng, minLat, maxLng, maxLat];
}