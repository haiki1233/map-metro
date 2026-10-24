import { useEffect, useRef, useState } from 'react';
import MapView from './components/MapView.jsx';
import FloorSwitcher from './components/FloorSwitcher.jsx';
import SearchBar from './components/SearchBar.jsx';
import RoutePanel from './components/RoutePanel.jsx';
import { getFloorMap, getFloors, findNearestNode, findRoute, getFloorTransform, getFloorFeatures } from './api/indoorNavApi.js';
import { enrichSteps } from './utils/routeGuidance.js';

const NODE_TYPE_LABELS = {
  gate: 'Cổng',
  parking: 'Bãi đỗ xe',
  elevator: 'Thang máy',
  escalator: 'Thang cuốn',
  stair: 'Cầu thang',
  room: 'Phòng',
  room_entrance: 'Lối vào phòng',
  junction: 'Nút giao',
};

export default function App() {
  const [floors, setFloors] = useState([]);
  const [currentFloorId, setCurrentFloorId] = useState(null);

  // States cho bản đồ
  const [floorMap, setFloorMap] = useState(null);
  const [mapCenter, setMapCenter] = useState(null);
  const [cadBackground, setCadBackground] = useState(null);
  const [isLoadingMap, setIsLoadingMap] = useState(false);
  const [mapError, setMapError] = useState(null);
  const [floorsError, setFloorsError] = useState(null);

  // States cho tìm đường — điểm đi và điểm đến độc lập nhau
  const [startNodeId, setStartNodeId] = useState(null);
  const [startFloorId, setStartFloorId] = useState(null);
  const [startPoint, setStartPoint] = useState(null); // chỉ có khi bấm trực tiếp lên bản đồ
  const [startLabel, setStartLabel] = useState(null);
  const [endNodeId, setEndNodeId] = useState(null);
  const [endFloorId, setEndFloorId] = useState(null);
  const [endLabel, setEndLabel] = useState(null);

  const [criteria, setCriteria] = useState('distance');
  const [route, setRoute] = useState(null);
  const [routeError, setRouteError] = useState(null);
  const [isLoadingRoute, setIsLoadingRoute] = useState(false);

  // States cho dẫn đường từng bước
  const [activeStepIndex, setActiveStepIndex] = useState(-1); // -1 = chưa bắt đầu
  const [fitNonce, setFitNonce] = useState(0);
  const nearestRequestId = useRef(0);

  const isNavigating = activeStepIndex >= 0;

  useEffect(() => {
    let isCurrentRequest = true;
    getFloors()
      .then((data) => {
        if (!isCurrentRequest) return;
        setFloors(data);
        if (data.length > 0) setCurrentFloorId(data[0].id);
      })
      .catch((error) => {
        console.error('Lỗi khi tải danh sách tầng:', error);
        if (isCurrentRequest) setFloorsError('Không thể tải danh sách tầng. Vui lòng thử tải lại trang.');
      });
    return () => { isCurrentRequest = false; };
  }, []);

  // Tải đồng thời 3 API bản đồ khi chọn tầng
  useEffect(() => {
    if (currentFloorId == null) return;

    let isCurrentRequest = true;
    setIsLoadingMap(true);
    setMapError(null);
    Promise.all([
      getFloorMap(currentFloorId),
      getFloorTransform(currentFloorId),
      getFloorFeatures(currentFloorId)
    ])
      .then(([mapData, transformData, featuresData]) => {
        if (!isCurrentRequest) return;
        setFloorMap({ ...mapData, __floorId: currentFloorId });

        // [FIX 1]: Đề phòng backend trả về camelCase hoặc snake_case
        const lat = transformData.originLat ?? transformData.origin_lat;
        const lng = transformData.originLng ?? transformData.origin_lng;
        setMapCenter([lat, lng]);

        setCadBackground(featuresData);
      })
      .catch((err) => {
        console.error("Lỗi khi tải dữ liệu bản đồ:", err);
        if (isCurrentRequest) {
          setFloorMap(null);
          setMapError(err.response?.data?.message || 'Không thể tải dữ liệu bản đồ của tầng này.');
        }
      })
      .finally(() => {
        if (isCurrentRequest) setIsLoadingMap(false);
      });
    return () => { isCurrentRequest = false; };
  }, [currentFloorId]);

  // Có đủ 2 đầu -> tính tuyến. Đổi tiêu chí cũng tính lại.
  useEffect(() => {
    if (startNodeId == null || endNodeId == null) {
      setIsLoadingRoute(false);
      return undefined;
    }

    let isCurrentRequest = true;
    setIsLoadingRoute(true);
    setRoute(null);
    setRouteError(null);
    findRoute(startNodeId, endNodeId, criteria)
      .then((data) => {
        if (isCurrentRequest) setRoute(data);
      })
      .catch((err) => {
        if (!isCurrentRequest) return;
        setRoute(null);
        setRouteError(err.response?.data?.message || 'Không tìm thấy tuyến đường phù hợp');
      })
      .finally(() => {
        if (isCurrentRequest) setIsLoadingRoute(false);
      });
    return () => { isCurrentRequest = false; };
  }, [startNodeId, endNodeId, criteria]);

  // Tuyến mới -> thoát chế độ dẫn đường, tránh con trỏ bước trỏ vào tuyến cũ.
  useEffect(() => {
    setActiveStepIndex(-1);
  }, [route]);

  // Đổi bước -> nhảy sang tầng của bước đó, và fit lại camera về đoạn đang đi.
  useEffect(() => {
    if (activeStepIndex < 0 || !route?.steps) return;
    const step = enrichSteps(route)[activeStepIndex];
    if (!step) return;
    if (step.floorId != null && step.floorId !== currentFloorId) setCurrentFloorId(step.floorId);
    setFitNonce((n) => n + 1);
    // currentFloorId cố ý không nằm trong deps: đây là effect "đổi bước", không phải "đổi tầng".
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [activeStepIndex, route]);

  /**
   * Toạ độ marker của 1 node. RoomSearchResult KHÔNG trả geometry, nên tra từ floorMap.nodes
   * của tầng đang xem. Node ở tầng khác -> trả null và KHÔNG vẽ marker, thay vì bịa toạ độ.
   */
  function nodePoint(nodeId, floorId) {
    if (nodeId == null || floorId == null || floorId !== currentFloorId) return null;
    const feature = floorMap?.nodes?.features?.find((f) => f.properties?.id === nodeId);
    const coords = feature?.geometry?.coordinates;
    if (!coords) return null;
    return { lat: coords[1], lng: coords[0] }; // GeoJSON Point là [lng, lat]
  }

  async function handleMapClick(latlng) {
    if (currentFloorId == null) return;
    const requestId = ++nearestRequestId.current;
    try {
      const nearest = await findNearestNode(latlng.lat, latlng.lng, currentFloorId);
      if (requestId !== nearestRequestId.current) return;
      setStartNodeId(nearest.nodeId);
      setStartFloorId(currentFloorId);
      const [lng, lat] = nearest.geometry.coordinates; // PostGIS trả về GeoJSON Point là [lng, lat]
      setStartPoint({ lat, lng });
      const floorLabel = floors.find((f) => f.id === currentFloorId)?.name || `tầng ${currentFloorId}`;
      setStartLabel(`Vị trí trên bản đồ (${floorLabel})`);
    } catch (error) {
      if (requestId !== nearestRequestId.current) return;
      console.error('Lỗi khi tìm vị trí gần nhất:', error);
      // [FIX 3]: Xóa dữ liệu cũ nếu click vào chỗ không hợp lệ
      setStartNodeId(null);
      setStartFloorId(null);
      setStartPoint(null);
      setStartLabel(null);
      setRoute(null);
      setRouteError(error.response?.data?.message || 'Không tìm thấy vị trí hợp lệ gần điểm bạn chọn');
    }
  }

  function handleSelectStart(result) {
    nearestRequestId.current += 1;
    setStartNodeId(result.nodeId);
    setStartFloorId(result.floorId);
    setStartLabel(result.name);
    setStartPoint(null); // toạ độ suy ra từ floorMap.nodes, tránh lệch tầng
    if (result.floorId != null) setCurrentFloorId(result.floorId);
  }

  function handleSelectEnd(result) {
    setEndNodeId(result.nodeId);
    setEndFloorId(result.floorId);
    setEndLabel(result.name);
    if (result.floorId != null) setCurrentFloorId(result.floorId);
  }

  function handleNodeSelect(node) {
    if (node.nodeId == null || node.floorId == null) return;
    if (node.nodeId === startNodeId || node.nodeId === endNodeId) return;

    const floorName = floors.find((floor) => floor.id === node.floorId)?.name
      || `tầng ${node.floorId}`;
    const typeName = NODE_TYPE_LABELS[node.type] || 'Điểm';
    const selection = {
      nodeId: node.nodeId,
      floorId: node.floorId,
      name: `${typeName} ${node.nodeId} (${floorName})`,
    };

    if (startNodeId == null) {
      handleSelectStart(selection);
    } else {
      handleSelectEnd(selection);
    }
  }

  function handleClear(role) {
    if (role === 'start') {
      nearestRequestId.current += 1;
      setStartNodeId(null);
      setStartFloorId(null);
      setStartPoint(null);
      setStartLabel(null);
    } else {
      setEndNodeId(null);
      setEndFloorId(null);
      setEndLabel(null);
    }
    setRoute(null);
    setRouteError(null);
  }

  /**
   * Hoán đổi điểm đi <-> điểm đến. Chỉ đổi được khi đã có đủ 2 đầu, vì `nodeId` mới là thứ
   * backend cần để tính tuyến — đổi nhãn không mà không đổi node sẽ ra chỉ dẫn sai.
   */
  function handleSwap() {
    if (startNodeId == null || endNodeId == null) return;
    nearestRequestId.current += 1;
    const prevStart = { id: startNodeId, floorId: startFloorId, label: startLabel };

    setStartNodeId(endNodeId);
    setStartFloorId(endFloorId);
    setStartLabel(endLabel);
    // Toạ độ cũ thuộc về điểm đi cũ, không dùng lại được cho điểm đi mới -> để `nodePoint` tra.
    setStartPoint(null);
    setEndNodeId(prevStart.id);
    setEndFloorId(prevStart.floorId);
    setEndLabel(prevStart.label);

    if (endFloorId != null) setCurrentFloorId(endFloorId);

    setRoute(null);
    setRouteError(null);
  }

  // Marker điểm đi: ưu tiên toạ độ từ click bản đồ (chính xác hơn), sau đó tra theo node.
  const startMarker = startPoint || nodePoint(startNodeId, startFloorId);
  // Marker điểm đến: chỉ vẽ khi node nằm cùng tầng đang xem.
  const destinationPoint = nodePoint(endNodeId, endFloorId);

  return (
    <div className="app-layout">
      <aside className="sidebar">
        <h1>Tìm đường nội khu</h1>
        {floorsError && <p className="app-error">{floorsError}</p>}
        <FloorSwitcher
          floors={floors}
          currentFloorId={currentFloorId}
          onChange={setCurrentFloorId}
          criteria={criteria}
          onCriteriaChange={setCriteria}
          disabled={isNavigating}
        />
        <SearchBar
          floors={floors}
          criteria={criteria}
          startLabel={startLabel}
          endLabel={endLabel}
          onSelectStart={handleSelectStart}
          onSelectEnd={handleSelectEnd}
          onClear={handleClear}
          onSwap={handleSwap}
        />

        <RoutePanel
          route={route}
          error={routeError}
          isLoading={isLoadingRoute}
          criteria={criteria}
          onCriteriaChange={setCriteria}
          floors={floors}
          startLabel={startLabel}
          endLabel={endLabel}
          activeStepIndex={activeStepIndex}
          onActiveStepChange={setActiveStepIndex}
          onStartNavigation={() => setActiveStepIndex(0)}
          onStopNavigation={() => setActiveStepIndex(-1)}
          onFitRoute={() => setFitNonce((n) => n + 1)}
        />
      </aside>

      <main className="map-container">
        {isLoadingMap ? (
          // [FIX 2]: Dùng CSS class thay vì inline style
          <div className="map-loading">
            Đang tải bản đồ...
          </div>
        ) : mapError ? (
          <div className="map-error">{mapError}</div>
        ) : (
          floorMap && mapCenter && (
            <MapView
              floorMap={floorMap}
              mapCenter={mapCenter}
              cadBackground={cadBackground}
              route={route}
              startPoint={startMarker}
              destinationPoint={destinationPoint}
              startNodeId={startNodeId}
              endNodeId={endNodeId}
              activeStepIndex={activeStepIndex}
              fitNonce={fitNonce}
              isNavigating={isNavigating}
              onMapClick={handleMapClick}
              onNodeClick={handleNodeSelect}
            />
          )
        )}
      </main>
    </div>
  );
}