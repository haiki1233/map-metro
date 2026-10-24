# Ghi chú review — Cần sửa / cần cải thiện

> Đánh giá nhanh sau khi scaffold xong repo (backend Spring Boot, frontend React/Vite/Leaflet, database PostGIS/pgRouting). Xếp theo độ ưu tiên. Cập nhật sau lần build + chạy thật đầu tiên (xem mục "Đã verify thật" bên dưới).

## 🔴 BLOCKER đang chờ xử lý (2026-09-15): thiếu file mặt bằng gốc CAD

Convert 22 file DWG (11 ga) sang DXF bằng ODA File Converter rồi đọc trực tiếp bằng Python (`ezdxf`) phát hiện: file `..._ROOM NAME_GROUND FLOOR.dwg` của **10/11 ga** chỉ chứa text nhãn tên phòng, **không có tường/phòng/hành lang** — file mặt bằng gốc thật (`<mã ga>_X_PLAN_GF.dwg`, được tham chiếu dạng XREF) **không có trong bộ dữ liệu đã nhận**. Chi tiết + danh sách 10 file cần xin lại: xem `gis-pipeline/README.md` mục "BLOCKER đã phát hiện".

**Trạng thái**: đang chờ người dùng liên hệ đơn vị cung cấp CAD xin lại 10 file này. Việc số hóa 11 ga tạm dừng cho tới khi có file. `data/raw_cad/*.PARKING SPACE.dwg` (bãi xe, đầy đủ dữ liệu thật) và `data/processed/` (đã convert sang DXF) không bị ảnh hưởng, có thể dùng ngay nếu muốn thử pipeline trước với dữ liệu ngoài trời.

## Đã verify thật (build + chạy thật, không chỉ đọc code)

Đã cài Java 17 + Maven, dựng DB qua Docker, build và chạy Backend thật với dữ liệu seed, gọi thử toàn bộ 4 nhóm API (bao gồm cả các case lỗi 400/401/404/409). Phát hiện và sửa 2 lỗi thật trong lần chạy đầu tiên:

1. **`pom.xml` dùng sai thư viện GeoJSON**: `com.bedatadriven:jackson-datatype-jts` chỉ hỗ trợ JTS cũ (`com.vividsolutions.jts`), không tương thích với `org.locationtech.jts` mà toàn bộ entity dùng — version `2.14` khai báo ban đầu còn không tồn tại trên Maven Central (bịa số). Đã đổi sang `org.n52.jackson:jackson-datatype-jts:2.0.0` (đúng hỗ trợ `org.locationtech.jts`) và build/chạy thành công.
2. **`docker-compose.yml` dùng image `postgis/postgis` thiếu pgRouting** — `schema.sql` cần cả 2 extension, `CREATE EXTENSION pgrouting` báo lỗi "not available". Đã đổi sang image chính thức `pgrouting/pgrouting:16-3.5-4.0.1` (có sẵn cả PostGIS). Đồng thời đổi cổng host từ `5432` sang `5433` vì máy đã có sẵn 1 Postgres khác chiếm cổng 5432.

Sau khi sửa, đã verify **khớp chính xác** với số liệu trong `mockData.js` gốc: `pgr_dijkstra` từ node 1→10 cho `agg_cost = 70` (khớp `mockRouteResponse`), tạo node mới qua Admin API cho toạ độ WGS84 `[106.698228606, 106.772044966]` (khớp từng chữ số với `mockAdminNodeCreated`), case lỗi `ROUTE_NOT_FOUND`/`NODE_IN_USE`/`INVALID_REQUEST` đều đúng định dạng.

**Lưu ý**: `mockData.js` gốc có 1-2 chỗ số liệu `totalTimeEstimate` không khớp phép tính thật (ví dụ 91.7 vs số thật tính được ~79), nhiều khả năng là sai số/gõ nhầm khi soạn tài liệu — số liệu tính ra từ DB thật (qua code hiện tại) mới là nguồn đáng tin, không cần ép khớp 100% theo mock cũ.

