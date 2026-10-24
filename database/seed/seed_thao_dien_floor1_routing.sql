-- Source: data/processed/02. THAO DIEN/routing_network_floor1.geojson.
-- Import the manually digitized floor 1 pedestrian network and attach searchable rooms.
BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM floor WHERE id = 1 AND level_order = 1) THEN
        RAISE EXCEPTION 'floor id 1 must be configured as Thao Dien floor 1';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM room WHERE floor_id = 1 AND category = 'paid_concourse') THEN
        RAISE EXCEPTION 'floor_1_room_v2.geojson must be seeded before the floor 1 routing network';
    END IF;
END;
$$;

UPDATE room SET node_id = NULL WHERE floor_id = 1;

DELETE FROM edge e
USING node source_node, node target_node
WHERE e.source = source_node.id
  AND e.target = target_node.id
  AND source_node.floor_id = 1
  AND target_node.floor_id = 1;

DELETE FROM node
WHERE floor_id = 1
  AND type IN ('floor1_route', 'room_access');

CREATE TEMP TABLE floor1_route_source (
    route_id INT PRIMARY KEY,
    is_one_way BOOLEAN NOT NULL,
    base_height DOUBLE PRECISION NOT NULL,
    geom geometry(LineStringZ, 4326) NOT NULL
) ON COMMIT DROP;

