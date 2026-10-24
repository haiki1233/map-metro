# Indoor Navigation — Metro Line 1 (HCMC)

Ứng dụng tìm đường nội khu ga Metro: người dùng biết vị trí GPS hiện tại (hoặc chọn điểm trên bản đồ), hệ thống chỉ đường ngắn nhất / nhanh nhất / ít cầu thang nhất tới điểm đến trong ga (qua sảnh, cầu thang, thang máy, sân ga) bằng thuật toán Dijkstra (pgRouting) trên nền PostGIS.

## Mục lục

- [Kiến trúc](#kiến-trúc)
- [Cấu trúc repo](#cấu-trúc-repo)
- [Cách chạy dự án](#cách-chạy-dự-án)
- [REST API](#rest-api)
- [Trạng thái hiện tại](#trạng-thái-hiện-tại)
- [Tài liệu chi tiết](#tài-liệu-chi-tiết)

## Kiến trúc

### Tech stack

| Thành phần | Lựa chọn | Vì sao |
|---|---|---|
| Backend | Java 21 + Spring Boot 3 (Maven) | Runtime Docker đồng bộ với `java.version` trong Maven. |
| CSDL | PostgreSQL 16 + PostGIS 3.4 + pgRouting | Lưu Node/Edge/Room dạng hình học, chạy `pgr_dijkstra` trực tiếp trong CSDL. |
| ORM/Query | Spring Data JPA (CRUD) + native query cho hàm không gian (`fn_find_route`, `ST_ClosestPoint`, `ST_DWithin`...) | JPA không diễn đạt tốt các hàm PostGIS/pgRouting. |
| Auth | Spring Security | Các API bản đồ/tìm kiếm/định tuyến hiện mở công khai; API quản trị/JWT chưa được triển khai trong backend hiện tại. |
| Frontend | React 18 + Vite + Leaflet | Bản đồ 2D theo tầng, nhẹ và đủ dùng cho phạm vi 1 ga. |
| GIS pipeline | QGIS (làm sạch CAD, georeferencing, xuất GeoJSON) | Chuẩn ngành cho indoor mapping khi không có ảnh vệ tinh (CAD nhìn xuyên được sàn/phòng/hành lang). |

### Hệ tọa độ

Hệ thống dùng song song 2 hệ tọa độ, chuyển đổi ở tầng Backend bằng phép Affine (`originLat`, `originLng`, `scaleX`, `scaleY`, `rotationDeg` lưu theo từng tầng):

- **Local (mét)** — dùng nội bộ CSDL để tính `cost` cho `pgr_dijkstra` và các truy vấn không gian (`ST_DWithin`, `ST_ClosestPoint`).
- **WGS84 (kinh/vĩ độ)** — dùng cho toàn bộ dữ liệu trao đổi qua API (chuẩn GeoJSON) và hiển thị trên Leaflet.

### Luồng dữ liệu

```
data/raw_cad/*.dwg (CAD gốc 11 ga Metro)
      │  QGIS: cleanup layer + georeference bằng 2-3 điểm mốc WGS84
      ▼
data/processed/<station>/<floor>.geojson  (nodes / edges / rooms)
      │  import bằng script gis-pipeline/
      ▼
PostgreSQL/PostGIS  (trigger tự tính geom_wgs84 + cost từ geom_local)
      │  pgr_dijkstra qua hàm fn_find_route
      ▼
Backend Spring Boot  (REST API — xem docs/RESTAPI_Spec.md)
      │  JSON/GeoJSON qua HTTPS
      ▼
Frontend React + Leaflet  (bản đồ theo tầng, tìm kiếm, chỉ đường, snap GPS vào node gần nhất)
```

Phân tích đầy đủ (đánh giá hướng đi, các quyết định kiến trúc, gap cần biết trước khi mở rộng sang 11 ga thật) nằm ở [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Cấu trúc repo

```
Finding_map_GIS/
├── backend/            Spring Boot REST API (Java 21, PostGIS/pgRouting)
├── frontend/           React + Vite + Leaflet
├── database/           schema.sql + seed data (PostgreSQL/PostGIS/pgRouting)
├── gis-pipeline/        Quy trình số hóa CAD -> GeoJSON (QGIS)
├── data/
│   ├── raw_cad/         Bản vẽ CAD gốc của 11 ga Metro Line 1 (.dwg, chưa xử lý)
│   └── processed/        Kết quả số hóa (.geojson; .dxf/.gpkg/.qmd bị gitignore)
├── docs/                Toàn bộ tài liệu (kiến trúc, REST API, roadmap, base tech)
└── docker-compose.yml   Docker Compose cho DB, Backend và Frontend
```

## Cách chạy dự án

### Yêu cầu

- [Docker](https://www.docker.com/) (chạy PostgreSQL/PostGIS/pgRouting local)
- Java 21+ và Maven (chạy Backend) — `brew install openjdk@21 maven` trên macOS
- Node.js 18+ (chạy Frontend)

> macOS + Homebrew: `openjdk@21` là keg-only nên không tự vào `PATH`. Set tạm khi chạy lệnh:
> `export JAVA_HOME="/opt/homebrew/opt/openjdk@21" && export PATH="$JAVA_HOME/bin:$PATH"`

### 1. Cơ sở dữ liệu

```bash
docker compose up -d db
# Lần đầu tiên container khởi tạo (volume rỗng) sẽ chạy schema + seed, bật hỗ trợ tìm kiếm,
# nạp room/entity từ database/_load_map_data.sql, routing graph từ database/_rebuild_graph.sql,
# sau đó tính lại cost cho pgRouting, áp dụng ràng buộc drawing_feature và nạp mặt bằng nền
# dữ liệu tầng trệt (ID 0), ràng buộc drawing_feature và mặt bằng tầng 1 (ID 1) Thảo Điền.
# DB expose ở cổng 5433 (không phải 5432 mặc định) để tránh xung đột với Postgres khác có sẵn trên máy.
```

Trên database đã khởi tạo trước đó, chuyển dữ liệu tầng trệt cũ sang ID `0`, sau đó nạp mặt bằng tầng 1 ID `1`:

```bash
psql -h localhost -p 5433 -U postgres -d indoornav -f database/migrations/20261020_drawing_feature_floor_required.sql
psql -h localhost -p 5433 -U postgres -d indoornav -f database/migrations/20261020_floor_zero_ground_level.sql
psql -h localhost -p 5433 -U postgres -d indoornav -f database/migrations/20261020_drawing_feature_semantics.sql
psql -h localhost -p 5433 -U postgres -d indoornav -f database/migrations/20261022_routing_modes_accessibility.sql
psql -h localhost -p 5433 -U postgres -d indoornav -f database/migrations/20261023_room_height.sql
psql -h localhost -p 5433 -U postgres -d indoornav -f database/seed/seed_thao_dien_floor0.sql
psql -h localhost -p 5433 -U postgres -d indoornav -f database/seed/seed_thao_dien_floor1.sql
psql -h localhost -p 5433 -U postgres -d indoornav -f database/seed/seed_thao_dien_floor0_routing.sql
psql -h localhost -p 5433 -U postgres -d indoornav -f database/seed/seed_thao_dien_floor1_routing.sql
```

Các seed mặt bằng và routing có thể chạy lặp lại theo đúng thứ tự trên. Seed floor 0 xóa các node tầng 0 cũ cùng cạnh liên quan trước khi tạo lại node cổng, thiết bị đứng và node tuyến từ GeoJSON; cổng được vẽ/đặt nhãn trực tiếp từ lớp `gates`. Seed floor 1 cập nhật bản vẽ theo `base_height` (Z=5 m) và giữ kết nối chuyển tầng. Chiều cao và cao độ đáy của phòng được đồng bộ từ thuộc tính GeoJSON `height` và `base_height`; các lớp 3D dùng `height` làm cao độ đỉnh và `base_height` làm cao độ đáy. Hai seed routing lấy cao độ từ `base_height` của từng tuyến, tạo node tại các đỉnh, tách cạnh theo từng đoạn và nối điểm truy cập cho từng phòng/khu vực. Floor 1 giữ hướng một chiều theo GeoJSON; routing floor 0 dùng các cạnh hai chiều vì nguồn hiện không khai báo thuộc tính `oneway`.

Sinh lại hai SQL khi cập nhật GeoJSON tầng Thảo Điền:

```bash
node gis-pipeline/scripts/build_routing_graph.mjs "data/processed/02. THAO DIEN" "database/_rebuild_graph.sql" "database/_load_map_data.sql"
```

Generator dùng các Point trong `02_node_modified_clean_v1.geojson` làm node cố định, đồng thời tách cạnh tại các đỉnh hình học có góc rẽ từ 20° để tạo node `turn` và các chỉ dẫn tương ứng (bỏ qua đoạn rẽ cách node kế tiếp dưới 1 m). Node rẽ được ghi vào `routing_turn_nodes.geojson`, các cạnh đã tách vào `routing_network_turn_nodes.geojson`; node loại `turn` được lưu trong backend để định tuyến nhưng ẩn trên frontend. Giao cắt giữa các cạnh không tự tạo kết nối. Áp dụng thủ công trên database đã khởi tạo: chạy `_load_map_data.sql` trước, sau đó `_rebuild_graph.sql`.

### 2. Backend

```bash
cd backend
mvn spring-boot:run
# API chạy ở http://localhost:8080 — xem docs/RESTAPI_Spec.md
```

### 3. Frontend

```bash
cd frontend
cp .env.example .env.local     # VITE_USE_MOCK=true để chạy ngay, không cần chờ Backend
npm install
npm run dev
# http://localhost:5173
```

Khi Backend đã sẵn sàng: đổi `VITE_USE_MOCK=false` trong `frontend/.env.local` để Frontend gọi API thật thay vì `frontend/src/mock/mockData.js`.

### Chạy toàn bộ bằng Docker

Docker Compose sẽ build Backend Spring Boot, build Frontend thành static assets và chạy cả hai cùng PostgreSQL/PostGIS/pgRouting:

```bash
docker compose up --build -d
# Frontend: http://localhost
# Backend:  http://localhost:8080
```

Trong mạng Docker, Backend tự kết nối tới `db:5432`; cổng `5433` chỉ dành cho kết nối từ máy host. Frontend proxy các request `/api` tới Backend nên không cần tạo `frontend/.env.local` khi chạy bằng Docker. Dừng các service bằng `docker compose down` (dữ liệu database vẫn giữ trong volume).

### Sử dụng thử

1. Mở `http://localhost:5173`, chọn tầng ở thanh chuyển tầng phía trên sidebar.
2. Bấm vào 1 điểm bất kỳ trên bản đồ để mô phỏng "vị trí hiện tại" — hệ thống tự snap vào node gần nhất.
3. Gõ từ khóa vào ô tìm kiếm (ví dụ "sân ga", "nhà vệ sinh") để chọn điểm đến.
4. Tuyến đường, hướng dẫn từng bước và cảnh báo chuyển tầng (thang máy/thang bộ) hiển thị ở sidebar; đổi tiêu chí Ngắn nhất / Nhanh nhất / Ít cầu thang để so sánh.

## REST API

Base URL: `/api`. Đặc tả đầy đủ ở [`docs/RESTAPI_Spec.md`](docs/RESTAPI_Spec.md).

| Nhóm | Mô tả | Auth |
|---|---|---|
| A. Bản đồ | `GET /api/floors`, `GET /api/floors/{id}/map`, `/api/map/floors/{id}/transform`, `/api/map/features/{id}` | Không cần |
| B. Tìm kiếm & định vị | `GET /api/rooms/search`, `GET /api/nodes/nearest` | Không cần |
| C. Định tuyến | `POST /api/route` (Dijkstra qua pgRouting) | Không cần |

> Nhóm D chỉ còn trong đặc tả tương lai; controller quản trị và JWT chưa có trong backend hiện tại.
| D. Quản trị | `/api/auth/login`, `/api/admin/**` (node/edge/room, import/export GeoJSON, kiểm tra liên thông đồ thị, cấu hình transform) | JWT Bearer |

## Trạng thái hiện tại

- ✅ Schema PostGIS/pgRouting và seed cơ bản — seed tạo tầng trệt ID 0 và tầng 1 ID 1; dữ liệu định tuyến/mặt bằng được nạp bằng SQL GIS tương ứng.
- ✅ Backend Spring Boot cho các API công khai A/B/C — đã kiểm tra trực tiếp với PostgreSQL thật: bản đồ, GeoJSON nền, tìm kiếm, nearest-node và tuyến đường qua `fn_find_route`.
- ✅ Frontend React/Vite/Leaflet — đã build và chạy dev server thành công.
- ⏳ Dữ liệu thật của 11 ga (`data/raw_cad/`) chưa được số hóa — xem `docs/ROADMAP.md` giai đoạn 2.
- ⏳ Backend có regression test cho request JSON không hợp lệ; cần mở rộng kiểm thử tự động các luồng nghiệp vụ và bổ sung test frontend.

## Tài liệu chi tiết

1. [`docs/BaseTech_IndoorNavigation.md`](docs/BaseTech_IndoorNavigation.md) — nền tảng công nghệ GIS/Indoor Navigation.
2. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — đánh giá hướng đi, quyết định kiến trúc, gap cần biết.
3. [`docs/RESTAPI_Spec.md`](docs/RESTAPI_Spec.md) — đặc tả toàn bộ REST API.
4. [`docs/ROADMAP.md`](docs/ROADMAP.md) — kế hoạch triển khai từng giai đoạn.
5. [`gis-pipeline/README.md`](gis-pipeline/README.md) — quy trình chuyển CAD → GeoJSON → CSDL.
