// Do khoang cach tu 29 nut ngu nghia (cua vao, cong, thang may...) den mang luoi hanh lang.
// Neu chung nam sat mang luoi thi co the gan (snap) vao do; neu qua xa thi mang luoi thieu duong.
import fs from 'node:fs';
import path from 'node:path';

const DIR = process.argv[2];
const read = (f) => JSON.parse(fs.readFileSync(path.join(DIR, f), 'utf8'));

const lines = read('routing_network_clean.geojson').features
  .filter((f) => f.geometry?.type === 'LineString')
  .map((f) => f.geometry.coordinates.map(([lng, lat]) => ({ lng, lat })));

const nodes = read('02_node_modified_clean.geojson').features
  .filter((f) => f.geometry?.type === 'Point')
  .map((f, i) => ({
    idx: i + 1,
    lng: f.geometry.coordinates[0],
    lat: f.geometry.coordinates[1],
    layer: f.properties?.Layer ?? '',
    text: (f.properties?.Text ?? '').trim(),
  }));

const rad = (d) => (d * Math.PI) / 180;
const mPerLat = 111320;
const mPerLng = (lat) => 111320 * Math.cos(rad(lat));

// Khoang cach (met) tu diem den doan thang, kem tham chieu hinh chieu.
function distToSegment(p, a, b) {
  const kx = mPerLng(p.lat);
  const toXY = (q) => ({ x: q.lng * kx, y: q.lat * mPerLat });
  const P = toXY(p), A = toXY(a), B = toXY(b);
  const vx = B.x - A.x, vy = B.y - A.y;
  const wx = P.x - A.x, wy = P.y - A.y;
  const len2 = vx * vx + vy * vy;
  let t = len2 === 0 ? 0 : (wx * vx + wy * vy) / len2;
  t = Math.max(0, Math.min(1, t));
  const cx = A.x + t * vx, cy = A.y + t * vy;
  return { dist: Math.hypot(P.x - cx, P.y - cy), t };
}

const results = [];
for (const n of nodes) {
  let best = { dist: Infinity };
  lines.forEach((coords, li) => {
    for (let i = 0; i < coords.length - 1; i++) {
      const d = distToSegment(n, coords[i], coords[i + 1]);
      if (d.dist < best.dist) best = { ...d, lineIdx: li, segIdx: i };
    }
  });
  results.push({ ...n, dist: best.dist, lineIdx: best.lineIdx, segIdx: best.segIdx });
}

results.sort((a, b) => a.dist - b.dist);
console.log('=== Khoang cach tu nut ngu nghia den mang luoi hanh lang (met) ===');
for (const r of results) {
  console.log(
    `node ${String(r.idx).padStart(2)}  ${r.dist.toFixed(2).padStart(8)} m   line ${String(r.lineIdx).padStart(2)} seg ${String(r.segIdx).padStart(2)}   [${r.layer}] "${r.text}"`
  );
}

const within = (t) => results.filter((r) => r.dist <= t).length;
console.log('\n=== Tong hop ===');
console.log('tong nut            :', results.length);
for (const t of [1, 2, 3, 5, 10, 20, 50]) console.log(`  <= ${String(t).padStart(2)} m : ${within(t)}`);
console.log('xa nhat             :', results[results.length - 1].dist.toFixed(2), 'm');