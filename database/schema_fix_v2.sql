-- =========================================================
-- SCHEMA: Hệ thống tìm đường nội khu ga Metro (Bản 3D Final)
-- Cập nhật: Hỗ trợ tọa độ 3D (X, Y, Z) & ETL Data từ QGIS
-- =========================================================

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgrouting;
-- unaccent: tim kiem khong dau ("nha ve sinh" phai khop "Nhà vệ sinh").
-- pg_trgm: chi muc trigram cho ILIKE '%tu khoa%' (B.1 GET /api/rooms/search).
CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- unaccent() goc duoc danh dau STABLE (phu thuoc bang unaccent_rules co the doi), nen KHONG duoc
-- phep dung trong bieu thuc CREATE INDEX. Ham bao nay khang dinh ket qua la bat bien de chi muc
-- bieu thuc hoat dong duoc. PHAI khoa search_path de tranh bi chiem dung.
CREATE OR REPLACE FUNCTION immutable_unaccent(p_text TEXT)
RETURNS TEXT AS $$
    SELECT public.unaccent('public.unaccent'::regdictionary, p_text);
$$ LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT
SET search_path = pg_catalog, public;

-- 1. Bảng Tầng và Cấu hình dịch chuyển tọa độ
CREATE TABLE floor (
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(50) NOT NULL,
    level_order  INT NOT NULL UNIQUE,
    description  VARCHAR(255)
);

CREATE TABLE floor_transform (
    floor_id      INT PRIMARY KEY REFERENCES floor(id) ON DELETE CASCADE,
    origin_lat    DOUBLE PRECISION NOT NULL,
    origin_lng    DOUBLE PRECISION NOT NULL,
    scale_x       DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    scale_y       DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    rotation_deg  DOUBLE PRECISION NOT NULL DEFAULT 0.0
);

-- 2. Hàm chuyển đổi tọa độ (CẬP NHẬT HỖ TRỢ TRỤC Z)
CREATE OR REPLACE FUNCTION fn_local_to_wgs84(p_floor_id INT, p_x DOUBLE PRECISION, p_y DOUBLE PRECISION, p_z DOUBLE PRECISION DEFAULT 0.0)
RETURNS geometry AS $$
DECLARE
    t floor_transform%ROWTYPE;
    rot_rad DOUBLE PRECISION;
    dx DOUBLE PRECISION;
    dy DOUBLE PRECISION;
    meters_per_deg_lat CONSTANT DOUBLE PRECISION := 111320.0;
    meters_per_deg_lng DOUBLE PRECISION;
    lat DOUBLE PRECISION;
    lng DOUBLE PRECISION;
BEGIN
    SELECT * INTO t FROM floor_transform WHERE floor_id = p_floor_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Chưa cấu hình floor_transform cho floor_id = %', p_floor_id;
    END IF;

    rot_rad := radians(t.rotation_deg);
    dx := (p_x * t.scale_x * cos(rot_rad)) - (p_y * t.scale_y * sin(rot_rad));
    dy := (p_x * t.scale_x * sin(rot_rad)) + (p_y * t.scale_y * cos(rot_rad));

    meters_per_deg_lng := meters_per_deg_lat * cos(radians(t.origin_lat));

    lat := t.origin_lat + (dy / meters_per_deg_lat);
    lng := t.origin_lng + (dx / meters_per_deg_lng);

    -- Tạo Point 3D (lng, lat, z)
    RETURN ST_SetSRID(ST_MakePoint(lng, lat, p_z), 4326);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION fn_wgs84_to_local(p_floor_id INT, p_lng DOUBLE PRECISION, p_lat DOUBLE PRECISION, p_z DOUBLE PRECISION DEFAULT 0.0)
RETURNS geometry AS $$
DECLARE
    t floor_transform%ROWTYPE;
    rot_rad DOUBLE PRECISION;
    meters_per_deg_lat CONSTANT DOUBLE PRECISION := 111320.0;
    meters_per_deg_lng DOUBLE PRECISION;
    dx DOUBLE PRECISION;
    dy DOUBLE PRECISION;
    x DOUBLE PRECISION;
    y DOUBLE PRECISION;
