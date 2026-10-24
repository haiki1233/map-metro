# ĐẶC TẢ REST API — HỆ THỐNG TÌM ĐƯỜNG NỘI KHU GA METRO

> Base URL: `/api`
> Trạng thái triển khai: nhóm API công khai A/B/C được triển khai; nhóm D bên dưới là đặc tả tương lai, chưa có trong backend hiện tại.
> Xác thực: các API đang triển khai đều công khai; xác thực JWT cho API quản trị chưa được triển khai.
> Thuật toán định tuyến: **Dijkstra** (pgRouting `pgr_dijkstra`) — hệ thống chỉ dùng duy nhất thuật toán này, không có lựa chọn thuật toán khác
> Xác thực: JWT Bearer Token (chỉ áp dụng nhóm API Quản trị — mục D)

---

## 0. Quy ước hệ tọa độ (đọc trước khi triển khai)

Hệ thống dùng **2 hệ tọa độ song song**, chuyển đổi cho nhau ở tầng Backend:

| Hệ tọa độ | Đơn vị | Dùng để | Phạm vi sử dụng |
|---|---|---|---|
| **Tọa độ cục bộ (Local Cartesian)** | mét, gốc (0,0) đặt tại 1 điểm mốc trong ga | Lưu trữ Node/Edge dùng cho routing, tính `cost` cho `pgr_dijkstra` | Nội bộ CSDL + tầng Service của Backend |
| **WGS84 (EPSG:4326 — kinh/vĩ độ)** | độ | Toàn bộ dữ liệu trao đổi qua API (đúng chuẩn GeoJSON RFC 7946), hiển thị trên Leaflet | Toàn bộ request/response ở tầng API |

**Lý do:** dù chỉ dùng Dijkstra (không cần heuristic như A*), việc tính `cost` bằng mét thực vẫn quan trọng vì: (1) cho kết quả `totalDistance`/`totalTimeEstimate` chính xác thay vì suy ra gần đúng từ độ kinh/vĩ; (2) các truy vấn không gian như tìm node gần nhất (`ST_ClosestPoint`, `ST_DWithin`) chính xác và nhanh hơn khi làm việc trên phạm vi nhỏ (trong 1 tòa nhà) bằng đơn vị mét thay vì độ.

**Cơ chế chuyển đổi:** mỗi tầng (Floor) lưu sẵn 1 bộ tham số phép biến đổi Affine (`originLat`, `originLng`, `scaleX`, `scaleY`, `rotation`) — xác định 1 lần khi số hóa. Backend dùng bộ tham số này để chuyển `(x, y)` mét ↔ `(lat, lng)` độ ở tầng Service. Frontend và các API tiêu thụ dữ liệu (nhóm A, B, C) **không cần biết** đến hệ tọa độ cục bộ này — mọi request/response public đều là WGS84 như bình thường.

**Ngoại lệ duy nhất:** nhóm API Quản trị (D.2, D.3) hỗ trợ thêm trường `localCoordinates` (mét) làm input thay thế, thuận tiện hơn cho đội số hóa khi thao tác trong phạm vi 1 tòa nhà.

---

## A. NHÓM API BẢN ĐỒ (FR-01, FR-02)

### A.1. Lấy danh sách tầng

| | |
|---|---|
| **FR liên quan** | FR-02 |
| **Method / Endpoint** | `GET /api/floors` |
| **Mô tả** | Trả về danh sách tất cả các tầng của ga, dùng để dựng thanh chuyển tầng |

**Response `200 OK`:**
```json
[
  { "id": 1, "name": "B4 - Sân ga", "levelOrder": -4 },
  { "id": 2, "name": "B3", "levelOrder": -3 },
  { "id": 3, "name": "B2", "levelOrder": -2 },
  { "id": 4, "name": "B1 - Sảnh chính", "levelOrder": -1 }
]
```

### A.2. Lấy dữ liệu bản đồ theo tầng

| | |
|---|---|
| **FR liên quan** | FR-01, FR-02 |
| **Method / Endpoint** | `GET /api/floors/{floorId}/map` |
| **Mô tả** | Trả về toàn bộ dữ liệu Node, Edge, Room của một tầng dưới dạng GeoJSON FeatureCollection. Tọa độ trong response luôn ở WGS84 |
| **Path param** | `floorId` (int, bắt buộc) |

