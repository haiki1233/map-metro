# Kiến trúc hệ thống — Indoor Navigation Metro

## 1. Đánh giá 3 file tham khảo (đã đi đúng hướng)

| File | Vai trò | Nhận xét |
|---|---|---|
| `schema.sql` | Thiết kế CSDL PostGIS + pgRouting | Đúng chuẩn: tách 2 hệ tọa độ (local mét cho routing, WGS84 cho API), trigger tự sinh `geom_wgs84`/`cost`, 3 cột cost riêng cho 3 tiêu chí (distance/time/least_stairs) tránh phải đổi thuật toán. Đây là phần **chín muồi nhất** trong bộ tài liệu — có thể dùng gần như nguyên trạng. |
| `DacTa_RESTAPI.md` | Đặc tả REST API | Khớp 100% với schema, phân nhóm rõ theo FR (A. Bản đồ, B. Tìm kiếm, C. Định tuyến, D. Quản trị), có bảng mã lỗi chuẩn dùng chung. Đủ chi tiết để code Backend mà không cần đoán. |
| `mockData.js` | Mock FE | Điểm mạnh nhất: số liệu không bịa mà lấy từ **test thật** trên schema+seed, nên FE/BE làm song song vẫn khớp nhau khi tích hợp. Đã bao phủ đủ 4 nhóm API kể cả các case lỗi (404/409/400). |

**Kết luận:** hướng đi hiện tại (PostGIS/pgRouting cho routing engine, tách local/WGS84 bằng Affine transform theo từng tầng, REST API monolith có JWT cho phần quản trị) là một kiến trúc chuẩn, phổ biến trong ngành cho quy mô 1 ga/1 tòa nhà. Không cần đổi hướng, chỉ cần bổ sung phần còn thiếu (xem mục 3).

## 2. Đặc thù dữ liệu thật (khác với dữ liệu demo trong mockData.js)

Thư mục `data/raw_cad/` chứa CAD của **11 ga trên tuyến Metro Số 1** (Văn Thánh Park → Suối Tiên Terminal), mỗi ga có:
- 1 file `..._ROOM NAME_GROUND FLOOR.dwg` — mặt bằng tầng trệt, tên phòng/khu chức năng.
- 1 file `..._PARKING SPACE.dwg` — bãi xe.
- Riêng ga Suối Tiên Terminal có thêm `BASE_PL.dwg` và `GROUND MASTER PLAN.dwg` (ga cuối, quy mô lớn hơn — depot/terminal).

**Khác biệt so với ví dụ demo (B1 sảnh chính / B2 sân ga) trong mockData.js:**
- Đây là các ga **trên cao** của tuyến Metro số 1 (không phải ga ngầm nhiều tầng dưới lòng đất) → hiện chỉ có dữ liệu **1 tầng trệt** (ground floor) + bãi xe cho mỗi ga, KHÔNG có sẵn dữ liệu multi-floor (B1/B2) như ví dụ.
- Schema hiện tại **chưa có bảng `station`/`building`** ở trên `floor` — nếu mở rộng sang nhiều ga, cần thêm 1 bảng `station (id, name, code)` và `floor.station_id` để phân biệt ga nào là ga nào (tránh lẫn dữ liệu 11 ga vào chung 1 danh sách `floor`).
- Chưa có toạ độ WGS84 thật cho từng ga (input georeferencing) — cần lấy tọa độ tim ga thực tế (Google Maps/khảo sát) để làm điểm ghim khi chuyển CAD → GeoJSON.

## 3. Việc còn thiếu / cần làm rõ trước khi code Backend

1. **Bảng `station`** — bổ sung vào schema (xem `database/schema.sql`, đã giữ nguyên bản gốc; phần mở rộng multi-station sẽ làm ở migration riêng khi bắt đầu số hóa ga đầu tiên, tránh sửa schema đang hoạt động tốt cho case 1 tầng).
2. **`seed_data.sql` gốc không có trong bộ bàn giao** — đã tái tạo lại (`database/seed/seed_data.sql`) từ đúng số liệu trong `mockData.js`, verify khớp tọa độ local/WGS84 và cost. Dùng file này để chạy thử BE/FE trước khi có dữ liệu CAD thật.
3. **File `PhanChiaTask_BE_FE.md`** được `mockData.js` nhắc tới nhưng không có trong bộ 3 file gửi — nếu có, nên bổ sung vào `docs/` để đối chiếu phân công.
4. **CAD → GeoJSON**: chưa có bước số hóa nào được thực hiện, đây là phần tốn thời gian nhất của dự án (xem `gis-pipeline/README.md` và `docs/ROADMAP.md`).

## 4. Tech stack lựa chọn cho khung repo này

| Thành phần | Lựa chọn | Vì sao |
|---|---|---|
| Backend | **Java 21 + Spring Boot 3 (Maven)** | Phiên bản Java runtime đồng bộ giữa Maven và Docker. |
| CSDL | **PostgreSQL 16 + PostGIS 3.4 + pgRouting** | Đã cố định trong `schema.sql`, không đổi. |
| ORM/Query | Spring Data JPA (entity CRUD) + `JdbcTemplate`/native query cho các hàm PostGIS/pgRouting (`fn_find_route`, `ST_ClosestPoint`, `ST_DWithin`...) vì JPA không diễn đạt tốt các hàm không gian. |
| Auth | Spring Security + JWT (HS256), chỉ áp cho nhóm `D. /api/admin/**` và `/api/auth/**`. |
| Frontend | **React 18 + Vite + Leaflet** | BaseTech doc đề xuất Leaflet cho bản đồ 2D theo tầng (nhẹ, đủ dùng, không cần nghiêng/xoay 3D như MapLibre) — hợp lý cho 1 ga. |
| GIS pipeline | **QGIS** (làm sạch CAD, georeferencing, xuất GeoJSON) + script Python hỗ trợ (kiểm tra topology, sinh SQL INSERT từ GeoJSON). |
| Hạ tầng dev | `docker-compose.yml` chạy PostGIS + (tùy chọn) backend/frontend, để onboard nhanh không cần cài Postgres tay. |

## 5. Sơ đồ luồng dữ liệu

```
data/raw_cad/*.dwg
      │  (QGIS: cleanup layer, georeference bằng 2-3 điểm mốc WGS84)
      ▼
data/processed/<station>/<floor>.geojson  (nodes / edges / rooms)
      │  (script import: gis-pipeline/scripts/, hoặc Admin API D.5 import)
      ▼
PostgreSQL (bảng node/edge/room + trigger tự tính geom_wgs84/cost)
      │  (pgr_dijkstra qua fn_find_route)
      ▼
Backend Spring Boot (REST API theo docs/RESTAPI_Spec.md)
      │  (JSON/GeoJSON qua HTTPS)
      ▼
Frontend React + Leaflet (vẽ bản đồ theo tầng, tìm kiếm, chỉ đường, GPS snap-to-node)
```
