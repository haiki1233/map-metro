import React, { useEffect, useMemo, useRef, useState } from 'react';
import Map, { Source, Layer, Marker, NavigationControl } from 'react-map-gl/maplibre';

import 'maplibre-gl/dist/maplibre-gl.css';
import { enrichSteps, routeLineForFloor, stepGeometryFeature, routeBounds } from '../utils/routeGuidance.js';

// ==========================================
// CẤU HÌNH LAYER STYLES
// ==========================================

const room3DLayer = {
  id: 'rooms-3d',
  type: 'fill-extrusion',
  paint: {
    'fill-extrusion-color': [
      'match',
      ['get', 'category'],
      'wc', '#BDE3FB',        // Xanh lơ
      'toilet', '#BDE3FB',
      'ticket_counter', '#FDE68A',
      'corridor', '#F8FAFC',  // Xám nhạt
      'stair', '#FCA5A5',     // Đỏ nhạt / Cam
      'elevator', '#FDE047',  // Vàng
      '#FFF4E0'               // Trắng kem (Mặc định)
    ],
    'fill-extrusion-height': ['coalesce', ['get', 'height'], 3.5],
    'fill-extrusion-base': ['coalesce', ['get', 'baseHeight'], 0],
    'fill-extrusion-opacity': 0.95
  }
};

const room2DLayer = {
  id: 'rooms-2d',
  type: 'fill',
  paint: {
    'fill-color': [
      'match',
      ['get', 'category'],
      'wc', '#BDE3FB',
      'toilet', '#BDE3FB',
      'ticket_counter', '#FDE68A',
      'corridor', '#F8FAFC',
      'stair', '#FCA5A5',
      'elevator', '#FDE047',
      '#FFF4E0'
    ],
    'fill-opacity': 0.95,
    'fill-outline-color': '#94A3B8'
  }
};

const roomLabelLayer = {
  id: 'rooms-label',
  type: 'symbol',
  layout: {
    'text-field': ['get', 'name'],
    'text-size': 12,
    'text-anchor': 'center',
    'text-justify': 'center'
  },
  paint: {
    'text-color': '#1E293B',
    'text-halo-color': '#FFFFFF',
    'text-halo-width': 2
  }
};

const cadLineLayer = {
  id: 'cad-lines',
  type: 'line',
  layout: {
    'line-join': 'round',
    'line-cap': 'round'
  },
  paint: {
    'line-width': [
      'interpolate', ['linear'], ['zoom'],
      17, 1.5,
      19, 4,
      21, 8,
      22, 12
    ],
    'line-color': [
      'match',
      ['get', 'layer_name'],
      '1.Fence Wall', '#475569',
      '1ST_ALIGSIDE', '#CBD5E1',
      '3.Curb', '#94A3B8',
      'Trench', '#7DD3FC',
      '#94A3B8'
    ],
    'line-dasharray': ['literal', [1, 0]]
  }
};

const floorPlanWallsLayer = {
  id: 'thao-dien-walls',
  type: 'fill',
  source: 'cad-source',
  filter: ['==', ['get', 'layer_name'], 'walls'],
  paint: {
    'fill-color': [
      'match',
      ['get', 'feature_type'],
      'outer_wall', '#475569',
      'barrier', '#94A3B8',
      'fare_barrier', '#F97316',
      'column', '#334155',
      'bollard', '#475569',
      '#64748B',
    ],
    'fill-opacity': 0.9,
    'fill-outline-color': '#334155',
  },
};

const floorPlanWalls3DLayer = {
  id: 'thao-dien-walls-3d',
  type: 'fill-extrusion',
  source: 'cad-source',
  filter: ['==', ['get', 'layer_name'], 'walls'],
  paint: {
    'fill-extrusion-color': ['coalesce', ['get', 'color', ['get', 'style']], '#64748B'],
    'fill-extrusion-base': ['coalesce', ['get', 'base_height', ['get', 'style']], 0],
    'fill-extrusion-height': ['coalesce', ['get', 'height', ['get', 'style']], 1],
    'fill-extrusion-opacity': 0.95,
  },
};