**Response `200 OK`:**
```json
{
  "nodes": {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": { "type": "Point", "coordinates": [106.6980, 10.7720] },
        "properties": { "id": 12, "type": "junction", "floorId": 4 }
      }
    ]
  },
  "edges": {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": { "type": "LineString", "coordinates": [[106.6980,10.7720],[106.6982,10.7721]] },
        "properties": { "id": 34, "source": 12, "target": 15, "cost": 8.2, "edgeType": "corridor" }
      }
    ]
  },
  "rooms": {
    "type": "FeatureCollection",
    "features": [
      {
        "type": "Feature",
        "geometry": { "type": "Polygon", "coordinates": [[[106.6979,10.7719],[106.6981,10.7719],[106.6981,10.7721],[106.6979,10.7721],[106.6979,10.7719]]] },
        "properties": { "id": 5, "name": "Phòng vé", "category": "ticket_office", "floorId": 4 }
      }
    ]
  }
}
```
> `cost` trong `properties` của Edge là mét thực (từ tọa độ cục bộ) — dùng trực tiếp làm trọng số cho `pgr_dijkstra`.

**Lỗi:** `404 Not Found` nếu `floorId` không tồn tại.

### A.3. Lấy phép biến đổi tọa độ của tầng

| | |
|---|---|
| **Method / Endpoint** | `GET /api/map/floors/{floorId}/transform` |
| **Mô tả** | Trả về `originLat`, `originLng`, `scaleX`, `scaleY` và `rotationDeg` của tầng để frontend căn chỉnh bản vẽ |

**Lỗi:** `404 Not Found` nếu tầng chưa có cấu hình transform.

### A.4. Lấy các đối tượng nền bản vẽ

| | |
|---|---|
| **Method / Endpoint** | `GET /api/map/features/{floorId}` |
| **Response** | GeoJSON `FeatureCollection`; geometry được chuyển về 2D cho phù hợp RFC 7946 |

Tầng hợp lệ chưa có đối tượng bản vẽ trả về `features: []`. Trả `404 Not Found` nếu tầng không tồn tại.

---

## B. NHÓM API TÌM KIẾM & ĐỊNH VỊ ĐIỂM (FR-03, FR-04, FR-05)

### B.1. Tìm kiếm khu vực chức năng và điểm trên bản đồ

| | |
|---|---|
| **FR liên quan** | FR-03 |
| **Method / Endpoint** | `GET /api/rooms/search` |
| **Query params** | `q` (string, tùy chọn khi có `category`), `category` (string, tùy chọn), `floorId` (int, tùy chọn) |

**Ví dụ:** `GET /api/rooms/search?q=nha ve sinh`; lọc thang máy, thang bộ hoặc thang cuốn theo `category=elevator`, `category=stair` hoặc `category=escalator`. Có thể giới hạn tầng bằng `floorId`.

**Response `200 OK`:**
```json
[
  { "id": 8, "name": "Nhà vệ sinh nam", "floorId": 3, "category": "restroom", "nodeId": 40, "resultType": "room" },
  { "id": 10, "name": "Cổng 10", "floorId": 1, "category": "gate", "nodeId": 10, "resultType": "node" }
]
```
Kết quả bao gồm phòng/khu vực (`resultType: "room"`) và các node có thể chọn như cổng, bãi đỗ xe, thang máy, thang bộ và thang cuốn (`resultType: "node"`). Thiết bị thang dùng tên từ nhãn `vertical_link` và được trả về riêng cho từng tầng; không cần tạo bản ghi tương ứng trong bảng `room`. Các trường `id`, `nodeId`, `floorId`, `category` và `name` dùng chung để frontend chọn điểm. GeoJSON phòng của API bản đồ cũng trả `baseHeight` lấy từ Z của hình học để dựng đúng cao độ mặt bằng.

**Lỗi:** `200 OK` với mảng rỗng `[]` nếu không tìm thấy.

### B.2. Tìm node gần nhất (snap điểm người dùng chọn vào mạng lưới)

