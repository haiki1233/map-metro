# GIS Pipeline — CAD → GeoJSON → CSDL

Quy trình chuyển `data/raw_cad/*.dwg` thành dữ liệu nạp được vào bảng `node` / `edge` / `room` (xem `docs/BaseTech_IndoorNavigation.md` mục 5 để hiểu lý do).

## Công cụ cần cài
- **QGIS** (miễn phí) — làm sạch, georeference, xuất GeoJSON.
- Plugin đọc DWG cho QGIS (ví dụ GDAL/OGR driver `CAD`, hoặc convert DWG → DXF bằng AutoCAD/ODA File Converter trước, vì OGR đọc DXF ổn định hơn DWG trực tiếp).

## Các bước cho MỖI ga

### Bước 1 — CAD Cleanup
1. Mở file `..._ROOM NAME_GROUND FLOOR.dwg` trong AutoCAD (hoặc DWG TrueView, miễn phí, chỉ xem/không sửa được nếu không có AutoCAD).
2. Tắt/xóa các layer không cần: điện, nước, kết cấu chi tiết, ghi chú kích thước, hatch trang trí...
3. Chỉ giữ: tường bao phòng, cửa ra vào, cầu thang, thang máy/thang cuốn, ranh giới khu chức năng (phòng vé, sân ga, nhà vệ sinh...).
4. Xuất lại thành `.dxf` (File → Save As → DXF) — định dạng OGR/QGIS đọc ổn định.

> **Lưu ý về Git:** các file `.dxf`, `.gpkg`, `.qmd` trong `data/processed/` **bị `.gitignore` bỏ qua** (nhị phân, dung lượng lớn, sinh lại được từ `.dwg`). Chỉ `.dwg` trong `data/raw_cad/` (nguồn gốc) và `.geojson` (kết quả số hóa) được commit. Vì vậy sau khi clone repo, **phải làm lại bước 1.4** để có file `.dxf` trước khi mở QGIS.

### Bước 2 — Georeferencing (gán tọa độ WGS84 thật)
1. Xác định 2–3 điểm mốc trên bản vẽ CAD (ví dụ góc tường ngoài của ga) và tọa độ GPS thực tế tương ứng (đo tại hiện trường hoặc đối chiếu Google Maps/ảnh vệ tinh).
2. Trong QGIS: Layer → Georeferencer, ghim từng cặp điểm CAD ↔ GPS, chọn phép biến đổi **Affine** hoặc **Helmert** (vì `schema.sql` dùng đúng công thức Affine: xoay + tỷ lệ + tịnh tiến — xem `fn_local_to_wgs84`/`fn_wgs84_to_local`).
3. Ghi lại 5 tham số suy ra được (`originLat`, `originLng`, `scaleX`, `scaleY`, `rotationDeg`) — đây chính là 1 dòng cần insert vào bảng `floor_transform` (hoặc gọi `PUT /api/admin/floors/{id}/transform`).

> Lưu ý: **không bắt buộc** phải tự tính tay 5 tham số này — có thể để `originLat/originLng` = tọa độ điểm gốc CAD (0,0) quy đổi ra GPS, `scaleX/scaleY = 1.0`, `rotationDeg` đo bằng góc lệch giữa trục CAD và trục Bắc thật. Cách đơn giản nhất: georeference 1 điểm làm gốc + 1 điểm để đo góc xoay.

### Bước 3 — Số hóa (Vectorization) trong QGIS
Trải layer CAD đã georeference làm nền, tạo 3 shapefile/GeoJSON layer mới:

| Layer xuất | Kiểu hình học | Map tới bảng | Thuộc tính bắt buộc |
|---|---|---|---|
| `rooms.geojson` | Polygon | `room` | `name`, `category` (`ticket_office`\|`restroom`\|`platform`\|...) |
| `nodes.geojson` | Point | `node` | `type` (`junction`\|`gate`\|`stair`\|`elevator`\|`escalator`\|`room_entrance`) |
| `edges.geojson` | LineString | `edge` | `edgeType` (`corridor`\|`stair`\|`elevator`\|`escalator`), `source`/`target` (id của node, điền sau khi có id) |