INSERT INTO floor1_route_source (route_id, is_one_way, base_height, geom) VALUES
    (1, FALSE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73318161242382,10.800439627945195,5],[106.73336018019705,10.800473713904744,5],[106.73337924454731,10.800386914537631,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (2, FALSE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73322215627503,10.80042736660879,5],[106.73333970374337,10.80044874614222,5],[106.73335901978432,10.800383508261062,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (3, FALSE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.7332356548452,10.80039537668919,5],[106.73337958661247,10.800423924101526,5],[106.73338875757112,10.800388516730942,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (4, TRUE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73318052234238,10.80044373671369,5],[106.73339058583598,10.800483710169104,5],[106.73340511743581,10.80041538936533,5],[106.73348045998928,10.800429556031293,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (5, TRUE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73322178867062,10.800429097412895,5],[106.73341491012106,10.800464024143704,5],[106.73342442641815,10.800419020036655,5],[106.73348045998928,10.800429556031293,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (6, TRUE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73323537801062,10.800396756013917,5],[106.73339021497411,10.800427184263203,5],[106.73339386241956,10.800412639901785,5],[106.73348045998928,10.800429556031293,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (7, FALSE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73336956142099,10.800385283695155,5],[106.73336370858138,10.800407921551507,5],[106.73348045998928,10.800429556031293,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (8, TRUE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73348045998928,10.800429556031293,5],[106.73369475089838,10.800509115955009,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (9, FALSE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73372751696178,10.80049768194524,5],[106.73372206367254,10.800522610655738,5],[106.73397883318603,10.800570044739636,5],[106.73397444336868,10.800586695753433,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (10, FALSE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73370975357616,10.80049040433452,5],[106.73397402159894,10.800544251446807,5],[106.7339782491967,10.800530495842478,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (11, TRUE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73367264709607,10.80052565422848,5],[106.73346252272921,10.800494187111322,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (12, TRUE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73346252272921,10.800494187111322,5],[106.7331810887306,10.800441601865787,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (13, TRUE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73346252272921,10.800494187111322,5],[106.73322178867062,10.800429097412895,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (14, TRUE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73346252272921,10.800494187111322,5],[106.73323515136806,10.800397885257548,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (15, FALSE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73317991569213,10.800446023318495,5],[106.73322836474566,10.800455571826127,5],[106.73322162747603,10.800429856370817,5]]}'), 4326))::geometry(LineStringZ, 4326)),
    (16, FALSE, 5, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73323605087589,10.800393403471444,5],[106.73324839941006,10.800395381228993,5],[106.7332362206963,10.800428762288446,5],[106.73322245261004,10.800425971364824,5]]}'), 4326))::geometry(LineStringZ, 4326));

CREATE TEMP TABLE floor1_route_vertex ON COMMIT DROP AS
SELECT r.route_id,
       r.is_one_way,
       (dumped.path)[1]::INT AS vertex_order,
       round(ST_X(dumped.geom)::NUMERIC, 8) AS x_key,
       round(ST_Y(dumped.geom)::NUMERIC, 8) AS y_key,
       ST_SetSRID(ST_MakePoint(
           round(ST_X(dumped.geom)::NUMERIC, 8)::DOUBLE PRECISION,
           round(ST_Y(dumped.geom)::NUMERIC, 8)::DOUBLE PRECISION,
           ST_Z(dumped.geom)
       ), 4326)::geometry(PointZ, 4326) AS geom,
       NULL::INT AS node_id
FROM floor1_route_source r
CROSS JOIN LATERAL ST_DumpPoints(r.geom) AS dumped;

CREATE TEMP TABLE floor1_route_point ON COMMIT DROP AS
SELECT row_number() OVER (ORDER BY x_key, y_key)::INT AS point_id,
       x_key,
       y_key,
       geom,
       NULL::INT AS node_id
FROM (
    SELECT DISTINCT x_key, y_key, geom
    FROM floor1_route_vertex
) points;

WITH matches AS (
    SELECT p.point_id, nearby.id AS node_id
    FROM floor1_route_point p
    CROSS JOIN LATERAL (
        SELECT n.id
        FROM node n
        WHERE n.floor_id = 1
          AND n.type IN ('elevator', 'stair', 'escalator', 'gate')
          AND n.geom_wgs84 IS NOT NULL
          AND EXISTS (
              SELECT 1
              FROM floor1_route_vertex v
              WHERE v.x_key = p.x_key
                AND v.y_key = p.y_key
                AND v.vertex_order IN (
                    1,
                    (SELECT max(last_vertex.vertex_order)
                     FROM floor1_route_vertex last_vertex
                     WHERE last_vertex.route_id = v.route_id)
                )
          )
          AND ST_DWithin(n.geom_wgs84::GEOGRAPHY, p.geom::GEOGRAPHY, 2.0)
        ORDER BY n.geom_wgs84::GEOGRAPHY <-> p.geom::GEOGRAPHY
        LIMIT 1
    ) nearby
)
UPDATE floor1_route_point p
SET node_id = matches.node_id
FROM matches
WHERE p.point_id = matches.point_id;

INSERT INTO node (floor_id, type, geom_wgs84)
SELECT 1, 'floor1_route', geom
FROM floor1_route_point
WHERE node_id IS NULL;

UPDATE floor1_route_point p
SET node_id = n.id
FROM node n
WHERE p.node_id IS NULL
  AND n.floor_id = 1
  AND n.type = 'floor1_route'
  AND ST_DWithin(n.geom_wgs84::GEOGRAPHY, p.geom::GEOGRAPHY, 0.02);

UPDATE floor1_route_vertex v
SET node_id = p.node_id
FROM floor1_route_point p
WHERE v.x_key = p.x_key
  AND v.y_key = p.y_key;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM floor1_route_vertex WHERE node_id IS NULL) THEN
        RAISE EXCEPTION 'Could not resolve all floor 1 route vertices to graph nodes';
    END IF;
END;
$$;

CREATE TEMP TABLE floor1_route_edge_source ON COMMIT DROP AS
SELECT route_id,
       is_one_way,
       source,
       target,
       ST_MakeLine(previous_geom, geom)::geometry(LineStringZ, 4326) AS geom
FROM (
    SELECT route_id,
           is_one_way,
           node_id AS target,
           geom,
           lag(node_id) OVER (PARTITION BY route_id ORDER BY vertex_order) AS source,
           lag(geom) OVER (PARTITION BY route_id ORDER BY vertex_order) AS previous_geom
    FROM floor1_route_vertex
) segments
WHERE source IS NOT NULL;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM floor1_route_edge_source WHERE source = target) THEN
        RAISE EXCEPTION 'A floor 1 route collapsed to a self-loop after snapping';
    END IF;
END;
$$;

INSERT INTO edge (
    source, target, edge_type, geom_wgs84,
    reverse_cost_distance, reverse_cost_time, reverse_cost_least_stairs
)
SELECT source, target, 'corridor', geom,
       CASE WHEN is_one_way THEN -1 ELSE NULL END,
       CASE WHEN is_one_way THEN -1 ELSE NULL END,
       CASE WHEN is_one_way THEN -1 ELSE NULL END
FROM floor1_route_edge_source;

CREATE TEMP TABLE floor1_room_access ON COMMIT DROP AS
SELECT r.id AS room_id,
       nearby.node_id AS route_node_id,
       CASE
           WHEN r.category = 'paid_concourse' THEN
               ST_SetSRID(ST_MakePoint(
                   ST_X(ST_PointOnSurface(r.geom_wgs84)),
                   ST_Y(ST_PointOnSurface(r.geom_wgs84)),
                   ST_Z(nearby.geom_wgs84)
               ), 4326)
           ELSE
               ST_SetSRID(ST_MakePoint(
                   ST_X(ST_ClosestPoint(ST_Boundary(r.geom_wgs84), nearby.geom_wgs84)),
                   ST_Y(ST_ClosestPoint(ST_Boundary(r.geom_wgs84), nearby.geom_wgs84)),
                   ST_Z(nearby.geom_wgs84)
               ), 4326)
       END::geometry(PointZ, 4326) AS geom,
       r.category,
       r.geom_wgs84 AS room_geom
FROM room r
CROSS JOIN LATERAL (
    SELECT n.id AS node_id,
           n.geom_wgs84,
           ST_Distance(n.geom_wgs84::GEOGRAPHY, r.geom_wgs84::GEOGRAPHY) AS distance
    FROM node n
    WHERE n.floor_id = 1
      AND n.type IN ('floor1_route', 'elevator', 'stair', 'escalator', 'gate')
      AND n.geom_wgs84 IS NOT NULL
      AND (
          r.category <> 'paid_concourse'
          OR ST_Covers(r.geom_wgs84, n.geom_wgs84)
      )
    ORDER BY n.geom_wgs84::GEOGRAPHY <-> r.geom_wgs84::GEOGRAPHY
    LIMIT 1
) nearby
WHERE r.floor_id = 1;

DO $$
BEGIN
    IF (SELECT count(*) FROM floor1_room_access) <>
       (SELECT count(*) FROM room WHERE floor_id = 1) THEN
        RAISE EXCEPTION 'Could not find floor 1 route access points for every room';
    END IF;
END;
$$;

INSERT INTO node (floor_id, type, geom_wgs84)
SELECT 1, 'room_access', geom
FROM floor1_room_access;

UPDATE floor1_room_access access
SET geom = n.geom_wgs84
FROM node n
WHERE n.floor_id = 1
  AND n.type = 'room_access'
  AND ST_DWithin(n.geom_wgs84::GEOGRAPHY, access.geom::GEOGRAPHY, 0.02);

CREATE TEMP TABLE floor1_room_access_node ON COMMIT DROP AS
SELECT access.room_id, access.route_node_id, access.category, access.geom, access.room_geom,
       n.id AS access_node_id
FROM floor1_room_access access
JOIN node n
  ON n.floor_id = 1
 AND n.type = 'room_access'
 AND ST_DWithin(n.geom_wgs84::GEOGRAPHY, access.geom::GEOGRAPHY, 0.02);

DO $$
BEGIN
    IF (SELECT count(*) FROM floor1_room_access_node) <>
       (SELECT count(*) FROM room WHERE floor_id = 1) THEN
        RAISE EXCEPTION 'Could not resolve the floor 1 room access graph nodes';
    END IF;
END;
$$;

UPDATE room r
SET node_id = access.access_node_id
FROM floor1_room_access_node access
WHERE r.id = access.room_id;

INSERT INTO edge (source, target, edge_type, geom_wgs84)
SELECT route_node.id,
       access.access_node_id,
       'corridor',
       ST_MakeLine(route_node.geom_wgs84, access_node.geom_wgs84)::geometry(LineStringZ, 4326)
FROM floor1_room_access_node access
JOIN node route_node
  ON route_node.floor_id = 1
 AND route_node.type IN ('floor1_route', 'elevator', 'stair', 'escalator', 'gate')
JOIN node access_node ON access_node.id = access.access_node_id
WHERE route_node.id <> access_node.id
  AND access.category <> 'paid_concourse'
  AND ST_DWithin(
      route_node.geom_wgs84::GEOGRAPHY,
      access.room_geom::GEOGRAPHY,
      5.0
  );

INSERT INTO edge (source, target, edge_type, geom_wgs84)
SELECT route_node.id,
       access.access_node_id,
       'corridor',
       ST_MakeLine(route_node.geom_wgs84, access_node.geom_wgs84)::geometry(LineStringZ, 4326)
FROM floor1_room_access_node access
JOIN node route_node
  ON route_node.floor_id = 1
 AND route_node.type IN ('floor1_route', 'elevator', 'stair', 'escalator', 'gate')
JOIN node access_node ON access_node.id = access.access_node_id
WHERE route_node.id <> access_node.id
  AND access.category = 'paid_concourse'
  AND ST_Covers(access.room_geom, route_node.geom_wgs84);

UPDATE edge e
SET geom_wgs84 = ST_MakeLine(source_node.geom_wgs84, target_node.geom_wgs84)::geometry(LineStringZ, 4326)
FROM node source_node,
     node target_node
WHERE e.source = source_node.id
  AND e.target = target_node.id
  AND source_node.floor_id <> target_node.floor_id
  AND source_node.floor_id IN (0, 1)
  AND target_node.floor_id IN (0, 1)
  AND e.edge_type IN ('elevator', 'stair', 'escalator');

DO $$
DECLARE
    one_way_segment_count INT;
    one_way_edge_count INT;
BEGIN
    SELECT count(*) INTO one_way_segment_count
    FROM floor1_route_edge_source
    WHERE is_one_way;

    SELECT count(*) INTO one_way_edge_count
    FROM edge e
    JOIN node source_node ON source_node.id = e.source
    JOIN node target_node ON target_node.id = e.target
    WHERE source_node.floor_id = 1
      AND target_node.floor_id = 1
      AND e.reverse_cost_distance = -1;

    IF one_way_segment_count <> one_way_edge_count THEN
        RAISE EXCEPTION 'Expected % one-way floor 1 edges, found %',
            one_way_segment_count, one_way_edge_count;
    END IF;

    IF EXISTS (
        SELECT 1 FROM room
        WHERE floor_id = 1
          AND (node_id IS NULL OR NOT EXISTS (
              SELECT 1 FROM node WHERE id = room.node_id AND floor_id = 1
          ))
    ) THEN
        RAISE EXCEPTION 'A floor 1 room is missing its graph access node';
    END IF;

    IF (
        SELECT count(*)
        FROM edge e
        JOIN node source_node ON source_node.id = e.source
        JOIN node target_node ON target_node.id = e.target
        WHERE source_node.floor_id = 0
          AND target_node.floor_id = 1
          AND e.edge_type IN ('stair', 'elevator', 'escalator')
    ) <> 4 THEN
        RAISE EXCEPTION 'Expected four floor transfer edges between floor 0 and floor 1';
    END IF;
END;
$$;

COMMIT;