| | |
|---|---|
| **FR liên quan** | FR-04, FR-05 |
| **Method / Endpoint** | `GET /api/nodes/nearest` |
| **Query params** | `lat` (double, bắt buộc), `lng` (double, bắt buộc), `floorId` (int, bắt buộc), `maxDistance` (double, mét, mặc định 15) |
| **Xử lý nội bộ** | Backend truy vấn `geom_wgs84` của tầng theo khoảng cách `geography` (đơn vị mét), giới hạn bằng `ST_DWithin` và trả về node gần nhất |

**Response `200 OK`:**
```json
{ "nodeId": 27, "distance": 3.4, "geometry": { "type": "Point", "coordinates": [106.6981, 10.7722] } }
```
**Lỗi:** `404 Not Found` — `{ "error": "NO_NEARBY_NODE", "message": "Không tìm thấy vị trí hợp lệ gần điểm đã chọn" }`.

---

## C. NHÓM API ĐỊNH TUYẾN (FR-06 → FR-11)

### C.1. Tìm đường ngắn nhất (Dijkstra)

| | |
|---|---|
| **FR liên quan** | FR-06, FR-07, FR-08, FR-09, FR-10, FR-11 |
| **Method / Endpoint** | `POST /api/route` |
| **Mô tả** | API trung tâm — tính tuyến đường bằng `pgr_dijkstra` và trả toàn bộ dữ liệu cần thiết (hình học, hướng dẫn từng bước, điểm chuyển tầng, khoảng cách/thời gian) trong 1 lần gọi |
| **Xử lý nội bộ** | `pgr_dijkstra` chạy trên bảng edge với cột `cost` tính bằng mét thực (tọa độ cục bộ). Sau khi có kết quả, Backend chuyển hình học tuyến đường sang WGS84 để trả về Frontend |

**Request body:**
```json
{
  "startNodeId": 12,
  "endNodeId": 58,
  "criteria": "distance"
}
```
| Trường | Kiểu | Bắt buộc | Ghi chú |
|---|---|---|---|
| `startNodeId` | int | có | Lấy từ B.2 |
| `endNodeId` | int | có | Lấy từ B.2 hoặc B.1 |
| `criteria` | string | không | `"distance"`/`"shortest"` \| `"time"`/`"fastest"` \| `"least_stairs"`/`"less_stairs"` \| `"accessible"`, mặc định `"distance"`. Chế độ xe lăn loại cạnh cầu thang và thang cuốn khỏi đồ thị truy vấn. |

Chi phí thời gian dùng tốc độ đi bộ `1.2 m/s`, cầu thang `0.6 m/s`, thang cuốn `0.8 m/s`; cạnh thang máy dùng thời gian trung bình mỗi tầng trong `vertical_link` cộng `15 giây` chờ. Chế độ ít cầu thang nhân chi phí cạnh `stair` lên `10`; xe lăn loại bỏ cạnh cầu thang/thang cuốn nhưng vẫn cho phép hành lang, ramp và thang máy.

**Response `200 OK`:**
```json
{
  "totalDistance": 128.5,
  "totalTimeEstimate": 165,
  "geometry": {
    "type": "Feature",
    "geometry": { "type": "LineString", "coordinates": [[106.6980,10.7720], [106.6982,10.7721], "..."] },
    "properties": {}
  },
  "transferPoints": [
    { "nodeId": 34, "transferType": "elevator", "fromFloorId": 4, "toFloorId": 2, "avgTime": 40 }
  ],
  "steps": [
    {
      "order": 1,
      "instruction": "Đi thẳng khoảng 20m",
      "distance": 20.0,
      "duration": 25.0,
      "floorId": 4,
      "maneuver": "DEPART",
      "geometry": {
        "type": "Feature",
        "geometry": { "type": "LineString", "coordinates": [[106.6980,10.7720], [106.6981,10.7721]] },
        "properties": {}
      }
    },
    {
      "order": 2,
      "instruction": "Rẽ trái và đi thẳng khoảng 5m",
      "distance": 5.0,
      "duration": 6.0,
      "floorId": 4,
      "maneuver": "LEFT",
      "geometry": {
        "type": "Feature",
        "geometry": { "type": "LineString", "coordinates": [[106.6981,10.7721], [106.6981,10.7723]] },
        "properties": {}
      }
    },
    {
      "order": 3,
      "instruction": "Sử dụng thang máy chuyển sang B2 - Sân ga",
      "distance": 0.0,
      "duration": 40.0,
      "floorId": 4,
      "maneuver": "ELEVATOR",
      "geometry": null
    },
    {
      "order": 4,
      "instruction": "Đi thẳng khoảng 15m",
      "distance": 15.0,
      "duration": 18.0,
      "floorId": 2,
      "maneuver": "DEPART",
      "geometry": {
        "type": "Feature",
        "geometry": { "type": "LineString", "coordinates": [[106.6981,10.7723], [106.6983,10.7725]] },
        "properties": {}
      }
    }
  ]
}
```
| Trường response | Ứng với FR |
|---|---|
| `geometry` (WGS84) | FR-08 — vẽ tuyến đường lên bản đồ. Là LineString **gộp toàn tuyến**; muốn vẽ theo từng tầng thì dùng `steps[].geometry` |
| `steps` | FR-09 — hướng dẫn từng bước |
| `transferPoints` | FR-10 — cảnh báo điểm chuyển tầng |
| `totalDistance` (mét), `totalTimeEstimate` (giây) | FR-11 |

