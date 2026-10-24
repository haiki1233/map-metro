# BaseTech — Công nghệ nền cho hệ thống tìm đường nội khu

> Nguồn: `BaseTech_IndoorNavigation.docx` (chuyển sang Markdown để version-control được).

## 1. Cách GIS lưu trữ và hiển thị đối tượng (2D)

Dữ liệu GIS biểu diễn thế giới thực qua 3 dạng hình học (Vector Geometry):

- **Point (Điểm)**: cổng, ATM, vòi nước, lối vào tòa nhà, quầy vé...
- **Line / LineString (Đường)**: mạng lưới đường đi bộ, hành lang, đường nội bộ.
- **Polygon (Đa giác)**: ranh giới tòa nhà, phòng, sân ga, bãi xe...

Mỗi đối tượng Vector gắn liền với **Thuộc tính (Attributes)** lưu trong CSDL (`name`, `type`, `category`...). Map Renderer (Leaflet/MapLibre) nhận tọa độ + thuộc tính rồi vẽ đường, tô polygon, gắn nhãn theo thời gian thực khi zoom/pan.

## 2. Quy trình dựng bản đồ (trường hợp ngoài trời, có ảnh vệ tinh)

1. **Base map**: ảnh vệ tinh/flycam độ phân giải cao, georeference vào WGS84 bằng QGIS.
2. **Số hóa (vectorization)**: vẽ polygon (tòa nhà, bãi xe), vẽ mạng lưới đường (LineString, các giao lộ phải cắt đúng 1 điểm để thuật toán hiểu là có thể rẽ), đánh dấu POI.
3. **Đóng gói**: xuất GeoJSON (đơn giản, phổ biến) hoặc Vector Tiles/MBTiles (tối ưu hiệu năng).

## 3. Ba nhóm dữ liệu cần thu thập

| Nhóm | Thành phần | Mục đích |
|---|---|---|
| Dữ liệu không gian | Ranh giới building/lối đi/bãi xe, mạng lưới Node & Edge | Vẽ 2D + tính route |
| Dữ liệu đồ thị định tuyến | Chiều lưu thông, phân loại đường, trọng số (khoảng cách/thời gian) | Chạy Dijkstra/A* |
| Dữ liệu thuộc tính & tìm kiếm | Tên phòng/mã phòng, mô tả, giờ mở cửa | Search bar, popup thông tin |

## 4. Tech stack đề xuất (miễn phí / mã nguồn mở)

- **Biên tập bản đồ**: QGIS, hoặc OpenStreetMap + JOSM.
- **Hiển thị**: MapLibre GL JS / Mapbox GL (vector mượt, xoay/nghiêng) hoặc Leaflet (nhẹ, đơn giản, đủ cho bản đồ 2D theo tầng).
- **Routing engine**: Turf.js (tính toán hình học phía client), **pgRouting** (đồ thị phức tạp trên PostgreSQL/PostGIS — lựa chọn của dự án này), OSRM/GraphHopper (server routing chuyên dụng, không cần cho phạm vi 1 ga).

## 5. Trường hợp KHÔNG có ảnh vệ tinh — dùng CAD (áp dụng cho dự án này)

Ảnh vệ tinh chỉ thấy mái nhà, không xuyên được sàn để thấy phòng/hành lang/cầu thang. Với indoor navigation trong 1 tòa nhà, **bản vẽ CAD (.dwg/.dxf) là nguồn chuẩn xác nhất**. Quy trình chuyển đổi CAD → bản đồ tìm đường:

1. **Làm sạch CAD (CAD Cleanup)**: mở trong AutoCAD/QGIS, ẩn/xóa layer thừa (điện, nước, kết cấu chi tiết thi công...). Chỉ giữ: ranh giới tường, cửa ra vào, cầu thang, thang máy, phân chia phòng.
2. **Georeferencing**: CAD gốc dùng hệ tọa độ tương đối (mét, gốc 0,0). Cần ghim ít nhất 2–3 điểm góc tòa nhà trùng tọa độ GPS thực tế (WGS84) → đây chính là bộ tham số Affine (`originLat/Lng, scaleX/Y, rotationDeg`) lưu trong bảng `floor_transform` của schema dự án.
3. **Convert DWG → GeoJSON/Shapefile** (QGIS/ArcGIS):
   - Phòng/khu vực → Polygon (`room`, thuộc tính tên/tầng).
   - Hành lang → LineString (`edge`, dùng dựng đồ thị).
   - Thang máy/cầu thang → Point nối giữa các tầng (`node` với `vertical_link_id`).
4. **Dựng đồ thị nội bộ (Indoor Graph)**: vẽ tuyến trung tâm dọc hành lang, nối vào cửa từng phòng — đây là input cho Dijkstra/A*.

## 6. Thách thức: định vị người dùng trong nhà (Indoor Positioning)

GPS lệch 10–20m hoặc mất tín hiệu trong nhà bê tông cốt thép. Giải pháp thay thế (ngoài phạm vi MVP hiện tại, ghi nhận cho roadmap dài hạn):

- **BLE Beacons**: định vị theo cường độ tín hiệu Bluetooth từ các beacon lắp quanh hành lang.
- **Wi-Fi Fingerprinting**: đo cường độ tín hiệu Wi-Fi có sẵn.
- **PDR (Pedestrian Dead Reckoning)**: dùng gyroscope + accelerometer điện thoại để đếm bước và hướng đi.

## 7. Chuẩn dữ liệu quốc tế tham khảo

**IMDF (Indoor Mapping Data Format)** — do Apple đề xuất, cấu trúc GeoJSON chuẩn cho bản đồ trong nhà (building, floor, space (venue), footway/edge, opening). Không bắt buộc cho MVP nhưng nên tham khảo khi thiết kế thuộc tính GeoJSON để dễ tương thích/migrate về sau.