**Quy tắc bắt buộc khi vẽ mạng lưới đường (giống hướng dẫn trong BaseTech doc):**
- Các đường giao nhau PHẢI cắt đúng tại 1 điểm chung (dùng QGIS snapping, tolerance nhỏ) — nếu không, `pgr_dijkstra` sẽ không hiểu là có thể rẽ tại đó.
- Mỗi hành lang 2 chiều nên vẽ 1 line, khi import sẽ tạo 2 edge (source→target và target→source) — xem cách `database/seed/seed_data.sql` làm mẫu.
- Cổng ra vào 1 chiều (chỉ ra, không vào) chỉ tạo 1 edge theo đúng hướng — xem case lỗi `ROUTE_NOT_FOUND` trong `docs/RESTAPI_Spec.md`.
- Mỗi node loại `stair`/`elevator`/`escalator` cần gán `vertical_link_id` trỏ tới 1 dòng trong `vertical_link` — 1 vertical_link đại diện 1 thiết bị vật lý nối nhiều tầng.

### Bước 4 — Import vào CSDL
Hai lựa chọn (dùng cái nào tiện hơn khi có Backend):
1. **Qua API**: `POST /api/admin/import` (multipart, `layer=nodes|edges|rooms`, `floorId`) — xem `docs/RESTAPI_Spec.md` mục D.5.
2. **Qua script**: viết script Python (`scripts/`) đọc GeoJSON, sinh câu `INSERT` giống mẫu trong `database/seed/seed_data.sql`, chạy bằng `psql`. Phù hợp khi import số lượng lớn hoặc cần review SQL trước khi chạy.

### Bước 5 — Kiểm tra liên thông đồ thị
Sau khi import xong 1 tầng: gọi `GET /api/admin/graph/validate?floorId=<id>` (hoặc `SELECT * FROM fn_check_graph_connectivity(<1 node bất kỳ làm root>);`) — phải trả về **0 node cô lập** trước khi coi tầng đó là hoàn thành.

## Xem trước mặt bằng tầng 1 ga Thảo Điền

`database/seed/seed_thao_dien_floor0.sql` nạp `floor_0_rooms.geojson` vào `room`, các lớp site/nét vẽ/tường/thang/cổng vào `drawing_feature`, đồng thời xóa node tầng 0 cũ và các cạnh liên quan trước khi tái tạo dữ liệu cổng/thiết bị. Lớp `gates` được vẽ và gắn nhãn trực tiếp trên bản đồ; node cổng kỹ thuật không bị hiển thị lặp. `database/seed/seed_thao_dien_floor1.sql` nạp các lớp floor 1 hiện hành với Z theo `base_height` (5 m trong dữ liệu mới), liên kết cặp thiết bị chuyển tầng qua `vertical_link` và tạo cạnh liên tầng. Sau đó `seed_thao_dien_floor0_routing.sql` và `seed_thao_dien_floor1_routing.sql` nạp hai mạng đi bộ với cao độ từ `base_height` của từng tuyến; mỗi đỉnh tuyến thành node để hỗ trợ rẽ, cạnh được tách theo từng đoạn và điểm truy cập phòng được gắn vào đồ thị.

## Trạng thái hiện tại của `data/raw_cad/`
11 ga tuyến Metro Số 1 (Văn Thánh Park → Suối Tiên Terminal), mỗi ga có file `ROOM NAME_GROUND FLOOR.dwg` (mặt bằng tầng trệt) + `PARKING SPACE.dwg` (bãi xe). Chưa có ga nào được số hóa. Xem `docs/ROADMAP.md` giai đoạn 2 để biết thứ tự triển khai đề xuất (bắt đầu từ 1 ga thí điểm).

## ⚠️ BLOCKER đã phát hiện (2026-09-15): thiếu file mặt bằng gốc (XREF)

Đã convert cả 22 file DWG (11 ga) sang DXF bằng ODA File Converter và đọc trực tiếp bằng Python (`ezdxf`) để kiểm tra. Kết quả:

- File `..._ROOM NAME_GROUND FLOOR.dwg` của **10/11 ga** (trừ Suối Tiên) **chỉ chứa 21-25 đối tượng** — toàn bộ là text nhãn tên/số phòng (`"23"`, `"22A"`, `"ST-1"`, `"EV-1"`...) và ký hiệu, **không có bất kỳ đường tường, polygon phòng, hay hành lang nào**.
- File này tham chiếu (XREF) tới 1 file ngoài tên `<mã ga>_X_PLAN_GF.dwg` — đây mới là bản vẽ mặt bằng gốc thật (tường/phòng/cửa) — nhưng **file đó không có trong bộ dữ liệu đã nhận**, nên khi mở ra XREF bị rỗng.
- File `..._PARKING SPACE.dwg` thì đầy đủ dữ liệu thật (186–13976 đối tượng: bãi xe, hàng rào, vỉa hè, đường...) nhưng đó là **layout ngoài trời**, không phải mặt bằng trong nhà ga.
- Riêng ga Suối Tiên Terminal (`45_X_GROUND MASTER PLAN.dwg`, ~4700 đối tượng thật) không bị vấn đề này — nhưng là bản vẽ site/terminal quy mô lớn (đường, bãi xe, cảnh quan), không phải mặt bằng 1 tầng ga đơn lẻ.

