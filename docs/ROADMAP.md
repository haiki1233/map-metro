# Roadmap — Từng bước triển khai

Thứ tự dưới đây ưu tiên **bỏ chặn (unblock) làm song song sớm nhất**: BE và FE có thể bắt đầu ngay bằng `seed_data.sql`/`mockData.js` mà không cần chờ dữ liệu CAD số hóa xong — vốn là việc tốn thời gian nhất.

## Giai đoạn 0 — Khung dự án (đã xong trong lần scaffold này)
- [x] Cấu trúc repo chuẩn (backend / frontend / database / gis-pipeline / docs / data).
- [x] `database/schema.sql` + `database/seed/seed_data.sql` (dữ liệu demo, verify khớp mockData.js).
- [x] Skeleton Spring Boot (entity/repository/controller theo đúng `docs/RESTAPI_Spec.md`).
- [x] Skeleton React + Vite + Leaflet, dùng `mockData.js` làm nguồn dữ liệu tạm.
- [x] `docker-compose.yml` cho PostGIS local.

## Giai đoạn 1 — Chạy được end-to-end trên dữ liệu demo (1–2 tuần)
1. `docker compose up -d db` → load `schema.sql` rồi `seed_data.sql`.
2. Hoàn thiện Backend nhóm A/B/C (bản đồ, tìm kiếm, định tuyến) — đây là nhóm **không cần login**, ưu tiên làm trước vì FE cần ngay.
3. Nối Frontend vào API thật (bỏ `mock/mockData.js`, chuyển sang gọi `VITE_API_BASE_URL`), giữ cấu trúc response giống hệt để không phải sửa component.
4. Viết test tích hợp so khớp kết quả `fn_find_route` với số liệu đã "test thật" ghi trong `mockData.js` (agg_cost=70 cho distance 1→10, ~79.17 cho time 1→9).
5. Hoàn thiện nhóm D (quản trị: JWT login, CRUD node/edge/room, import/export GeoJSON, graph validate).

**Tiêu chí xong giai đoạn 1:** người dùng chọn ga demo, bấm 1 điểm bất kỳ trên bản đồ B1, chọn điểm đến ở B2, thấy tuyến đường vẽ trên Leaflet kèm hướng dẫn từng bước và cảnh báo thang máy — toàn bộ chạy trên dữ liệu seed, chưa cần CAD thật.

## Giai đoạn 2 — Số hóa dữ liệu thật từ CAD (song song với giai đoạn 1, tốn thời gian nhất)
1. Chọn **1 ga thí điểm** trước (đề xuất: ga có CAD đơn giản nhất, ví dụ Văn Thánh Park hoặc Thảo Điền) để làm end-to-end 1 lần trước khi nhân rộng ra 11 ga.
2. Mở `.dwg` trong AutoCAD/QGIS, làm sạch layer (xem `gis-pipeline/README.md`).
3. Lấy tọa độ GPS thực tế của 2–3 điểm góc ga (Google Maps hoặc khảo sát) → georeference.
4. Xuất GeoJSON 3 layer: `rooms` (polygon), `corridor edges` (linestring dọc hành lang + tim đường), `nodes` (giao lộ/cửa/thang).
5. Import vào DB qua API `POST /api/admin/import` (nhóm D.5) hoặc script `gis-pipeline/scripts/`.
6. Chạy `GET /api/admin/graph/validate` — đảm bảo đồ thị liên thông (không có node cô lập) trước khi công bố ga đó.
7. Lặp lại bước 2–6 cho 10 ga còn lại. **Quyết định cần chốt trước khi lặp:** có thêm bảng `station` để phân nhóm floor theo từng ga hay không (xem `docs/ARCHITECTURE.md` mục 2) — nên chốt ngay sau ga thí điểm đầu tiên, tránh phải migrate lại dữ liệu đã nhập.

## Giai đoạn 3 — Định vị người dùng (Indoor Positioning)
- MVP: người dùng tự chọn vị trí xuất phát trên bản đồ (snap vào node gần nhất qua `GET /api/nodes/nearest`) — **không cần phần cứng thêm**, đã đủ cho luồng "biết vị trí GPS rồi chỉ đường nội khu".
- Nếu ga trên cao (ngoài trời/bán ngoài trời như các ga Metro số 1) → GPS thường vẫn bắt được tín hiệu tốt hơn ga ngầm, có thể dùng trực tiếp GPS của điện thoại snap vào node gần nhất mà chưa cần BLE Beacon/Wi-Fi Fingerprinting ngay.
- Beacon/PDR chỉ cân nhắc ở các khu vực GPS yếu thật sự (tầng hầm, khu để xe kín) — để dành cho giai đoạn sau khi đã có người dùng thật đánh giá độ chính xác GPS.

## Giai đoạn 4 — Hoàn thiện & vận hành
- Xuất bản Vector Tiles/MBTiles nếu số lượng ga lớn khiến GeoJSON tải chậm (chưa cần ở quy mô hiện tại — 1 ga vài chục node/edge).
- CI/CD, migration tool (Flyway) thay vì chạy tay `schema.sql`.
- Theo dõi lỗi 404 `ROUTE_NOT_FOUND` thực tế (đồ thị bị đứt do quên nối edge khi số hóa) — dùng `graph/validate` định kỳ.