const floorPlanVerticalLayer = {
  id: 'thao-dien-vertical',
  type: 'fill',
  source: 'cad-source',
  filter: ['==', ['get', 'layer_name'], 'vertical'],
  paint: {
    'fill-color': [
      'match',
      ['get', 'feature_type'],
      'elevator', '#FDE047',
      'escalator_stair', '#FDBA74',
      'stairs', '#FCA5A5',
      '#E2E8F0',
    ],
    'fill-opacity': 0.95,
    'fill-outline-color': '#475569',
  },
};

const floorPlanVertical3DLayer = {
  id: 'thao-dien-vertical-3d',
  type: 'fill-extrusion',
  source: 'cad-source',
  filter: ['==', ['get', 'layer_name'], 'vertical'],
  paint: {
    'fill-extrusion-color': ['coalesce', ['get', 'color', ['get', 'style']], '#64748B'],
    'fill-extrusion-base': ['coalesce', ['get', 'base_height', ['get', 'style']], 0],
    'fill-extrusion-height': ['coalesce', ['get', 'height', ['get', 'style']], 1],
    'fill-extrusion-opacity': 0.95,
  },
};

const floorPlanLabelLayer = {
  id: 'thao-dien-vertical-labels',
  type: 'symbol',
  source: 'cad-source',
  filter: ['==', ['get', 'layer_name'], 'vertical'],
  layout: {
    'text-field': ['get', 'name'],
    'text-size': 11,
    'text-anchor': 'center',
    'text-allow-overlap': true,
  },
  paint: {
    'text-color': '#1E293B',
    'text-halo-color': '#FFFFFF',
    'text-halo-width': 2,
  },
};

const floorPlanGateLayer = {
  id: 'thao-dien-gates',
  type: 'circle',
  source: 'cad-source',
  filter: ['==', ['get', 'layer_name'], 'gates'],
  paint: {
    'circle-radius': 7,
    'circle-color': ['coalesce', ['get', 'color', ['get', 'style']], '#16A34A'],
    'circle-stroke-color': '#FFFFFF',
    'circle-stroke-width': 2,
  },
};

const floorPlanGateLabelLayer = {
  id: 'thao-dien-gate-labels',
  type: 'symbol',
  source: 'cad-source',
  filter: ['==', ['get', 'layer_name'], 'gates'],
  layout: {
    'text-field': ['get', 'name'],
    'text-size': 11,
    'text-anchor': 'top',
    'text-offset': [0, 0.8],
    'text-allow-overlap': true,
  },
  paint: {
    'text-color': '#166534',
    'text-halo-color': '#FFFFFF',
    'text-halo-width': 2,
  },
};

const floorPlanSiteLayer = {
  id: 'thao-dien-site',
  type: 'fill',
  source: 'cad-source',
  filter: ['==', ['get', 'layer_name'], 'site'],
  paint: {
    'fill-color': ['coalesce', ['get', 'color', ['get', 'style']], '#CBD5E1'],
    'fill-opacity': 0.45,
    'fill-outline-color': '#94A3B8',
  },
};

const edgeLayer = {
  id: 'routing-edges',
  type: 'line',
  layout: { 'line-join': 'round', 'line-cap': 'round' },
  paint: {
    'line-color': '#64748B',
    'line-width': ['interpolate', ['linear'], ['zoom'], 17, 1.5, 21, 4],
    'line-opacity': 0.85,
  },
};

const routeLayer = {
  id: 'route-line',
  type: 'line',
  layout: {
    'line-join': 'round',
    'line-cap': 'round'
  },
  paint: {
    'line-color': [
      'match',
      ['get', 'progress'],
      'completed', '#94A3B8',
      'active', '#F97316',
      '#2563EB',
    ],
    'line-width': ['match', ['get', 'progress'], 'active', 8, 6],
    'line-opacity': ['match', ['get', 'progress'], 'completed', 0.24, 'active', 1, 0.78]
  }
};

/**
 * Chevron chỉ hướng đi trên tuyến. Dùng symbol layer với text glyph '›' đặt dọc theo line —
 * KHÔNG cần cài thêm package hay asset icon nào.
 */
