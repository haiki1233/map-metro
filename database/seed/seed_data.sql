BEGIN;
-- Tầng trệt (ID 0) giữ dữ liệu định tuyến hiện có của ga Thảo Điền.
INSERT INTO floor (id, name, level_order, description) 
VALUES (0, 'Tầng Trệt - Ga Thảo Điền', 0, 'Dữ liệu từ GeoJSON')
ON CONFLICT (id) DO NOTHING;

-- Tầng 1 (ID 1) chứa các lớp mặt bằng GeoJSON mới.
INSERT INTO floor (id, name, level_order, description)
VALUES (1, 'Tầng 1 - Ga Thảo Điền', 1, 'Mặt bằng từ floor_1_*.geojson')
ON CONFLICT (id) DO NOTHING;

-- Tâm tham chiếu WGS84 cho mặt bằng GeoJSON tầng 1.
INSERT INTO floor_transform (floor_id, origin_lat, origin_lng, scale_x, scale_y, rotation_deg)
VALUES (1, 10.8004929, 106.7336435, 1.0, 1.0, 0.0)
ON CONFLICT (floor_id) DO NOTHING;

-- Tâm tham chiếu tầng trệt hiện có.
INSERT INTO floor_transform (floor_id, origin_lat, origin_lng, scale_x, scale_y, rotation_deg) 
VALUES (0, 10.8005, 106.734, 1.0, 1.0, 11.3487)
ON CONFLICT (floor_id) DO NOTHING;

SELECT setval(pg_get_serial_sequence('floor', 'id'), GREATEST(COALESCE((SELECT max(id) FROM floor), 1), 1));
COMMIT;