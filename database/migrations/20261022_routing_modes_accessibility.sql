BEGIN;

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
    IF NEW.source IS NULL OR NEW.target IS NULL THEN
        IF NEW.geom_wgs84 IS NOT NULL AND (NEW.cost_distance IS NULL OR NEW.cost_distance < 0) THEN
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
        END IF;
        IF NEW.cost_least_stairs IS NULL OR NEW.cost_least_stairs < 0 THEN
            NEW.cost_least_stairs := CASE
                WHEN lower(COALESCE(NEW.edge_type, '')) IN ('stair', 'stairs')
                    THEN NEW.cost_distance * stair_penalty
                ELSE NEW.cost_distance
            END;
        END IF;
        RETURN NEW;
    END IF;

    SELECT geom_local, floor_id, vertical_link_id
    INTO p1, floor_a, vlink_a FROM node WHERE id = NEW.source;
    SELECT geom_local, floor_id, vertical_link_id
    INTO p2, floor_b, vlink_b FROM node WHERE id = NEW.target;

    IF floor_a = floor_b THEN
        IF NEW.geom_local IS NULL AND NEW.geom_wgs84 IS NULL AND p1 IS NOT NULL AND p2 IS NOT NULL THEN
            NEW.geom_local := ST_MakeLine(p1, p2);
            NEW.geom_wgs84 := ST_MakeLine(
                fn_local_to_wgs84(floor_a, ST_X(p1), ST_Y(p1), ST_Z(p1)),
                fn_local_to_wgs84(floor_b, ST_X(p2), ST_Y(p2), ST_Z(p2))
            );
        END IF;

        IF NEW.cost_distance IS NULL OR NEW.cost_distance < 0 THEN
            IF NEW.geom_local IS NOT NULL THEN
                NEW.cost_distance := ST_3DLength(NEW.geom_local);
            ELSIF NEW.geom_wgs84 IS NOT NULL THEN
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
        NEW.geom_local := NULL;
        NEW.geom_wgs84 := NULL;
        floor_diff := ABS(floor_b - floor_a);

        IF NEW.cost_distance IS NULL OR NEW.cost_distance < 0 THEN
            NEW.cost_distance := floor_diff * 5.0;
        END IF;

        IF NEW.cost_time IS NULL OR NEW.cost_time < 0 THEN
            IF lower(COALESCE(NEW.edge_type, '')) = 'elevator' THEN
                SELECT avg_time_per_floor INTO v_avg_time
                FROM vertical_link WHERE id = COALESCE(vlink_a, vlink_b);
                NEW.cost_time := COALESCE(v_avg_time, 20) * floor_diff + 15;
            ELSIF lower(COALESCE(NEW.edge_type, '')) IN ('stair', 'stairs') THEN
                NEW.cost_time := NEW.cost_distance / stair_speed;
            ELSIF lower(COALESCE(NEW.edge_type, '')) IN ('escalator', 'escalator_stair') THEN
                NEW.cost_time := NEW.cost_distance / escalator_speed;
            ELSE
                SELECT avg_time_per_floor INTO v_avg_time
                FROM vertical_link WHERE id = COALESCE(vlink_a, vlink_b);
                NEW.cost_time := COALESCE(v_avg_time, 20) * floor_diff;
            END IF;
        END IF;
    END IF;

    IF NEW.cost_least_stairs IS NULL OR NEW.cost_least_stairs < 0 THEN
        NEW.cost_least_stairs := CASE
            WHEN lower(COALESCE(NEW.edge_type, '')) IN ('stair', 'stairs')
                THEN NEW.cost_distance * stair_penalty
            ELSE NEW.cost_distance
        END;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

WITH edge_times AS (
    SELECT e.id,
           CASE lower(COALESCE(e.edge_type, ''))
               WHEN 'stair' THEN e.cost_distance / 0.6
               WHEN 'stairs' THEN e.cost_distance / 0.6
               WHEN 'escalator' THEN e.cost_distance / 0.8
               WHEN 'escalator_stair' THEN e.cost_distance / 0.8
               WHEN 'elevator' THEN COALESCE(vl.avg_time_per_floor, 20)
                                    * GREATEST(ABS(target_node.floor_id - source_node.floor_id), 1)
                                    + 15
               ELSE e.cost_distance / 1.2
           END AS cost_time
    FROM edge e
    LEFT JOIN node source_node ON source_node.id = e.source
    LEFT JOIN node target_node ON target_node.id = e.target
    LEFT JOIN vertical_link vl ON vl.id = COALESCE(source_node.vertical_link_id, target_node.vertical_link_id)
    WHERE e.cost_distance IS NOT NULL
)
UPDATE edge e
SET cost_time = round(edge_times.cost_time::numeric, 2)
FROM edge_times
WHERE e.id = edge_times.id;

UPDATE edge
SET cost_least_stairs = CASE
    WHEN lower(COALESCE(edge_type, '')) IN ('stair', 'stairs') THEN cost_distance * 10
    ELSE cost_distance
END
WHERE cost_distance IS NOT NULL;

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
        WHEN 'time' THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_time'
        WHEN 'fastest' THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_time'
        WHEN 'least_stairs' THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_least_stairs'
        WHEN 'less_stairs' THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_least_stairs'
        WHEN 'accessible' THEN 'SELECT id, source, target, cost, reverse_cost FROM v_edge_accessible'
        ELSE 'SELECT id, source, target, cost, reverse_cost FROM v_edge_distance'
    END;

    RETURN QUERY
    SELECT r.seq, r.node, r.edge, r.cost, r.agg_cost
    FROM pgr_dijkstra(v_sql, p_start_node, p_end_node, directed := true) r;
END;
$$ LANGUAGE plpgsql;

COMMIT;