**Lỗi thật thứ 3 phát hiện khi chạy Frontend thật trong trình duyệt (không phải qua curl)**: Backend chưa cấu hình CORS — `localhost:5173` gọi `localhost:8080` bị trình duyệt chặn (curl không thấy vì CORS chỉ enforce ở client), khiến bản đồ hiện trắng trơn không có tầng nào. Đã thêm `CorsConfigurationSource` vào `SecurityConfig` (origin cấu hình qua `CORS_ALLOWED_ORIGINS`, mặc định `http://localhost:5173`) — đã verify lại header `Access-Control-Allow-Origin` trả đúng và map chạy được trên trình duyệt thật.

## Ưu tiên cao — nên làm trước khi code tiếp

1. **`AdminEdgeService.update()` xóa-rồi-tạo-lại edge** → sinh id mới mỗi lần sửa. Cách này tránh phải chép logic trigger sang Java, nhưng phá vỡ kỳ vọng REST thông thường (PUT giữ nguyên id). Nên bàn lại: thêm trigger `BEFORE UPDATE` vào `schema.sql`, hay chấp nhận đánh đổi này.
2. **Chưa có test nào** (unit lẫn integration) cho cả BE/FE — dù đã verify thủ công bằng curl, chưa có test tự động để giữ đúng khi sửa code sau này.

## Ưu tiên trung bình — ảnh hưởng UX/vận hành

1. **Hướng dẫn từng bước (`RouteResponse.steps`) còn thô** — hiện là 1 câu/1 edge, chưa gộp các đoạn hành lang liên tiếp cùng hướng thành 1 câu tự nhiên như `mockData.js` từng làm mẫu.
2. **Frontend chưa có trang Admin** — backend đã đủ API nhóm D (login, CRUD node/edge/room, import/export, validate graph) nhưng chưa có UI nào dùng tới; hiện chỉ có màn hình người dùng cuối.
3. **Frontend chưa responsive mobile** — sidebar cố định 320px, trong khi ứng dụng định vị GPS thực tế sẽ dùng trên điện thoại là chính.
4. **`ImportExportService` cho layer `edges`** đang giả định GeoJSON đã có sẵn `source`/`target` id — chưa tự động "snap" toạ độ LineString vào node gần nhất. Cần thống nhất với người làm số hóa CAD xem việc này làm ở QGIS hay ở Backend.
5. **Chưa có Admin API cho chính bảng `floor`** (chỉ có GET công khai ở nhóm A) — khi thử nghiệm pilot bãi xe Văn Thánh (xem `gis-pipeline/README.md`) phải insert floor mới bằng tay qua `psql` (`gis-pipeline/scripts/setup_pilot_floor.sql`) vì không có `POST /api/admin/floors`. Cần bổ sung nếu muốn quản lý floor hoàn toàn qua API thay vì SQL tay.

## Ưu tiên thấp hơn nhưng nên biết

1. **Chưa có bảng `station`** — cần trước khi nhập dữ liệu 11 ga thật (đã ghi trong `docs/ARCHITECTURE.md`, chưa làm).
2. Quản lý schema đang chạy tay qua `schema.sql`/`seed_data.sql`, chưa có Flyway — dễ lệch giữa các môi trường khi nhóm đông người.
3. `GlobalExceptionHandler` bắt `Exception` chung trả 500 nhưng chưa log lỗi — khó debug khi chạy thật.
4. Icon Leaflet trong `MapView.jsx` đang load từ CDN `unpkg.com` — nên bundle local để không phụ thuộc mạng ngoài.

## Đề xuất bước tiếp theo

Nền tảng (schema + backend + frontend) đã chạy được thật. Số hóa CAD (giai đoạn 2 trong `docs/ROADMAP.md`) đang **tạm dừng chờ file mặt bằng gốc** (xem BLOCKER ở đầu file). Trong lúc chờ, nên ưu tiên: (1) viết test tự động cho các luồng chính (routing, admin CRUD), hoặc (2) thử pipeline CAD→GeoJSON→DB trước với dữ liệu bãi xe (`PARKING SPACE.dwg`, đã có sẵn và đầy đủ) để không phải chờ không.