const routeChevronLayer = {
  id: 'route-chevrons',
  type: 'symbol',
  layout: {
    'symbol-placement': 'line',
    'symbol-spacing': 55,
    'text-field': '›',
    'text-size': 20,
    'text-rotation-alignment': 'map',
    'text-keep-upright': false,
    'text-allow-overlap': true,
    'text-ignore-placement': true
  },
  paint: {
    'text-color': '#FFFFFF',
    'text-halo-color': [
      'match',
      ['get', 'progress'],
      'completed', '#94A3B8',
      'active', '#F97316',
      '#2563EB',
    ],
    'text-halo-width': 1,
    'text-opacity': ['match', ['get', 'progress'], 'completed', 0.24, 'active', 1, 0.78]
  }
};

/** Quầng trắng dưới đoạn đang đi, để nổi lên trên toàn tuyến. */
const activeStepCasingLayer = {
  id: 'active-step-casing',
  type: 'line',
  layout: { 'line-join': 'round', 'line-cap': 'round' },
  paint: {
    'line-color': '#FFFFFF',
    'line-width': 10,
    'line-opacity': 0.95
  }
};

const activeStepLayer = {
  id: 'active-step-line',
  type: 'line',
  layout: { 'line-join': 'round', 'line-cap': 'round' },
  paint: {
    'line-color': '#F97316',
    'line-width': 7,
    'line-opacity': 1
  }
};