BEGIN
    SELECT * INTO t FROM floor_transform WHERE floor_id = p_floor_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Chưa cấu hình floor_transform cho floor_id = %', p_floor_id;
    END IF;

    meters_per_deg_lng := meters_per_deg_lat * cos(radians(t.origin_lat));
    dy := (p_lat - t.origin_lat) * meters_per_deg_lat;
    dx := (p_lng - t.origin_lng) * meters_per_deg_lng;

    rot_rad := radians(-t.rotation_deg);
    x := (dx * cos(rot_rad) - dy * sin(rot_rad)) / t.scale_x;
    y := (dx * sin(rot_rad) + dy * cos(rot_rad)) / t.scale_y;

    -- Tạo Point 3D (x, y, z)
    RETURN ST_SetSRID(ST_MakePoint(x, y, p_z), 0);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- 3. Bảng dữ liệu Tiện ích & Nút giao (CẬP NHẬT KIỂU PointZ)
CREATE TABLE vertical_link (
    id                SERIAL PRIMARY KEY,
    label             VARCHAR(100),
    transfer_type     VARCHAR(20) NOT NULL
                       CHECK (transfer_type IN ('stair','elevator','escalator')),
    avg_time_per_floor DOUBLE PRECISION NOT NULL DEFAULT 20
);

CREATE UNIQUE INDEX uq_thao_dien_floor1_vertical_link_label
    ON vertical_link (label)
    WHERE label LIKE 'TD_F1:%';

CREATE TABLE node (
    id                SERIAL PRIMARY KEY,
    floor_id          INT REFERENCES floor(id) ON DELETE CASCADE,
    type              VARCHAR(50) DEFAULT 'junction',
    geom_local        geometry(PointZ, 0),    -- < ĐÃ SỬA THÀNH PointZ
    geom_wgs84        geometry(PointZ, 4326), -- < ĐÃ SỬA THÀNH PointZ
    vertical_link_id  INT REFERENCES vertical_link(id)
);

CREATE INDEX idx_node_geom_local  ON node USING GIST (geom_local);
CREATE INDEX idx_node_geom_wgs84  ON node USING GIST (geom_wgs84);
CREATE INDEX idx_node_floor       ON node (floor_id);

CREATE OR REPLACE FUNCTION trg_fn_node_set_wgs84()
RETURNS TRIGGER AS $$
BEGIN
    -- Truyền thêm tham số Z vào hàm
    IF NEW.geom_local IS NOT NULL AND NEW.geom_wgs84 IS NULL AND NEW.floor_id IS NOT NULL THEN
        NEW.geom_wgs84 := fn_local_to_wgs84(NEW.floor_id, ST_X(NEW.geom_local), ST_Y(NEW.geom_local), ST_Z(NEW.geom_local));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_node_before_insert_update
BEFORE INSERT OR UPDATE OF geom_local, floor_id ON node
FOR EACH ROW EXECUTE FUNCTION trg_fn_node_set_wgs84();


-- 4. Bảng Đường Đi / Cạnh (CẬP NHẬT KIỂU LineStringZ VÀ BỎ NOT NULL CHO ETL)
CREATE TABLE edge (
    id                  SERIAL PRIMARY KEY,
    source              INT, 
    target              INT, 
    edge_type           VARCHAR(50) DEFAULT 'corridor', 
    geom_local          geometry(LineStringZ, 0),    -- < ĐÃ SỬA THÀNH LineStringZ
    geom_wgs84          geometry(LineStringZ, 4326), -- < ĐÃ SỬA THÀNH LineStringZ
    cost_distance       DOUBLE PRECISION,
    cost_time           DOUBLE PRECISION,
    cost_least_stairs   DOUBLE PRECISION,
    reverse_cost_distance     DOUBLE PRECISION,
    reverse_cost_time         DOUBLE PRECISION,
    reverse_cost_least_stairs DOUBLE PRECISION,
    CONSTRAINT chk_edge_no_self_loop CHECK (source IS NULL OR target IS NULL OR source <> target)
);

