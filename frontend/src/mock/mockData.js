// =========================================================
// MOCK DATA CHO FRONTEND — dùng để code song song, KHÔNG CẦN CHỜ BACKEND
// Bao phủ ĐẦY ĐỦ 4 nhóm API: A (Bản đồ), B (Tìm kiếm & định vị),
// C (Định tuyến), D (Quản trị) — khớp với PhanChiaTask_BE_FE.md
//
// Toàn bộ số liệu nhóm A/B/C và phần lớn nhóm D lấy TỪ KẾT QUẢ TEST THẬT
// trên schema.sql + seed_data.sql (đã chạy qua PostgreSQL/PostGIS/pgRouting
// thật, không phải số bịa). Vài chỗ không thể test thật (ví dụ response
// login JWT, response import file) được đánh dấu rõ "[GIẢ ĐỊNH]".
// =========================================================

// =========================================================
// A. NHÓM API BẢN ĐỒ
// =========================================================

// GET /api/floors
export const mockFloors = [
  { "id": 1, "name": "B1 - Sảnh chính", "levelOrder": -1 },
  { "id": 2, "name": "B2 - Sân ga", "levelOrder": -2 }
];

// GET /api/floors/1/map  (6 node + 8 edge + 2 room — trích thật từ DB)
export const mockFloor1Map = {
  "nodes": {
    "type": "FeatureCollection",
    "features": [
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698000000, 10.772000000] }, "properties": { "id": 1, "type": "gate", "floorId": 1 } },
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698091442, 10.772224578] }, "properties": { "id": 2, "type": "gate", "floorId": 1 } },
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698091442, 10.772000000] }, "properties": { "id": 3, "type": "junction", "floorId": 1 } },
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698182885, 10.772000000] }, "properties": { "id": 4, "type": "junction", "floorId": 1 } },
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698274327, 10.772000000] }, "properties": { "id": 5, "type": "elevator", "floorId": 1 } },
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698091442, 10.772134747] }, "properties": { "id": 6, "type": "junction", "floorId": 1 } }
    ]
  },
  "edges": {
    "type": "FeatureCollection",
    "features": [
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698000000,10.772000000],[106.698091442,10.772000000]] }, "properties": { "id": 1, "source": 1, "target": 3, "cost": 10, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698091442,10.772000000],[106.698182885,10.772000000]] }, "properties": { "id": 2, "source": 3, "target": 4, "cost": 10, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698182885,10.772000000],[106.698091442,10.772000000]] }, "properties": { "id": 3, "source": 4, "target": 3, "cost": 10, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698091442,10.772000000],[106.698091442,10.772134747]] }, "properties": { "id": 4, "source": 3, "target": 6, "cost": 15, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698091442,10.772134747],[106.698091442,10.772000000]] }, "properties": { "id": 5, "source": 6, "target": 3, "cost": 15, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698091442,10.772134747],[106.698091442,10.772224578]] }, "properties": { "id": 6, "source": 6, "target": 2, "cost": 10, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698182885,10.772000000],[106.698274327,10.772000000]] }, "properties": { "id": 7, "source": 4, "target": 5, "cost": 10, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698274327,10.772000000],[106.698182885,10.772000000]] }, "properties": { "id": 8, "source": 5, "target": 4, "cost": 10, "edgeType": "corridor" } }
    ]
  },
  "rooms": {
    "type": "FeatureCollection",
    "features": [
      { "type": "Feature", "geometry": { "type": "Polygon", "coordinates": [[[106.698168,10.771990],[106.698198,10.771990],[106.698198,10.772010],[106.698168,10.772010],[106.698168,10.771990]]] }, "properties": { "id": 1, "name": "Phòng vé", "category": "ticket_office", "floorId": 1 } },
      { "type": "Feature", "geometry": { "type": "Polygon", "coordinates": [[[106.698076,10.772125],[106.698106,10.772125],[106.698106,10.772145],[106.698076,10.772145],[106.698076,10.772125]]] }, "properties": { "id": 2, "name": "Nhà vệ sinh nam", "category": "restroom", "floorId": 1 } }
    ]
  }
};