**Trường của mỗi phần tử `steps[]`:**

| Trường | Kiểu | Ghi chú |
|---|---|---|
| `order` | int | Thứ tự bước, bắt đầu từ 1 |
| `instruction` | string | Câu hướng dẫn tiếng Việt, sinh theo `maneuver` |
| `distance` | double | Mét — `edge.cost_distance`. Bước chuyển tầng = 0 |
| `duration` | double | Giây — `edge.cost_time` |
| `floorId` | int | Tầng đang đi **trong bước này** (không phải tầng đích). Với bước chuyển tầng, đây là tầng xuất phát — người dùng còn phải đi trên tầng đó mới tới được thang máy/cầu thang |
| `maneuver` | string | `DEPART` \| `STRAIGHT` \| `SLIGHT_LEFT` \| `SLIGHT_RIGHT` \| `LEFT` \| `RIGHT` \| `U_TURN` \| `ELEVATOR` \| `ESCALATOR` \| `STAIR`. Ngưỡng phân loại góc: `\|delta\| < 20°` → thẳng · `20–45°` → chếch · `45–135°` → rẽ · `> 135°` → quay đầu (delta dương = rẽ phải). Frontend có bản fallback tự tính trong `frontend/src/utils/routeGuidance.js` — **sửa ngưỡng bên nào thì sửa cả hai** |
| `geometry` | object \| null | LineString WGS84 của **riêng bước này**. `null` với bước chuyển tầng (`ELEVATOR`/`ESCALATOR`/`STAIR`) vì trigger DB không sinh `geom_wgs84` cho các edge này — bản đồ 2D từng tầng không vẽ được đường xuyên tầng |

**Lỗi:**
- `400 Bad Request` — thiếu `startNodeId`/`endNodeId`, hoặc trùng nhau.
- `404 Not Found` — `{ "error": "ROUTE_NOT_FOUND", "message": "Không tìm thấy tuyến đường phù hợp giữa hai điểm" }`.

---

## D. NHÓM API QUẢN TRỊ (FR-12 → FR-17)

> Yêu cầu header `Authorization: Bearer <token>`, trả `401 Unauthorized` nếu thiếu/sai token (NFR-11, NFR-12).

### D.1. Đăng nhập quản trị

| | |
|---|---|
| **FR liên quan** | FR-12 |
| **Method / Endpoint** | `POST /api/auth/login` |

**Request:**
```json
{ "username": "admin", "password": "••••••••" }
```

**Response `200 OK`:**
```json
{ "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...", "expiresIn": 3600 }
```
**Lỗi:** `401 Unauthorized`.

### D.2. Quản lý Node

| FR | Method | Endpoint | Mô tả |
|---|---|---|---|
| FR-13 | `GET` | `/api/admin/nodes` | Danh sách node (phân trang, lọc theo `floorId`) |
| FR-13 | `GET` | `/api/admin/nodes/{id}` | Chi tiết 1 node |
| FR-13 | `POST` | `/api/admin/nodes` | Tạo node mới |
| FR-13 | `PUT` | `/api/admin/nodes/{id}` | Cập nhật node |
| FR-13 | `DELETE` | `/api/admin/nodes/{id}` | Xóa node |