CREATE INDEX idx_edge_geom_local  ON edge USING GIST (geom_local);
CREATE INDEX idx_edge_geom_wgs84  ON edge USING GIST (geom_wgs84);
CREATE INDEX idx_edge_source      ON edge (source);
CREATE INDEX idx_edge_target      ON edge (target);

CREATE OR REPLACE FUNCTION trg_fn_edge_before_insert()
RETURNS TRIGGER AS $$
DECLARE
    p1 geometry; p2 geometry;
    floor_a INT; floor_b INT;
    vlink_a INT; vlink_b INT;
    v_avg_time DOUBLE PRECISION;
    floor_diff INT;
    stair_penalty CONSTANT DOUBLE PRECISION := 10.0;
    walking_speed CONSTANT DOUBLE PRECISION := 1.2;
    stair_speed CONSTANT DOUBLE PRECISION := 0.6;
    escalator_speed CONSTANT DOUBLE PRECISION := 0.8;
BEGIN
    -- TRƯỜNG HỢP 1: Dữ liệu thô import từ QGIS (Chưa có Source/Target)
    IF NEW.source IS NULL OR NEW.target IS NULL THEN
        IF NEW.geom_wgs84 IS NOT NULL AND (NEW.cost_distance IS NULL OR NEW.cost_distance < 0) THEN
            -- PHAI do qua ::geography: ST_3DLength tren geom_wgs84 (EPSG:4326) tra ve so DO,
            -- khong phai met. Do dai that cua corridor ~21m nhung truoc day luu 0.00019 (do),
            -- nen moi chi phi dinh tuyen, moi cau huong dan "khoang Nm" deu sai.
            -- Cong them chenh lech truc Z de giu dung do dai mat cat nghieng (cau thang/doc).
            NEW.cost_distance := ST_Length(NEW.geom_wgs84::geography)
                                 + ABS(COALESCE(ST_Z(ST_EndPoint(NEW.geom_wgs84)), 0)
                                     - COALESCE(ST_Z(ST_StartPoint(NEW.geom_wgs84)), 0));
        END IF;
        
        IF NEW.cost_distance IS NOT NULL AND (NEW.cost_time IS NULL OR NEW.cost_time < 0) THEN
            NEW.cost_time := CASE lower(COALESCE(NEW.edge_type, ''))
                WHEN 'stair' THEN NEW.cost_distance / stair_speed
                WHEN 'stairs' THEN NEW.cost_distance / stair_speed
                WHEN 'escalator' THEN NEW.cost_distance / escalator_speed
                WHEN 'escalator_stair' THEN NEW.cost_distance / escalator_speed
                WHEN 'elevator' THEN NEW.cost_distance / walking_speed + 15
                ELSE NEW.cost_distance / walking_speed
            END;
            NEW.cost_least_stairs := CASE
                WHEN lower(COALESCE(NEW.edge_type, '')) IN ('stair', 'stairs')
                    THEN NEW.cost_distance * stair_penalty
                ELSE NEW.cost_distance
            END;
        END IF;
        RETURN NEW;
    END IF;

    -- TRƯỜNG HỢP 2: Dữ liệu tạo thủ công (Đã biết trước Source/Target)
    SELECT geom_local, floor_id, vertical_link_id INTO p1, floor_a, vlink_a FROM node WHERE id = NEW.source;
    SELECT geom_local, floor_id, vertical_link_id INTO p2, floor_b, vlink_b FROM node WHERE id = NEW.target;

    IF floor_a = floor_b THEN
        -- Tự động sinh LineString 3D nối 2 Point 3D nếu chưa có nét vẽ
        IF NEW.geom_local IS NULL AND NEW.geom_wgs84 IS NULL AND p1 IS NOT NULL AND p2 IS NOT NULL THEN
            NEW.geom_local  := ST_MakeLine(p1, p2);
            NEW.geom_wgs84  := ST_MakeLine(fn_local_to_wgs84(floor_a, ST_X(p1), ST_Y(p1), ST_Z(p1)),
                                            fn_local_to_wgs84(floor_b, ST_X(p2), ST_Y(p2), ST_Z(p2)));
        END IF;

        IF NEW.cost_distance IS NULL OR NEW.cost_distance < 0 THEN
            -- Uu tien geom_local: day la he toa do CUC BO tinh bang met (SRID 0) va moi chi phi
            -- dinh tuyen deu tinh bang met. geom_wgs84 la EPSG:4326 (do) nen chi duoc dung lam
            -- phuong an du phong, do qua ::geography.
            IF NEW.geom_local IS NOT NULL THEN
                NEW.cost_distance := ST_3DLength(NEW.geom_local);
            ELSEIF NEW.geom_wgs84 IS NOT NULL THEN
                NEW.cost_distance := ST_Length(NEW.geom_wgs84::geography)
                                     + ABS(COALESCE(ST_Z(ST_EndPoint(NEW.geom_wgs84)), 0)
                                         - COALESCE(ST_Z(ST_StartPoint(NEW.geom_wgs84)), 0));
            ELSE
                NEW.cost_distance := 0;
            END IF;
        END IF;

        IF NEW.cost_time IS NULL OR NEW.cost_time < 0 THEN
            NEW.cost_time := CASE lower(COALESCE(NEW.edge_type, ''))
                WHEN 'stair' THEN NEW.cost_distance / stair_speed
                WHEN 'stairs' THEN NEW.cost_distance / stair_speed
                WHEN 'escalator' THEN NEW.cost_distance / escalator_speed
                WHEN 'escalator_stair' THEN NEW.cost_distance / escalator_speed
                WHEN 'elevator' THEN NEW.cost_distance / walking_speed + 15
                ELSE NEW.cost_distance / walking_speed
            END;
        END IF;
    ELSE
        -- Edge chuyển tầng
        NEW.geom_local := NULL;
        NEW.geom_wgs84 := NULL;
        floor_diff := ABS(floor_b - floor_a);

        IF NEW.cost_distance IS NULL OR NEW.cost_distance < 0 THEN
            NEW.cost_distance := floor_diff * 5.0;
        END IF;

        IF NEW.cost_time IS NULL OR NEW.cost_time < 0 THEN
            IF lower(COALESCE(NEW.edge_type, '')) = 'elevator' THEN
                SELECT avg_time_per_floor INTO v_avg_time FROM vertical_link WHERE id = COALESCE(vlink_a, vlink_b);
                NEW.cost_time := COALESCE(v_avg_time, 20) * floor_diff + 15;
            ELSIF lower(COALESCE(NEW.edge_type, '')) IN ('stair', 'stairs') THEN
                NEW.cost_time := NEW.cost_distance / stair_speed;
            ELSIF lower(COALESCE(NEW.edge_type, '')) IN ('escalator', 'escalator_stair') THEN
                NEW.cost_time := NEW.cost_distance / escalator_speed;
            ELSE
                SELECT avg_time_per_floor INTO v_avg_time FROM vertical_link WHERE id = COALESCE(vlink_a, vlink_b);
                NEW.cost_time := COALESCE(v_avg_time, 20) * floor_diff;
            END IF;
        END IF;
    END IF;

    IF NEW.cost_least_stairs IS NULL OR NEW.cost_least_stairs < 0 THEN
        NEW.cost_least_stairs := CASE WHEN lower(COALESCE(NEW.edge_type, '')) IN ('stair', 'stairs')
                                       THEN NEW.cost_distance * stair_penalty
                                       ELSE NEW.cost_distance END;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_edge_before_insert
