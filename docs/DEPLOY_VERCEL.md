# Deploy lên Vercel

Tài liệu này mô tả cách đưa toàn bộ dự án lên **một project Vercel duy nhất**: frontend tĩnh, backend Spring Boot chạy trong container, database trên Neon.

## 1. Kiến trúc deploy

| Thành phần | Chạy ở đâu | Cấu hình |
|---|---|---|
| `frontend/` (React + Vite) | Vercel Service `frontend` | build tĩnh, framework `vite` |
| `backend/` (Spring Boot 3 / Java 21) | Vercel Service `backend` | [Container Runtime](https://vercel.com/docs/functions/runtimes/container) (Beta) qua `backend/Dockerfile.vercel` |
| PostgreSQL + PostGIS + pgRouting | **Neon**, cài qua Vercel Marketplace | nằm ngoài Vercel, backend kết nối qua Internet |

`docker-compose.yml` ở máy local **không** dùng cho production — Vercel không chạy Docker Compose.

Hai service nằm chung một project nên có chung một domain. [`vercel.json`](../vercel.json) chia traffic:

- `/api/*` → service `backend`, **giữ nguyên tiền tố `/api`** (khớp `@RequestMapping("/api/...")` trong các controller, không cần rewrite đường dẫn).
- Còn lại → service `frontend`.

Vì browser gọi `/api` trên **cùng origin**, request không phải cross-origin → **không cần chỉnh `app.cors.allowed-origins`** ([SecurityConfig.java](../backend/src/main/java/com/metro/indoornav/config/SecurityConfig.java)).

> **Lưu ý:** `Services` và `Container Runtime` đều đang ở trạng thái **Beta**.

---

## 2. Bước 1 — Tạo database Neon

```bash
vercel install neon
```

Hoặc trên dashboard: **Storage → Marketplace → Neon**.

Sau đó vào Neon Console lấy **2** connection string:

| Loại | Host | Dùng để |
|---|---|---|
| Direct | `ep-xxx.<region>.aws.neon.tech` | chạy script schema/seed (Bước 2) |
| Pooled | `ep-xxx-pooler.<region>.aws.neon.tech` | backend kết nối lúc chạy (Bước 3) |

Neon khuyến nghị dùng kết nối **direct** cho migration, vì pooler chạy PgBouncer ở `pool_mode=transaction` và không hỗ trợ các tính năng phụ thuộc session.

### Bật extension

pgRouting **yêu cầu PostGIS cài trước**, nên phải chạy đúng thứ tự:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgrouting;
```

Các extension còn lại (`unaccent`, `pg_trgm`) đã có sẵn trong [`database/schema_fix_v2.sql`](../database/schema_fix_v2.sql) và đều được Neon hỗ trợ.

---

## 3. Bước 2 — Nạp schema + seed

Chạy **đúng thứ tự** sau, dùng connection string **direct**:

| # | File | Ghi chú |
|---|---|---|
| 1 | `database/schema_fix_v2.sql` | extension, bảng, view, `fn_find_route`, trigger |
| 2 | `database/seed/seed_data.sql` | dữ liệu nền |
| 3 | `database/_apply_search_support.sql` | `unaccent` + `pg_trgm` cho tìm kiếm |
| 4 | `database/_load_map_data.sql` | nạp node/edge/room từ GeoJSON |
| 5 | `database/_rebuild_graph.sql` | dựng lại graph |
| 6 | `database/_apply_costs.sql` | tính `cost_*` |
| 7 | `database/migrations/20261020_drawing_feature_floor_required.sql` | |
| 8 | `database/migrations/20261020_floor_zero_ground_level.sql` | |
| 9 | `database/migrations/20261020_drawing_feature_semantics.sql` | |
| 10 | `database/migrations/20261022_routing_modes_accessibility.sql` | **bắt buộc** — xem cảnh báo bên dưới |
| 11 | `database/migrations/20261023_room_height.sql` | |
| 12 | `database/seed/seed_thao_dien_floor0.sql` | |
| 13 | `database/seed/seed_thao_dien_floor1.sql` | |
| 14 | `database/seed/seed_thao_dien_floor0_routing.sql` | |
| 15 | `database/seed/seed_thao_dien_floor1_routing.sql` | |

Bash (Git Bash / WSL / macOS):

```bash
export DIRECT_URL='postgresql://<user>:<pass>@ep-xxx.<region>.aws.neon.tech/neondb?sslmode=require'

for f in \
  database/schema_fix_v2.sql \
  database/seed/seed_data.sql \
  database/_apply_search_support.sql \
  database/_load_map_data.sql \
  database/_rebuild_graph.sql \
  database/_apply_costs.sql \
  database/migrations/20261020_drawing_feature_floor_required.sql \
  database/migrations/20261020_floor_zero_ground_level.sql \
  database/migrations/20261020_drawing_feature_semantics.sql \
  database/migrations/20261022_routing_modes_accessibility.sql \
  database/migrations/20261023_room_height.sql \
  database/seed/seed_thao_dien_floor0.sql \
  database/seed/seed_thao_dien_floor1.sql \
  database/seed/seed_thao_dien_floor0_routing.sql \
  database/seed/seed_thao_dien_floor1_routing.sql
do
  echo "==> $f"
  psql "$DIRECT_URL" -v ON_ERROR_STOP=1 -f "$f" || break
done
```

PowerShell:

```powershell
$env:DIRECT_URL = 'postgresql://<user>:<pass>@ep-xxx.<region>.aws.neon.tech/neondb?sslmode=require'

$files = @(
  'database/schema_fix_v2.sql',
  'database/seed/seed_data.sql',
  'database/_apply_search_support.sql',
  'database/_load_map_data.sql',
  'database/_rebuild_graph.sql',
  'database/_apply_costs.sql',
  'database/migrations/20261020_drawing_feature_floor_required.sql',
  'database/migrations/20261020_floor_zero_ground_level.sql',
  'database/migrations/20261020_drawing_feature_semantics.sql',
  'database/migrations/20261022_routing_modes_accessibility.sql',
  'database/migrations/20261023_room_height.sql',
  'database/seed/seed_thao_dien_floor0.sql',
  'database/seed/seed_thao_dien_floor1.sql',
  'database/seed/seed_thao_dien_floor0_routing.sql',
  'database/seed/seed_thao_dien_floor1_routing.sql'
)

foreach ($f in $files) {
  Write-Host "==> $f"
  psql $env:DIRECT_URL -v ON_ERROR_STOP=1 -f $f
  if ($LASTEXITCODE -ne 0) { break }
}
```

> ⚠️ **`20261022_routing_modes_accessibility.sql` không được mount trong `docker-compose.yml`** (compose chỉ mount 4 migration còn lại). Nhưng file này **bắt buộc** phải chạy, và phải chạy **sau `_apply_costs.sql`**, vì nó `CREATE OR REPLACE` lại 3 đối tượng mà các file trước đã định nghĩa ở bản cũ hơn:
>
> | Đối tượng | Bản cũ | Bản trong 20261022 |
> |---|---|---|
> | `trg_fn_edge_before_insert()` | `_apply_costs.sql` | có nhánh xử lý edge **khác tầng** + `avg_time_per_floor` cho thang máy |
> | `v_edge_accessible` | `schema_fix_v2.sql` | loại thêm `escalator`, `escalator_stair`, `motorcycle_lane` |
> | `fn_find_route(...)` | `schema_fix_v2.sql` | dùng `v_edge_time` / `v_edge_least_stairs` / `v_edge_accessible` |
>
> Nếu bỏ qua, chế độ `accessible` sẽ trả về đường đi qua cầu thang/thang cuốn, và `cost_time` của edge khác tầng bị sai.

---

## 4. Bước 3 — Biến môi trường trên Vercel

Đặt trong **Project → Settings → Environment Variables**, áp cho cả Production và Preview.

| Biến | Service | Giá trị |
|---|---|---|
| `VITE_API_BASE_URL` | frontend | `/api` |
| `VITE_USE_MOCK` | frontend | `false` |
| `SPRING_DATASOURCE_URL` | backend | `jdbc:postgresql://ep-xxx-pooler.<region>.aws.neon.tech/neondb?sslmode=require` |
| `SPRING_DATASOURCE_USERNAME` | backend | user của Neon |
| `SPRING_DATASOURCE_PASSWORD` | backend | password của Neon |
| `SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE` | backend | `2` |
| `SPRING_DATASOURCE_HIKARI_MAX_LIFETIME` | backend | `240000` |
| `LOGGING_LEVEL_ORG_HIBERNATE_SQL` | backend | `WARN` |

Giải thích:

- **`VITE_USE_MOCK=false` là bắt buộc.** [indoorNavApi.js:30](../frontend/src/api/indoorNavApi.js#L30) đọc biến này; nếu để `true` thì frontend dùng `src/mock/mockData.js` và **không gọi backend**.
- Vite **inline** biến `VITE_*` vào bundle lúc **build**, không phải lúc chạy → đổi biến phải **redeploy**, chỉ restart là không đủ.
- `frontend/.env.local` và `frontend/.env.development.local` đã nằm trong `.gitignore` nên **không** được đẩy lên Vercel — chỉ có tác dụng khi build ở máy. Trên Vercel chỉ biến môi trường của project được dùng.
- `SPRING_DATASOURCE_*` khớp với [application.yml](../backend/src/main/resources/application.yml) qua relaxed binding của Spring Boot, nên **không cần sửa code**. Giá trị trong `application.yml` (`localhost:5433`) chỉ dùng cho môi trường local.
- **Pool size = 2**: mỗi instance backend là một Vercel Function riêng, mỗi instance giữ một HikariCP pool. Mặc định Hikari là 10 → vài instance là đủ đụng trần connection của Neon. Đây cũng là lý do dùng host `-pooler`.
- **`maxLifetime = 240000`** (4 phút): để ngắn hơn ngưỡng pooler ngắt connection idle, tránh lỗi *connection closed* khi instance ngủ rồi thức.
- **`LOGGING_LEVEL_ORG_HIBERNATE_SQL`**: [application.yml:41](../backend/src/main/resources/application.yml#L41) đang để `DEBUG`, log ra toàn bộ SQL — chỉ nên bật ở local.
- `SERVER_PORT` **không cần đặt**: [backend/Dockerfile.vercel](../backend/Dockerfile.vercel) đã set `SERVER_PORT=80` (Container Runtime route vào port 80; Spring Boot đọc `SERVER_PORT` qua relaxed binding nên `application.yml` giữ nguyên `8080` cũng chạy đúng).

---

## 5. Bước 4 — Deploy

1. Push code lên GitHub/GitLab.
2. Trên Vercel: **Add New → Project → import repo**.
3. **Để trống `Root Directory`** (mặc định `./`). `vercel.json` phải nằm ở gốc repo vì nó định nghĩa `services`. Nếu trỏ Root Directory vào `frontend/`, Vercel sẽ không thấy `vercel.json` và bỏ qua cả backend.
4. Framework Preset: để **Other** — mỗi service tự khai báo `framework`/`runtime` riêng trong `vercel.json`.
5. Deploy. Vercel build từng service riêng: frontend bằng `npm run build`, backend bằng `backend/Dockerfile.vercel`.
6. Sau này mỗi lần `git push` là một lần deploy.

Deploy từ máy (không cần push):

```bash
npm i -g vercel
vercel          # preview
vercel --prod   # production
```

Chạy thử cả 2 service ở local (cần Docker daemon đang chạy):

```bash
vercel dev
```

---

## 6. Bước 5 — Kiểm tra

```bash
BASE=https://<project>.vercel.app

# backend sống
curl -i "$BASE/api/floors"

# tìm kiếm (unaccent + pg_trgm)
curl -i "$BASE/api/rooms/search?q=nha%20ve%20sinh"

# định tuyến (đi qua pgr_dijkstra)
curl -i -X POST "$BASE/api/route" -H 'Content-Type: application/json' \
  -d '{"startNodeId":1,"endNodeId":2,"criteria":"accessible"}'

# frontend
curl -i "$BASE/"
```

Request đầu tiên sau ~5 phút không có traffic sẽ chậm hơn bình thường (container đã scale-to-zero, JVM phải khởi động lại). Đây là hành vi bình thường, không phải lỗi.

---

## 7. Hạn chế cần biết

1. **Cold start JVM.** Container backend scale-to-zero sau 5 phút không có traffic; request kế tiếp phải chờ JVM + Hibernate + pool khởi động (vài giây). Nếu Vercel báo timeout, thêm vào service `backend` trong `vercel.json`:
   ```json
   "functions": { "maxDuration": 60 }
   ```
2. **Số connection tới Neon.** Vercel scale ngang theo traffic, mỗi instance một pool → tổng connection = số instance × pool size. Giữ pool size nhỏ và luôn dùng host `-pooler`.
3. **Neon free tier tự suspend compute** khi không dùng, nên query đầu tiên sau một lúc nghỉ cũng chậm hơn.
4. **Không có tiến trình nền.** `Services` chỉ phục vụ request. Nếu sau này cần job định kỳ (ví dụ chạy lại `_rebuild_graph.sql`), phải dùng Vercel Cron hoặc Daemon.
5. **Beta.** `Services` và `Container Runtime` có thể đổi cấu hình. Nếu cần ổn định tuyệt đối, chuyển service `backend` sang Railway/Render/Fly.io và giữ `vercel.json` chỉ còn phần frontend + một rewrite trỏ `/api/(.*)` sang domain backend đó (khi đó nhớ set `CORS_ALLOWED_ORIGINS` nếu gọi thẳng, hoặc giữ rewrite để Vercel proxy).

---

## 8. Xử lý sự cố

| Triệu chứng | Nguyên nhân thường gặp |
|---|---|
| Build frontend fail ở bước detect framework | Xoá `"framework": "vite"` trong `vercel.json` — Vercel sẽ tự nhận diện từ `frontend/package.json` + `vite.config.js` |
| `404` cho mọi `/api/...` | Sai `rewrites` gốc. Routing vào một service là **final**, không fallback sang rewrite khác |
| Frontend hiện dữ liệu mẫu, không gọi API | `VITE_USE_MOCK` còn `true`, hoặc sửa env nhưng chưa redeploy |
| `prepared statement "S_1" already exists` | Thêm `prepareThreshold=0` vào `SPRING_DATASOURCE_URL` |
| `too many clients already` / connection bị đóng | Giảm `SPRING_DATASOURCE_HIKARI_MAXIMUM_POOL_SIZE`, kiểm tra đang dùng host `-pooler` |
| `function pgr_dijkstra(...) does not exist` | Chưa chạy `CREATE EXTENSION pgrouting` (và phải chạy `postgis` trước) |
| `fn_find_route` báo lỗi hoặc thiếu chế độ `accessible` | Chưa chạy migration `20261022_routing_modes_accessibility.sql` |
| Backend không lên, log báo port | Container phải lắng nghe port **80**; xem `SERVER_PORT` trong `backend/Dockerfile.vercel` |
| Build ở máy (Git Bash), bundle chứa `baseURL: "C:/Program Files/Git/api"` | MSYS của Git Bash tự đổi giá trị `/api` thành đường dẫn Windows. Chạy `MSYS_NO_PATHCONV=1 VITE_API_BASE_URL=/api npm run build`, hoặc build qua PowerShell/CMD |