export default function MapView({
  floorMap,
  mapCenter,
  cadBackground,
  route,
  startPoint,
  destinationPoint,
  startNodeId,
  endNodeId,
  activeStepIndex = -1,
  fitNonce,
  isNavigating,
  onMapClick,
  onNodeClick,
}) {
  const mapRef = useRef(null);

  // STATE LƯU TRỮ CHẾ ĐỘ VIEW (Mặc định là 3D)
  const [is3D, setIs3D] = useState(true);

  const currentFloorId = floorMap?.__floorId ?? null;
  const isThaoDienFloor = [0, 1].includes(Number(currentFloorId));

  // Bước đã chuẩn hoá — dùng chung cho cả đường theo tầng lẫn tính bbox.
  const steps = useMemo(() => enrichSteps(route), [route]);

  // Đường của RIÊNG tầng đang xem: bước chuyển tầng không có geometry nên đường tự ngắt
  // tại chỗ chuyển tầng — đúng với bản đồ 2D từng tầng.
  const floorRoute = useMemo(
    () => (steps.length ? routeLineForFloor(steps, currentFloorId, activeStepIndex) : null),
    [steps, currentFloorId, activeStepIndex]
  );

  // Hình học của bước đang đi — tự suy ra từ `steps` nên App chỉ cần truyền chỉ số bước.
  const activeStepGeometry = useMemo(
    () => (activeStepIndex >= 0 ? stepGeometryFeature(steps[activeStepIndex]) : null),
    [steps, activeStepIndex]
  );

  const initialViewState = useMemo(() => {
    return {
      longitude: mapCenter ? mapCenter[1] : 106.7335,
      latitude: mapCenter ? mapCenter[0] : 10.8006,
      zoom: 19,
      pitch: 60,
      bearing: -20
    };
  }, [mapCenter]);

  // CHUYỂN TẦNG: Giữ nguyên chế độ 2D/3D hiện tại của người dùng khi camera bay.
  // Bỏ qua khi đang dẫn đường — lúc đó fitBounds theo bước đang đi mới là camera đúng,
  // nếu không sẽ bị kéo về tâm tầng và mất dấu đoạn đường.
  useEffect(() => {
    if (isNavigating) return;
    if (mapRef.current && mapCenter) {
      mapRef.current.flyTo({
        center: [mapCenter[1], mapCenter[0]],
        zoom: 19,
        pitch: mapRef.current.getPitch(),
        bearing: mapRef.current.getBearing(),
        essential: true
      });
    }
  }, [mapCenter, isNavigating]);

  // Khi dẫn đường, ưu tiên fit đúng bước đang đi; bước chuyển tầng fit đoạn lân cận cùng tầng.
  useEffect(() => {
    if (!mapRef.current || !steps.length) return;
    const activeStep = activeStepIndex >= 0 ? steps[activeStepIndex] : null;
    const neighboringSteps = activeStep && activeStep.coords.length < 2
      ? steps.filter((step, index) =>
        Math.abs(index - activeStepIndex) === 1
        && step.floorId === activeStep.floorId
        && step.coords.length >= 2)
      : [];
    const focusSteps = activeStep?.coords?.length >= 2
      ? [activeStep]
      : neighboringSteps.length
        ? neighboringSteps
        : steps;
    const bounds = routeBounds(focusSteps);
    if (!bounds) return;
    const [minLng, minLat, maxLng, maxLat] = bounds;
    mapRef.current.fitBounds(
      [
        [minLng, minLat],
        [maxLng, maxLat],
      ],
      { padding: 80, duration: 800, maxZoom: 21 }
    );
    // fitNonce: đổi giá trị để ép fit lại dù tuyến không đổi (nút "Xem toàn tuyến").
  }, [steps, fitNonce, activeStepIndex]);

  // VÀO CHẾ ĐỘ DẪN ĐƯỜNG: hạ pitch về 0 vì bản đồ nghiêng 60° làm đường 2D khó đọc.
  // Người dùng vẫn tự bật lại 3D bằng nút 2D/3D.
  useEffect(() => {
    if (!mapRef.current || !isNavigating) return;
    setIs3D(false);
    mapRef.current.easeTo({ pitch: 0, bearing: 0, duration: 800 });
  }, [isNavigating]);

  // HÀM CHUYỂN ĐỔI 2D VÀ 3D
  const toggleViewMode = (targetIs3D) => {
    if (targetIs3D === is3D) return;
    setIs3D(targetIs3D);

    if (mapRef.current) {
      mapRef.current.easeTo({
        pitch: targetIs3D ? 60 : 0,
        bearing: targetIs3D ? -20 : 0,
        duration: 800
      });
    }
  };

  const handleMapClick = (e) => {
    if (onMapClick) {
      onMapClick({ lat: e.lngLat.lat, lng: e.lngLat.lng });
    }
  };

  return (
    <div style={{ position: 'relative', width: '100%', height: '100%' }}>

      {/* KHỐI NÚT CHUYỂN ĐỔI 2D / 3D */}
      <div style={{
        position: 'absolute',
        top: '20px',
        right: '20px',
        zIndex: 10,
        display: 'flex',
        background: '#fff',
        borderRadius: '8px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
        overflow: 'hidden'
      }}>
        <button
          onClick={() => toggleViewMode(false)}
          style={{
            padding: '8px 16px',
            border: 'none',
            background: !is3D ? '#2563EB' : 'transparent',
            color: !is3D ? '#fff' : '#475569',
            fontWeight: 600,
            cursor: 'pointer',
            transition: 'all 0.2s'
          }}
        >
          2D
        </button>
        <button
          onClick={() => toggleViewMode(true)}
          style={{
            padding: '8px 16px',
            border: 'none',
            background: is3D ? '#2563EB' : 'transparent',
            color: is3D ? '#fff' : '#475569',
            fontWeight: 600,
            cursor: 'pointer',
            transition: 'all 0.2s'
          }}
        >
          3D
        </button>
      </div>

      <Map
        ref={mapRef}
        initialViewState={initialViewState}
        style={{ width: '100%', height: '100%' }}
        mapStyle="https://basemaps.cartocdn.com/gl/positron-gl-style/style.json"
        onClick={handleMapClick}
      >

        <NavigationControl position="bottom-right" />

        {cadBackground && (
          <Source id="cad-source" type="geojson" data={cadBackground}>
            <Layer {...cadLineLayer} />
            {isThaoDienFloor && (
              <>
                <Layer {...floorPlanSiteLayer} />
                <Layer {...floorPlanWallsLayer} />
                <Layer {...floorPlanVerticalLayer} />
                <Layer {...floorPlanGateLayer} />
                <Layer {...floorPlanGateLabelLayer} />
                <Layer {...floorPlanLabelLayer} />
                <Layer {...floorPlanWalls3DLayer} layout={{ visibility: is3D ? 'visible' : 'none' }} />
                <Layer {...floorPlanVertical3DLayer} layout={{ visibility: is3D ? 'visible' : 'none' }} />
              </>
            )}
          </Source>
        )}

        {/* RENDER CÁC PHÒNG VÀ TÊN BẰNG CÁCH ẨN/HIỆN (VISIBILITY) */}
        {floorMap?.rooms && (
          <Source id="rooms-source" type="geojson" data={floorMap.rooms}>
            {/* Cả 2 layer đều được render, nhưng chỉ 1 cái hiển thị tùy vào is3D */}
            <Layer {...room3DLayer} layout={{ visibility: is3D ? 'visible' : 'none' }} />
            <Layer {...room2DLayer} layout={{ visibility: !is3D ? 'visible' : 'none' }} />

            {/* Layer Tên luôn luôn hiển thị */}
            <Layer {...roomLabelLayer} />
          </Source>
        )}

        {/* {floorMap?.edges && (
          <Source id="routing-edges-source" type="geojson" data={floorMap.edges}>
            <Layer {...edgeLayer} />
          </Source>
        )} */}

        {/* TUYẾN ĐƯỜNG CỦA TẦNG ĐANG XEM + chevron chỉ hướng */}
        {floorRoute && floorRoute.features.length > 0 && (
          <Source id="route-source" type="geojson" data={floorRoute}>
            <Layer {...routeLayer} />
            <Layer {...routeChevronLayer} />
          </Source>
        )}

        {/* ĐOẠN ĐANG ĐI — quầng trắng + line xanh đè lên tuyến */}
        {activeStepGeometry && (
          <Source id="active-step-source" type="geojson" data={activeStepGeometry}>
            <Layer {...activeStepCasingLayer} />
            <Layer {...activeStepLayer} />
          </Source>
        )}

        {floorMap?.nodes?.features?.map((feature) => {
          const nodeId = feature.properties?.id;
          const type = feature.properties?.type || 'node';
          const floorId = feature.properties?.floorId ?? currentFloorId;
          const [longitude, latitude] = feature.geometry?.coordinates || [];
          if (type === 'turn'
            || ['floor0_route', 'floor1_route', 'room_access'].includes(type)
            || type === 'gate'
            || Number(floorId) === 1
            || !Number.isFinite(longitude)
            || !Number.isFinite(latitude)
            || nodeId === startNodeId || nodeId === endNodeId) {
            return null;
          }
          const labels = {
            gate: 'Cổng',
            parking: 'Bãi đỗ xe',
            elevator: 'Thang máy',
            escalator: 'Thang cuốn',
            stair: 'Cầu thang',
            room: 'Phòng',
            room_entrance: 'Lối vào phòng',
            junction: 'Nút giao',
          };
          const label = `${labels[type] || 'Điểm'} ${nodeId}`;

          return (
            <Marker
              key={`node-${nodeId}`}
              longitude={longitude}
              latitude={latitude}
              anchor="bottom"
            >
              <button
                type="button"
                className={`map-node-marker type-${type}`}
                aria-label={`Chọn ${label} làm điểm đi hoặc điểm đến`}
                title={`${label} · bấm để chọn`}
                onClick={(event) => {
                  event.stopPropagation();
                  onNodeClick?.({
                    nodeId,
                    type,
                    floorId,
                  });
                }}
              >
                <span className="map-node-dot" aria-hidden="true" />
                <span className="map-node-label">{label}</span>
              </button>
            </Marker>
          );
        })}

        {/* MARKER ĐIỂM ĐI (xanh) */}
        {startPoint && (
          <Marker longitude={startPoint.lng} latitude={startPoint.lat} color="#10b981" />
        )}

        {/* MARKER ĐIỂM ĐẾN (đỏ) — chỉ vẽ khi node nằm cùng tầng đang xem */}
        {destinationPoint && (
          <Marker longitude={destinationPoint.lng} latitude={destinationPoint.lat} color="#dc2626" />
        )}

      </Map>
    </div>
  );
}