**Request body (POST/PUT) — chỉ cần gửi 1 trong 2 cách nhập tọa độ:**
```json
{
  "localCoordinates": { "x": 12.4, "y": 8.1 },
  "type": "stair",
  "floorId": 3
}
```
hoặc:
```json
{
  "geometry": { "type": "Point", "coordinates": [106.6980, 10.7720] },
  "type": "stair",
  "floorId": 3
}
```

**Response `201 Created` / `200 OK`:**
```json
{
  "id": 34,
  "geometry": { "type": "Point", "coordinates": [106.6980, 10.7720] },
  "localCoordinates": { "x": 12.4, "y": 8.1 },
  "type": "stair",
  "floorId": 3
}
```

**Lỗi:**
- `400 Bad Request` — thiếu cả `localCoordinates` lẫn `geometry`, hoặc `floorId` không tồn tại.
- `409 Conflict` (DELETE) — `{ "error": "NODE_IN_USE", "message": "Không thể xóa node vì đang được tham chiếu bởi Edge" }`.

### D.3. Quản lý Edge và trọng số

| FR | Method | Endpoint | Mô tả |
|---|---|---|---|
| FR-14 | `GET` | `/api/admin/edges` | Danh sách edge (phân trang, lọc theo `floorId`) |
| FR-14 | `POST` | `/api/admin/edges` | Tạo edge mới |
| FR-14 | `PUT` | `/api/admin/edges/{id}` | Cập nhật edge |
| FR-14 | `DELETE` | `/api/admin/edges/{id}` | Xóa edge |

**Request body (POST/PUT):**
```json
{
  "source": 12,
  "target": 15,
  "edgeType": "corridor",
  "costOverride": null
}
```
| Trường | Ghi chú |
|---|---|
| `source`, `target` | id của Node (đã có `localCoordinates`) |
| `edgeType` | `"corridor"` \| `"stair"` \| `"elevator"` \| `"escalator"` |
| `costOverride` | Để `null` → Backend tự tính `cost` bằng khoảng cách Euclidean giữa `localCoordinates` của `source`/`target` (mét); truyền số cụ thể để ghi đè (ví dụ `elevator`/`escalator` nên dùng thời gian ước tính thay vì khoảng cách vật lý) |

**Response `201 Created`:**
```json
{
  "id": 34, "source": 12, "target": 15,
  "geometry": { "type": "LineString", "coordinates": [[106.6980,10.7720],[106.6982,10.7721]] },
  "cost": 8.2, "edgeType": "corridor"
}
```
**Lỗi:** `400 Bad Request` nếu `source`/`target` không tồn tại (đảm bảo NFR-07 — toàn vẹn dữ liệu).

### D.4. Quản lý Room

| FR | Method | Endpoint | Mô tả |
|---|---|---|---|
| FR-15 | `GET` | `/api/admin/rooms` | Danh sách room |
| FR-15 | `POST` | `/api/admin/rooms` | Tạo room mới |
| FR-15 | `PUT` | `/api/admin/rooms/{id}` | Cập nhật room |
| FR-15 | `DELETE` | `/api/admin/rooms/{id}` | Xóa room |

**Request body (POST/PUT):**
```json
{
  "name": "Phòng vé số 2",
  "geometry": { "type": "Polygon", "coordinates": [["..."]] },
  "floorId": 4,
  "category": "ticket_office",
  "nodeId": 20
}
```

### D.5. Nhập/Xuất dữ liệu GeoJSON

| | |
|---|---|
| **FR liên quan** | FR-16 |
| **Method / Endpoint** | `POST /api/admin/import` |
| **Request** | `multipart/form-data`: `file` (.geojson, WGS84), `layer` (`"nodes"` \| `"edges"` \| `"rooms"`), `floorId` |
| **Xử lý** | Layer `nodes`: tự tính `localCoordinates` từ `geometry`. Layer `edges`: tự tính `cost` từ độ dài LineString quy đổi ra mét |

**Response `200 OK`:**
```json
{ "imported": 45, "skipped": 2, "errors": [ { "row": 12, "reason": "Thiếu trường floorId" } ] }
```