// GET /api/floors/2/map  (4 node + 5 edge + 2 room — trích thật từ DB)
export const mockFloor2Map = {
  "nodes": {
    "type": "FeatureCollection",
    "features": [
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698274327, 10.772000000] }, "properties": { "id": 7, "type": "elevator", "floorId": 2 } },
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698274327, 10.772179662] }, "properties": { "id": 8, "type": "junction", "floorId": 2 } },
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698137164, 10.772179662] }, "properties": { "id": 9, "type": "junction", "floorId": 2 } },
      { "type": "Feature", "geometry": { "type": "Point", "coordinates": [106.698411491, 10.772179662] }, "properties": { "id": 10, "type": "junction", "floorId": 2 } }
    ]
  },
  "edges": {
    "type": "FeatureCollection",
    "features": [
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698274327,10.772000000],[106.698274327,10.772179662]] }, "properties": { "id": 11, "source": 7, "target": 8, "cost": 20, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698274327,10.772179662],[106.698274327,10.772000000]] }, "properties": { "id": 12, "source": 8, "target": 7, "cost": 20, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698274327,10.772179662],[106.698137164,10.772179662]] }, "properties": { "id": 13, "source": 8, "target": 9, "cost": 15, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698137164,10.772179662],[106.698274327,10.772179662]] }, "properties": { "id": 14, "source": 9, "target": 8, "cost": 15, "edgeType": "corridor" } },
      { "type": "Feature", "geometry": { "type": "LineString", "coordinates": [[106.698274327,10.772179662],[106.698411491,10.772179662]] }, "properties": { "id": 15, "source": 8, "target": 10, "cost": 15, "edgeType": "corridor" } }
    ]
  },
  "rooms": {
    "type": "FeatureCollection",
    "features": [
      { "type": "Feature", "geometry": { "type": "Polygon", "coordinates": [[[106.698396,10.772170],[106.698426,10.772170],[106.698426,10.772190],[106.698396,10.772190],[106.698396,10.772170]]] }, "properties": { "id": 3, "name": "Sân ga hướng Bến Thành", "category": "platform", "floorId": 2 } },
      { "type": "Feature", "geometry": { "type": "Polygon", "coordinates": [[[106.698122,10.772170],[106.698152,10.772170],[106.698152,10.772190],[106.698122,10.772190],[106.698122,10.772170]]] }, "properties": { "id": 4, "name": "Sân ga hướng Suối Tiên", "category": "platform", "floorId": 2 } }
    ]
  }
};

// =========================================================
// B. NHÓM API TÌM KIẾM & ĐỊNH VỊ ĐIỂM
// =========================================================

// GET /api/rooms/search?q=san ga  (dữ liệu thật từ bảng room)
export const mockSearchResults = [
  { "id": 3, "name": "Sân ga hướng Bến Thành", "floorId": 2, "category": "platform", "nodeId": 10 },
  { "id": 4, "name": "Sân ga hướng Suối Tiên", "floorId": 2, "category": "platform", "nodeId": 9 }
];

// GET /api/rooms/search?q=xyz  (không có kết quả — response hợp lệ, KHÔNG phải lỗi)
export const mockSearchEmpty = [];

// GET /api/nodes/nearest?lat=10.772&lng=106.698&floorId=1
export const mockNearestNode = {
  "nodeId": 1,
  "distance": 0.8,
  "geometry": { "type": "Point", "coordinates": [106.698000000, 10.772000000] }
};

// GET /api/nodes/nearest (không có node nào trong bán kính — 404)
export const mockNearestNodeError = {
  "error": "NO_NEARBY_NODE",
  "message": "Không tìm thấy vị trí hợp lệ gần điểm đã chọn"
};

// =========================================================
// C. NHÓM API ĐỊNH TUYẾN
// =========================================================

// POST /api/route  { startNodeId: 1, endNodeId: 10, criteria: "distance" }
// SỐ THẬT lấy từ pgr_dijkstra chạy trên seed_data.sql: đường đi 1-3-4-5-7-8-10, agg_cost=70
export const mockRouteResponse = {
  "totalDistance": 70,
  "totalTimeEstimate": 91.7,
  "geometry": {
    "type": "Feature",
    "geometry": {
      "type": "LineString",
      "coordinates": [
        [106.698000000, 10.772000000],
        [106.698091442, 10.772000000],
        [106.698182885, 10.772000000],
        [106.698274327, 10.772000000],
        [106.698274327, 10.772000000],
        [106.698274327, 10.772179662],
        [106.698411491, 10.772179662]
      ]
    },
    "properties": {}
  },
  "transferPoints": [
    { "nodeId": 5, "transferType": "elevator", "fromFloorId": 1, "toFloorId": 2, "avgTime": 25 }
  ],
  // Payload này mô phỏng BACKEND MỚI: có đủ maneuver + duration + geometry từng bước.
  // - duration: giây (edge.cost_time), nên bước thang máy hiện "~25 giây" thay vì "0 m".
  // - floorId : tầng CỦA BƯỚC NÀY (bước chuyển tầng thuộc tầng xuất phát).
  // - geometry: null ở bước chuyển tầng (trigger DB set geom_wgs84 = NULL cho stair/elevator/escalator).
  // Cố ý để maneuver của bước 4-5 = null để nhánh fallback của enrichSteps được chạy thật:
  // nó phải tự suy ra STRAIGHT (bước 4) và RIGHT (bước 5, ngoặt từ hướng Bắc sang hướng Đông).
  // duration cộng lại ĐÚNG BẰNG totalTimeEstimate (12 + 12 + 25 + 24.2 + 18.5 = 91.7),
  // giống backend vì cả hai đều lấy từ cùng edge.cost_time.
  "steps": [
    {
      "order": 1,
      "instruction": "Đi thẳng khoảng 10m dọc hành lang chính từ Cổng A",
      "distance": 10,
      "duration": 12,
      "floorId": 1,
      "maneuver": "DEPART",
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [[106.698000000, 10.772000000], [106.698091442, 10.772000000]]
        },
        "properties": {}
      }
    },
    {
      "order": 2,
      "instruction": "Tiếp tục đi thẳng khoảng 10m qua khu vực soát vé",
      "distance": 10,
      "duration": 12,
      "floorId": 1,
      "maneuver": "STRAIGHT",
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [[106.698091442, 10.772000000], [106.698182885, 10.772000000]]
        },
        "properties": {}
      }
    },
    {
      "order": 3,
      "instruction": "Di chuyển bằng thang máy xuống tầng B2 (khoảng 25 giây)",
      "distance": 0,
      "duration": 25,
      "floorId": 1,
      "maneuver": "ELEVATOR",
      "geometry": null
    },
    {
      "order": 4,
      "instruction": "Đi thẳng khoảng 20m đến giao lộ sân ga",
      "distance": 20,
      "duration": 24.2,
      "floorId": 2,
      "maneuver": null,
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [106.698182885, 10.772000000],
            [106.698274327, 10.772000000],
            [106.698274327, 10.772179662]
          ]
        },
        "properties": {}
      }
    },
    {
      "order": 5,
      "instruction": "Đi thẳng khoảng 15m đến Sân ga hướng Bến Thành",
      "distance": 15,
      "duration": 18.5,
      "floorId": 2,
      "maneuver": null,
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [[106.698274327, 10.772179662], [106.698411491, 10.772179662]]
        },
        "properties": {}
      }
    }
  ]
};

