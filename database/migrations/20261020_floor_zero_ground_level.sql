BEGIN;

DO $$
DECLARE
    legacy_floor_order INT;
    legacy_floor_description VARCHAR(255);
    legacy_floor_exists BOOLEAN;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM floor WHERE id = 1) THEN
        RAISE EXCEPTION 'Cannot migrate ground floor: floor id 1 does not exist';
    END IF;

    SELECT name = 'Tầng Trệt - Ga Thảo Điền'
    INTO legacy_floor_exists
    FROM floor
    WHERE id = 1;

    IF legacy_floor_exists THEN
        SELECT level_order, description
        INTO legacy_floor_order, legacy_floor_description
        FROM floor
        WHERE id = 1;

        IF NOT EXISTS (SELECT 1 FROM floor WHERE id = 0) THEN
            UPDATE floor SET level_order = -2147483648 WHERE id = 1;

            INSERT INTO floor (id, name, level_order, description)
            VALUES (0, 'Tầng Trệt - Ga Thảo Điền', legacy_floor_order, legacy_floor_description);
        END IF;

        IF EXISTS (SELECT 1 FROM floor WHERE level_order = 1 AND id <> 1) THEN
            RAISE EXCEPTION 'Cannot assign floor id 1 to level_order 1: that order is already in use';
        END IF;

        INSERT INTO floor_transform (floor_id, origin_lat, origin_lng, scale_x, scale_y, rotation_deg)
        SELECT 0, origin_lat, origin_lng, scale_x, scale_y, rotation_deg
        FROM floor_transform
        WHERE floor_id = 1
        ON CONFLICT (floor_id) DO NOTHING;

        UPDATE node SET floor_id = 0 WHERE floor_id = 1;
        UPDATE room SET floor_id = 0 WHERE floor_id = 1;
        UPDATE drawing_feature
        SET floor_id = 0
        WHERE floor_id = 1
          AND COALESCE(properties->>'_source_file', '') NOT IN (
              'floor_1_walls.geojson',
              'floor_1_room.geojson',
              'floor_1_vertical.geojson',
              'floor_1_gates.geojson'
          );

        UPDATE floor
        SET name = 'Tầng 1 - Ga Thảo Điền',
            level_order = 1,
            description = 'Mặt bằng từ floor_1_*.geojson'
        WHERE id = 1;

        INSERT INTO floor_transform (floor_id, origin_lat, origin_lng, scale_x, scale_y, rotation_deg)
        VALUES (1, 10.8004929, 106.7336435, 1.0, 1.0, 0.0)
        ON CONFLICT (floor_id) DO UPDATE
        SET origin_lat = EXCLUDED.origin_lat,
            origin_lng = EXCLUDED.origin_lng,
            scale_x = EXCLUDED.scale_x,
            scale_y = EXCLUDED.scale_y,
            rotation_deg = EXCLUDED.rotation_deg;
    END IF;

    PERFORM setval(
        pg_get_serial_sequence('floor', 'id'),
        GREATEST(COALESCE((SELECT max(id) FROM floor), 1), 1)
    );
END;
$$;

COMMIT;