BEFORE INSERT ON edge
FOR EACH ROW EXECUTE FUNCTION trg_fn_edge_before_insert();

CREATE TRIGGER trg_edge_before_update
BEFORE UPDATE OF source, target, edge_type ON edge
FOR EACH ROW EXECUTE FUNCTION trg_fn_edge_before_insert();


-- 5. Bảng Phòng ban & Cảnh quan bản đồ (CẬP NHẬT PolygonZ, GeometryZ)
CREATE TABLE room (
    id            SERIAL PRIMARY KEY,
    floor_id      INT REFERENCES floor(id) ON DELETE CASCADE,
    name          VARCHAR(100) NOT NULL,
    category      VARCHAR(50),
    height        DOUBLE PRECISION NOT NULL DEFAULT 3.5,
    geom_wgs84    geometry(PolygonZ, 4326) NOT NULL, -- < ĐÃ SỬA THÀNH PolygonZ
    node_id       INT
);

CREATE INDEX idx_room_geom   ON room USING GIST (geom_wgs84);
-- Chi muc bieu thuc PHAI dung dung immutable_unaccent() — RoomRepository.search truy van y nguyen
-- bieu thuc nay. Dung unaccent() tran o day se bao loi "functions in index expression must be
-- marked IMMUTABLE".
CREATE INDEX idx_room_name_unaccent ON room
    USING GIN (to_tsvector('simple', immutable_unaccent(name)));