// POST /api/route  { startNodeId: 1, endNodeId: 9, criteria: "time" }
// SỐ THẬT: cùng đường đi nhưng tổng thời gian = 79.17s (khác totalDistance vì criteria khác)
export const mockRouteResponseByTime = {
  "totalDistance": 65,
  "totalTimeEstimate": 79.17,
  "geometry": {
    "type": "Feature",
    "geometry": {
      "type": "LineString",
      "coordinates": [
        [106.698000000, 10.772000000],
        [106.698091442, 10.772000000],
        [106.698182885, 10.772000000],
        [106.698274327, 10.772000000],
        [106.698274327, 10.772000000],
        [106.698274327, 10.772179662],
        [106.698137164, 10.772179662]
      ]
    },
    "properties": {}
  },
  "transferPoints": [
    { "nodeId": 5, "transferType": "elevator", "fromFloorId": 1, "toFloorId": 2, "avgTime": 25 }
  ],
  // Cùng 5 bước, nhưng đoạn cuối rẽ ngược về hướng Tây (Sân ga hướng Suối Tiên nằm bên kia
  // hành lang) — nên fallback của enrichSteps phải ra LEFT chứ không phải RIGHT như payload trên.
  // Đây là ca kiểm tra nhánh âm của classifyManeuver mà payload "distance" không chạm tới.
  // duration cộng lại ĐÚNG BẰNG totalTimeEstimate (12 + 12 + 25 + 24.2 + 6 = 79.2 ≈ 79.17).
  "steps": [
    {
      "order": 1,
      "instruction": "Đi thẳng khoảng 10m dọc hành lang chính từ Cổng A",
      "distance": 10,
      "duration": 12,
      "floorId": 1,
      "maneuver": "DEPART",
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [[106.698000000, 10.772000000], [106.698091442, 10.772000000]]
        },
        "properties": {}
      }
    },
    {
      "order": 2,
      "instruction": "Tiếp tục đi thẳng khoảng 10m qua khu vực soát vé",
      "distance": 10,
      "duration": 12,
      "floorId": 1,
      "maneuver": "STRAIGHT",
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [[106.698091442, 10.772000000], [106.698182885, 10.772000000]]
        },
        "properties": {}
      }
    },
    {
      "order": 3,
      "instruction": "Di chuyển bằng thang máy xuống tầng B2 (khoảng 25 giây)",
      "distance": 0,
      "duration": 25,
      "floorId": 1,
      "maneuver": "ELEVATOR",
      "geometry": null
    },
    {
      "order": 4,
      "instruction": "Đi thẳng khoảng 20m đến giao lộ sân ga",
      "distance": 20,
      "duration": 24.2,
      "floorId": 2,
      "maneuver": null,
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [
            [106.698182885, 10.772000000],
            [106.698274327, 10.772000000],
            [106.698274327, 10.772179662]
          ]
        },
        "properties": {}
      }
    },
    {
      "order": 5,
      "instruction": "Đi thẳng khoảng 15m đến Sân ga hướng Suối Tiên",
      "distance": 15,
      "duration": 6.0,
      "floorId": 2,
      "maneuver": null,
      "geometry": {
        "type": "Feature",
        "geometry": {
          "type": "LineString",
          "coordinates": [[106.698274327, 10.772179662], [106.698137164, 10.772179662]]
        },
        "properties": {}
      }
    }
  ]
};

// POST /api/route với startNodeId=2 (Cổng B - lối RA, không có edge đi ra) — 404 THẬT đã test
export const mockRouteError = {
  "error": "ROUTE_NOT_FOUND",
  "message": "Không tìm thấy tuyến đường phù hợp giữa hai điểm"
};