| | |
|---|---|
| **Method / Endpoint** | `GET /api/admin/export?layer=nodes&floorId=3` |
| **Response** | File GeoJSON WGS84 (Content-Type: `application/geo+json`) |

### D.6. Kiểm tra tính liên thông của đồ thị

| | |
|---|---|
| **FR liên quan** | FR-17 |
| **Method / Endpoint** | `GET /api/admin/graph/validate` |
| **Query params** | `floorId` (tùy chọn) |

**Response `200 OK`:**
```json
{
  "isFullyConnected": false,
  "isolatedNodes": [ { "nodeId": 77, "floorId": 3, "reason": "Không có Edge nào tham chiếu đến node này" } ]
}
```

### D.7. Cấu hình phép biến đổi tọa độ theo tầng

| | |
|---|---|
| **Method / Endpoint** | `GET /api/admin/floors/{floorId}/transform`, `PUT /api/admin/floors/{floorId}/transform` |
| **Mô tả** | Xem/cập nhật bộ tham số Affine chuyển đổi giữa tọa độ cục bộ (mét) và WGS84 — cần thiết lập trước khi số hóa Node/Edge của tầng đó |

**Request body (PUT):**
```json
{
  "originLat": 10.7720, "originLng": 106.6980,
  "scaleX": 1.0, "scaleY": 1.0, "rotationDeg": 0.0
}
```
**Response `200 OK`:** trả lại object vừa lưu.
**Lỗi:** `400 Bad Request` nếu thiếu tham số bắt buộc.

---

## E. BẢNG TỔNG HỢP MÃ LỖI DÙNG CHUNG

| HTTP Status | Mã lỗi (`error`) | Ý nghĩa |
|---|---|---|
| 400 | `INVALID_REQUEST` | Thiếu tham số bắt buộc hoặc sai định dạng |
| 401 | `UNAUTHORIZED` | Chưa đăng nhập hoặc token không hợp lệ (nhóm D) |
| 404 | `NOT_FOUND` | Không tìm thấy tài nguyên (floor/node/room) |
| 404 | `ROUTE_NOT_FOUND` | Không tìm thấy tuyến đường giữa 2 điểm (FR-06) |
| 404 | `NO_NEARBY_NODE` | Không có node hợp lệ gần điểm người dùng chọn (FR-04/05) |
| 409 | `NODE_IN_USE` | Không thể xóa Node đang được Edge tham chiếu (FR-13) |
| 500 | `INTERNAL_ERROR` | Lỗi hệ thống không xác định |

**Định dạng lỗi chuẩn dùng chung:**
```json
{ "error": "ROUTE_NOT_FOUND", "message": "Không tìm thấy tuyến đường phù hợp giữa hai điểm" }
```

---

## F. BẢNG ÁNH XẠ FR ↔ API

| FR | API tương ứng |
|---|---|
| FR-01 | `GET /api/floors/{floorId}/map` |
| FR-02 | `GET /api/floors`, `GET /api/floors/{floorId}/map` |
| FR-03 | `GET /api/rooms/search` |
| FR-04 | `GET /api/nodes/nearest` |
| FR-05 | `GET /api/nodes/nearest`, `GET /api/rooms/search` |
| FR-06 | `POST /api/route` (Dijkstra) |
| FR-07 | `POST /api/route` (tham số `criteria`) |
| FR-08 | `POST /api/route` (trường `geometry`) |
| FR-09 | `POST /api/route` (trường `steps`) |
| FR-10 | `POST /api/route` (trường `transferPoints`) |
| FR-11 | `POST /api/route` (trường `totalDistance`, `totalTimeEstimate`) |
| FR-12 | `POST /api/auth/login` |
| FR-13 | `/api/admin/nodes` (GET/POST/PUT/DELETE) |
| FR-14 | `/api/admin/edges` (GET/POST/PUT/DELETE) |
| FR-15 | `/api/admin/rooms` (GET/POST/PUT/DELETE) |
| FR-16 | `POST /api/admin/import`, `GET /api/admin/export` |
| FR-17 | `GET /api/admin/graph/validate` |
| *(hỗ trợ)* | `/api/admin/floors/{floorId}/transform` |