CREATE INDEX idx_room_name_trgm ON room
    USING GIN (immutable_unaccent(name) gin_trgm_ops);

CREATE TABLE drawing_feature (
    id           SERIAL PRIMARY KEY,
    floor_id     INT NOT NULL REFERENCES floor(id) ON DELETE CASCADE,
    layer_name   VARCHAR(120),
    feature_type VARCHAR(50),
    name         VARCHAR(150),
    properties   JSONB NOT NULL DEFAULT '{}'::jsonb,
    style        JSONB NOT NULL DEFAULT '{}'::jsonb,
    geom_wgs84   geometry(GeometryZ, 4326) NOT NULL
);

CREATE INDEX idx_drawing_feature_floor ON drawing_feature (floor_id);
CREATE INDEX idx_drawing_feature_geom ON drawing_feature USING GIST (geom_wgs84);


-- 6. View & Function Tìm đường (Giữ nguyên)
CREATE OR REPLACE VIEW v_edge_distance AS
    SELECT id, source, target, cost_distance AS cost,
           COALESCE(reverse_cost_distance, cost_distance) AS reverse_cost
    FROM edge;

CREATE OR REPLACE VIEW v_edge_time AS
    SELECT id, source, target, cost_time AS cost,
           COALESCE(reverse_cost_time, cost_time) AS reverse_cost
    FROM edge;

CREATE OR REPLACE VIEW v_edge_least_stairs AS
    SELECT id, source, target, cost_least_stairs AS cost,
           COALESCE(reverse_cost_least_stairs, cost_least_stairs) AS reverse_cost
    FROM edge;

CREATE OR REPLACE VIEW v_edge_accessible AS
    SELECT id, source, target, cost_distance AS cost,
           COALESCE(reverse_cost_distance, cost_distance) AS reverse_cost
    FROM edge
    WHERE lower(COALESCE(edge_type, '')) NOT IN (
        'stair', 'stairs', 'escalator', 'escalator_stair', 'motorcycle_lane'
    );

CREATE OR REPLACE FUNCTION fn_find_route(
    p_start_node INT,
    p_end_node   INT,
    p_criteria   VARCHAR DEFAULT 'distance'
)
RETURNS TABLE(seq INT, node BIGINT, edge BIGINT, cost DOUBLE PRECISION, agg_cost DOUBLE PRECISION) AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := CASE p_criteria
        WHEN 'time'          THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_time'
        WHEN 'fastest'       THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_time'
        WHEN 'least_stairs'  THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_least_stairs'
        WHEN 'less_stairs'   THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_least_stairs'
        WHEN 'accessible'    THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_accessible'
        ELSE                      'SELECT id, source, target, cost, reverse_cost FROM v_edge_distance'
    END;

    RETURN QUERY
    SELECT r.seq, r.node, r.edge, r.cost, r.agg_cost
    FROM pgr_dijkstra(v_sql, p_start_node, p_end_node, directed := true) r;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_check_graph_connectivity(p_root_node INT)
RETURNS TABLE(isolated_node_id INT) AS $$
BEGIN
    RETURN QUERY
    SELECT n.id
    FROM node n
    WHERE n.id NOT IN (
        SELECT node FROM pgr_dijkstra(
            'SELECT id, source, target, cost_distance AS cost, COALESCE(reverse_cost_distance, cost_distance) AS reverse_cost FROM edge',
            p_root_node,
            (SELECT array_agg(id) FROM node),
            directed := true
        )
    ) AND n.id <> p_root_node;
END;
$$ LANGUAGE plpgsql;