**Danh sách 10 file cần xin lại** (đúng tên, đặt vào đúng thư mục `data/raw_cad/<tên ga>/` khi có):

| Ga | File còn thiếu |
|---|---|
| 01. VAN THANH PARK | `44_X_PLAN_GF.dwg` |
| 02. THAO DIEN | `39_X_PLAN_GF.dwg` |
| 03. RACH CHIEC | `46_X_PLAN_GF.dwg` |
| 04. PHUOC LONG | `40_X_PLAN_GF.dwg` |
| 05. BINH THAI | `41_X_PLAN_GF.dwg` |
| 06. THU DUC | `42_X_PLAN_GF.dwg` |
| 07. HIGH TECH PARK | `43_X_PLAN_GF.dwg` |
| 08. NATIONAL UNIVERSITY | `47_X_PLAN_GF.dwg` |
| 09. TAN CANG | `48_X_PLAN_GF.dwg` |
| 10. AN PHU | `49_X_PLAN_GF.dwg` |

**Không tự suy luận/vẽ lại** phần tường-phòng-hành lang còn thiếu này — phải có đúng file gốc từ đơn vị cung cấp CAD, nếu không dữ liệu số hóa sẽ sai lệch thực tế. Xem `docs/REVIEW_NOTES.md` để biết trạng thái theo dõi blocker này.

## ✅ Pilot đã chạy thật: bãi xe Văn Thánh Park (2026-09-15)

Trong lúc chờ file `_PLAN_GF.dwg`, đã thử toàn bộ pipeline CAD → GeoJSON → DB → REST API bằng dữ liệu bãi xe (đầy đủ, không bị thiếu XREF):

- Script: `scripts/setup_pilot_floor.sql` (tạo `floorId=3`) + `scripts/import_van_thanh_parking_pilot.py` (đọc DXF bằng `ezdxf`, gọi thật `POST /api/admin/nodes|edges|rooms` qua JWT).
- Kết quả nạp vào DB thật qua chính Backend API (không insert thẳng SQL): **178 ô đỗ xe** (`room`, category `parking_space`), **3 node** (2 cổng ra vào trích từ layer `gate` + 1 junction đại diện khu đỗ xe), **6 edge** (2 chiều).
- Đã verify qua API thật: `GET /api/floors/3/map` trả đúng 178 room/3 node/6 edge; `POST /api/route` từ cổng → khu đỗ xe cho `totalDistance=68.36m`; `GET /api/admin/graph/validate?floorId=3` → `isFullyConnected: true`.
- Xem được trực tiếp trên Frontend (`http://localhost:5173`, chọn tầng "Bãi xe Văn Thánh Park (thử nghiệm)").

**Giới hạn đã biết của pilot này** (không che giấu, xem thêm docstring đầu file `import_van_thanh_parking_pilot.py`):
1. **Tọa độ GPS gốc chỉ là gần đúng** — lấy 1 điểm tham khảo từ Google Maps cho cả ga, chưa georeference bằng 2-3 điểm góc thật trong QGIS. Vị trí trên bản đồ sẽ lệch so với thực tế.
2. **Mạng lưới node/edge bị đơn giản hóa** — cả 178 ô đỗ xe đều trỏ chung về 1 node junction duy nhất (không có đường đi riêng tới từng hàng xe), vì file CAD không có sẵn layer "đường đi bộ" nối từ cổng vào khu đỗ xe này. Muốn chi tiết hơn cần số hóa thêm bằng tay trong QGIS.

Đây là bằng chứng pipeline (parse CAD → transform toạ độ → gọi Admin API → routing thật) hoạt động đúng cơ chế — khi có file `_PLAN_GF.dwg` thật, quy trình tương tự sẽ áp dụng cho dữ liệu phòng/hành lang trong nhà, chỉ cần thay bước georeferencing bằng dữ liệu chính xác (Bước 2 ở trên).
