-- Generated from floor_1_walls_v1.geojson, floor_1_vertical_v1.geojson, floor_1_gates_v1.geojson, and floor_1_room_v2.geojson.
-- GeoJSON geometries are stored with Z offset by each feature's base_height.
BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM floor WHERE id = 1 AND level_order = 1) THEN
        RAISE EXCEPTION 'floor id 1 must be configured as Thao Dien floor 1 before loading this seed';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM floor WHERE id = 0 AND level_order = 0) THEN
        RAISE EXCEPTION 'floor id 0 must be configured as Thao Dien ground floor before loading vertical links';
    END IF;
END;
$$;

CREATE TEMP TABLE floor1_source_feature (
    source_layer VARCHAR(20) NOT NULL,
    source_file VARCHAR(120) NOT NULL,
    feature JSONB NOT NULL
) ON COMMIT DROP;

INSERT INTO floor1_source_feature (source_layer, source_file, feature) VALUES
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":1,"type":"outer_wall","name":"tường","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73300671444291,10.800463591462444],[106.73303251569578,10.80029471053452],[106.73304307075378,10.80029471053452],[106.73301492393246,10.800465937030888],[106.73300671444291,10.800463591462444]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":2,"type":"barrier","name":"hàng rào ngoài mép ga","level":1,"height":6.2,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73301492393246,10.800465937030888],[106.73322391408074,10.800517774093489],[106.73322508686496,10.800511910172382],[106.73301656583034,10.800460190388204],[106.73301492393246,10.800465937030888]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":3,"type":"barrier","name":"Hàng rào ngoài mép ga","level":1,"height":6.2,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73304307075378,10.80029471053452],[106.73329627486723,10.800327783049573],[106.73329510208299,10.800333529692264],[106.73304122361861,10.800299900104704],[106.73304307075378,10.80029471053452]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":4,"type":"outer_wall","name":"tường","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73322391408074,10.800517774093489],[106.73348521040532,10.80056761742291],[106.73348814236587,10.80056116710969],[106.73322508686496,10.800511910172382],[106.73322391408074,10.800517774093489]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":5,"type":"outer_wall","name":"tường","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73329510208299,10.800333529692264],[106.73353352911515,10.800379620112166],[106.73353540556992,10.800368830497323],[106.73329627486723,10.800327783049573],[106.73329510208299,10.800333529692264]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":6,"type":"barrier","name":"Hàng rào ngoài mép ga","level":1,"height":6.2,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73348521040532,10.80056761742291],[106.73381980574369,10.800631768719834],[106.73382273770424,10.800621213661838],[106.73348814236587,10.80056116710969],[106.73348521040532,10.80056761742291]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":7,"type":"barrier","name":"Hàng rào ngoài mép ga","level":1,"height":6.2,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73353352911515,10.800379620112166],[106.73389685766706,10.800448345267556],[106.7338990859571,10.800440370334849],[106.73353540556992,10.800368830497323],[106.73353352911515,10.800379620112166]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":8,"type":"outer_wall","name":"tường","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73424974843938,10.80069111160145],[106.73428024082914,10.8005316129473],[106.73427203133959,10.800528094594634],[106.73424153894983,10.800687593248787],[106.73424974843938,10.80069111160145]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":9,"type":"outer_wall","name":"tường","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73389685766706,10.800448345267556],[106.73406597315183,10.800478251265213],[106.73406831872028,10.800471507755939],[106.7338990859571,10.800440370334849],[106.73389685766706,10.800448345267556]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":10,"type":"outer_wall","name":"tường","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73381980574369,10.800631768719834],[106.73404204835373,10.800673050724438],[106.73404556670638,10.800663082058554],[106.73382273770424,10.800621213661838],[106.73381980574369,10.800631768719834]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":11,"type":"barrier","name":"Hàng rào ngoài mép ga","level":1,"height":6.2,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73404204835373,10.800673050724438],[106.73424974843938,10.80069111160145],[106.73424153894983,10.800687593248787],[106.73404556670638,10.800663082058554],[106.73404204835373,10.800673050724438]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":13,"type":"column","name":"cột","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73322220957016,10.800489114593411],[106.73322642787522,10.800470835271465],[106.73324611329886,10.800476459678217],[106.7332418949938,10.800493332898476],[106.73322220957016,10.800489114593411]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":14,"type":"column","name":"cột","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73325019099376,10.800362424831304],[106.73325581540051,10.800339927204293],[106.73328323438342,10.800345200085623],[106.73327444624788,10.80036664313637],[106.73325019099376,10.800362424831304]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":15,"type":"column","name":"cột","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73348585363667,10.800535656559285],[106.73349147804342,10.80051948638987],[106.73351608482297,10.80052440774578],[106.73350835126368,10.800541280966039],[106.73348585363667,10.800535656559285]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":16,"type":"column","name":"cột","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73352592753479,10.800409107407347],[106.73353225499237,10.800389421983711],[106.73356178312783,10.800396452492153],[106.73355404956854,10.800417544017476],[106.73352592753479,10.800409107407347]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":17,"type":"column","name":"cột","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73381741241474,10.800593447338674],[106.73382127919437,10.80057762869468],[106.73384483139766,10.800583604626855],[106.73383815241463,10.800597665643739],[106.73381741241474,10.800593447338674]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":18,"type":"column","name":"cột","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73385790814336,10.800472381983305],[106.73386423560096,10.80045621181389],[106.73389798204147,10.800461133169799],[106.73388392102459,10.800479412491747],[106.73385790814336,10.800472381983305]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":19,"type":"column","name":"cột","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73407852549825,10.800644207609626],[106.73408133770162,10.800630146592741],[106.73410383532864,10.800633661846962],[106.73410032007442,10.800647019813002],[106.73407852549825,10.800644207609626]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":20,"type":"column","name":"cột","level":1,"height":10,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.7341080536337,10.80052187676274],[106.73411297498961,10.80050148828826],[106.73414039397254,10.800507815745858],[106.73413195736241,10.800525392016961],[106.7341080536337,10.80052187676274]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":29,"type":"fare_barrier","name":"hàng rào soát vé","level":1,"height":6.2,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73344390174128,10.800552883087251],[106.73345583184656,10.800505860566334],[106.7334629498069,10.800507284158405],[106.73344987055476,10.800554138132442],[106.73344390174128,10.800552883087251]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":30,"type":"fare_barrier","name":"hàng rào soát vé","level":1,"height":6.2,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73346351924371,10.800478527598573],[106.73347206079615,10.800450055757153],[106.7334791787565,10.800451835247243],[106.73347063720406,10.800479951190644],[106.73346351924371,10.800478527598573]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":31,"type":"fare_barrier","name":"hàng rào soát vé","level":1,"height":6.2,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73350152915201,10.800374035940562],[106.73349014041544,10.800412472926478],[106.73348266655707,10.800411049334407],[106.73349619068175,10.800371900552456],[106.73350152915201,10.800374035940562]]]}}$feature$::jsonb),
    ('walls', 'floor_1_walls_v1.geojson', $feature${"type":"Feature","properties":{"fid":32,"type":"barrier","name":"hàng rào ngoài","level":1,"height":6.2,"base_height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73427078076514,10.800534636060945],[106.73406597315183,10.800478251265213],[106.73406831872028,10.800471507755939],[106.73427203133959,10.800528094594634],[106.73427078076514,10.800534636060945]]]}}$feature$::jsonb),
    ('vertical', 'floor_1_vertical_v1.geojson', $feature${"type":"Feature","properties":{"fid":1,"type":"escalator_stair","name":"thang cuốn","level":1,"base_height":5,"height":6.2},"geometry":{"type":"Polygon","coordinates":[[[106.73315794520563,10.800444076670416],[106.73315990264473,10.800435535117991],[106.73318161242382,10.800439627945195],[106.7331792990867,10.800448347446629],[106.73315794520563,10.800444076670416]]]}}$feature$::jsonb),
    ('vertical', 'floor_1_vertical_v1.geojson', $feature${"type":"Feature","properties":{"fid":2,"type":"stairs","name":"thang bộ 1","level":1,"base_height":5,"height":6.2},"geometry":{"type":"Polygon","coordinates":[[[106.73320172066184,10.800429093363869],[106.73320385604994,10.800419128219373],[106.73322307454289,10.800423043097567],[106.73322093915479,10.800433097216569],[106.73320172066184,10.800429093363869]]]}}$feature$::jsonb),
    ('vertical', 'floor_1_vertical_v1.geojson', $feature${"type":"Feature","properties":{"fid":3,"type":"elevator","name":"thang máy","level":1,"base_height":5,"height":10},"geometry":{"type":"Polygon","coordinates":[[[106.73321494308317,10.800387117604792],[106.7332364462829,10.800391433361058],[106.73323473097685,10.800399979851317],[106.7332132277771,10.800395664095051],[106.73321494308317,10.800387117604792]]]}}$feature$::jsonb),
    ('vertical', 'floor_1_vertical_v1.geojson', $feature${"type":"Feature","properties":{"fid":4,"type":"\nstairs","name":"thang bộ 2","level":1,"base_height":5,"height":6.2},"geometry":{"type":"Polygon","coordinates":[[[106.73382244239453,10.800530043836604],[106.73383854677982,10.80053297999525],[106.73384112704045,10.800524438442825],[106.73382457778263,10.800521769207691],[106.73382457778263,10.800521769207691],[106.73382244239453,10.800530043836604]]]}}$feature$::jsonb),
    ('gates', 'floor_1_gates_v1.geojson', $feature${"type":"Feature","properties":{"fid":1,"type":"gate","level":1,"height":7,"base_height":5,"radius":1.2},"geometry":{"type":"Point","coordinates":[106.73346252272921,10.800494187111322]}}$feature$::jsonb),
    ('gates', 'floor_1_gates_v1.geojson', $feature${"type":"Feature","properties":{"fid":2,"type":"gate","level":1,"height":7,"base_height":5,"radius":1.2},"geometry":{"type":"Point","coordinates":[106.73348045998928,10.800429556031293]}}$feature$::jsonb),
    ('room', 'floor_1_room_v2.geojson', $feature${"type":"Feature","properties":{"type":"paid_concourse","name":"khu trong cổng soát vé","level":1,"base_height":5,"height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73352071632458,10.800543473778855],[106.73356574623008,10.800426107852488],[106.73383833430796,10.800466998299964],[106.73378309784967,10.800593643018761],[106.73352071632458,10.800543473778855]]]}}$feature$::jsonb),
    ('room', 'floor_1_room_v2.geojson', $feature${"type":"Feature","properties":{"fid":1,"type":"ticket_counter","name":"quầy bán vé","level":1,"base_height":5,"height":8},"geometry":{"type":"Polygon","coordinates":[[[106.7333381007822,10.800342005118948],[106.7333281356377,10.800378306716757],[106.73342956657277,10.80039538982161],[106.73343941183924,10.800361426265908],[106.7333381007822,10.800342005118948]]]}}$feature$::jsonb),
    ('room', 'floor_1_room_v2.geojson', $feature${"type":"Feature","properties":{"fid":2,"type":"toilet","name":"nhà vệ sinh nam","level":1,"base_height":5,"height":8},"geometry":{"type":"Polygon","coordinates":[[[106.73392550312384,10.800453410864977],[106.73390525986326,10.800517818739705],[106.73404050111,10.800541308008874],[106.73405722017877,10.800476703409366],[106.73392550312384,10.800453410864977]]]}}$feature$::jsonb),
    ('room', 'floor_1_room_v2.geojson', $feature${"type":"Feature","properties":{"fid":3,"type":"toilet","name":"nhà vệ sinh nữ","level":1,"base_height":5,"height":8},"geometry":{"type":"Polygon","coordinates":[[[106.73387577405433,10.800631178912878],[106.73389244753463,10.800571203442365],[106.73404690727433,10.80060038707982],[106.73403124776155,10.800659466150764],[106.73387577405433,10.800631178912878]]]}}$feature$::jsonb);

-- Remove this import's prior records, including the first non-v1 drawing-only import.
DELETE FROM drawing_feature
WHERE floor_id = 1
  AND properties->>'_source_file' IN (
      'floor_1_walls.geojson',
      'floor_1_room.geojson',
      'floor_1_vertical.geojson',
      'floor_1_gates.geojson',
      'floor_1_walls_v1.geojson',
      'floor_1_room_v1.geojson',
      'floor_1_vertical_v1.geojson',
      'floor_1_gates_v1.geojson',
      'floor_1_room_v2.geojson'
  );

DELETE FROM room
WHERE floor_id = 1
  AND name IN (
      SELECT feature->'properties'->>'name'
      FROM floor1_source_feature
      WHERE source_layer = 'room'
  );

INSERT INTO room (floor_id, name, category, height, geom_wgs84)
SELECT
    1,
    btrim(feature->'properties'->>'name'),
    btrim(feature->'properties'->>'type', E' \t\n\r'),
    COALESCE(NULLIF(feature->'properties'->>'height', '')::DOUBLE PRECISION, 3.5),
    ST_Translate(
        ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON((feature->'geometry')::text), 4326)),
        0, 0, COALESCE(NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION, 0)
    )::geometry(PolygonZ, 4326)
FROM floor1_source_feature
WHERE source_layer = 'room';

INSERT INTO drawing_feature (
    floor_id, layer_name, feature_type, name, properties, style, geom_wgs84
)
SELECT
    1,
    source_layer,
    btrim(feature->'properties'->>'type', E' \t\n\r'),
    NULLIF(btrim(feature->'properties'->>'name'), ''),
    jsonb_set(feature->'properties', '{type}', to_jsonb(btrim(feature->'properties'->>'type', E' \t\n\r')))
        || jsonb_build_object(
        '_source_file', source_file,
        '_source_fid', feature->'properties'->'fid'
    ),
    jsonb_strip_nulls(jsonb_build_object(
        'color', CASE btrim(feature->'properties'->>'type', E' \t\n\r')
            WHEN 'outer_wall' THEN '#475569'
            WHEN 'barrier' THEN '#94A3B8'
            WHEN 'fare_barrier' THEN '#F97316'
            WHEN 'column' THEN '#334155'
            WHEN 'gate' THEN '#16A34A'
            WHEN 'elevator' THEN '#EAB308'
            WHEN 'stairs' THEN '#FCA5A5'
            WHEN 'escalator_stair' THEN '#FDBA74'
            ELSE '#64748B'
        END,
        'height', NULLIF(feature->'properties'->>'height', '')::DOUBLE PRECISION,
        'base_height', NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION,
        'radius', NULLIF(feature->'properties'->>'radius', '')::DOUBLE PRECISION,
        'opacity', 0.95
    )),
    ST_Translate(
        ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON((feature->'geometry')::text), 4326)),
        0, 0, COALESCE(NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION, 0)
    )::geometry(GeometryZ, 4326)
FROM floor1_source_feature
WHERE source_layer IN ('walls', 'vertical', 'gates');

CREATE TEMP TABLE floor1_vertical_device ON COMMIT DROP AS
SELECT
    feature->'properties'->>'fid' AS source_fid,
    btrim(feature->'properties'->>'name') AS name,
    'TD_F1:' || (feature->'properties'->>'fid') || ' - ' || btrim(feature->'properties'->>'name') AS link_label,
    CASE btrim(feature->'properties'->>'type', E' \t\n\r')
        WHEN 'elevator' THEN 'elevator'
        WHEN 'escalator_stair' THEN 'escalator'
        WHEN 'stairs' THEN 'stair'
        ELSE NULL
    END AS transfer_type,
    CASE btrim(feature->'properties'->>'type', E' \t\n\r')
        WHEN 'elevator' THEN 'elevator'
        WHEN 'escalator_stair' THEN 'escalator'
        WHEN 'stairs' THEN 'stair'
        ELSE NULL
    END AS node_type,
    ST_Translate(
        ST_Force3DZ(ST_SetSRID(ST_Centroid(ST_GeomFromGeoJSON((feature->'geometry')::text)), 4326)),
        0, 0, COALESCE(NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION, 0)
    )::geometry(PointZ, 4326) AS geom_wgs84
FROM floor1_source_feature
WHERE source_layer = 'vertical';

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM floor1_vertical_device WHERE transfer_type IS NULL OR node_type IS NULL) THEN
        RAISE EXCEPTION 'Unsupported vertical equipment type in floor_1_vertical_v1.geojson';
    END IF;
END;
$$;

INSERT INTO vertical_link (label, transfer_type, avg_time_per_floor)
SELECT link_label, transfer_type, 20
FROM floor1_vertical_device
ON CONFLICT (label) WHERE label LIKE 'TD_F1:%'
DO UPDATE SET transfer_type = EXCLUDED.transfer_type,
              avg_time_per_floor = EXCLUDED.avg_time_per_floor;

DO $$
DECLARE
    device_count INT;
    matched_count INT;
    distinct_node_count INT;
BEGIN
    SELECT count(*) INTO device_count FROM floor1_vertical_device;
    SELECT count(*), count(DISTINCT nearest.id)
    INTO matched_count, distinct_node_count
    FROM floor1_vertical_device device
    CROSS JOIN LATERAL (
        SELECT n.id
        FROM node n
        WHERE n.floor_id = 0
          AND n.type = device.node_type
          AND n.geom_wgs84 IS NOT NULL
          AND ST_DWithin(n.geom_wgs84::geography, device.geom_wgs84::geography, 15)
        ORDER BY n.geom_wgs84::geography <-> device.geom_wgs84::geography
        LIMIT 1
    ) nearest;

    IF device_count = 0 OR matched_count <> device_count OR distinct_node_count <> device_count THEN
        RAISE EXCEPTION 'Expected a unique matching floor 0 transfer node within 15m for each floor 1 vertical device (devices %, matched %, unique %)',
            device_count, matched_count, distinct_node_count;
    END IF;
END;
$$;

WITH floor0_matches AS (
    SELECT device.link_label, nearest.id AS node_id
    FROM floor1_vertical_device device
    CROSS JOIN LATERAL (
        SELECT n.id, ST_Distance(n.geom_wgs84::geography, device.geom_wgs84::geography) AS distance
        FROM node n
        WHERE n.floor_id = 0
          AND n.type = device.node_type
          AND n.geom_wgs84 IS NOT NULL
          AND ST_DWithin(n.geom_wgs84::geography, device.geom_wgs84::geography, 15)
        ORDER BY n.geom_wgs84::geography <-> device.geom_wgs84::geography
        LIMIT 1
    ) nearest
)
UPDATE node n
SET vertical_link_id = link.id
FROM floor0_matches floor_match
JOIN vertical_link link ON link.label = floor_match.link_label
WHERE n.id = floor_match.node_id;

INSERT INTO node (floor_id, type, geom_wgs84, vertical_link_id)
SELECT
    1,
    device.node_type,
    device.geom_wgs84,
    link.id
FROM floor1_vertical_device device
JOIN vertical_link link ON link.label = device.link_label
WHERE NOT EXISTS (
    SELECT 1 FROM node n
    WHERE n.floor_id = 1
      AND n.type = device.node_type
      AND n.vertical_link_id = link.id
);

UPDATE node n
SET geom_wgs84 = device.geom_wgs84
FROM floor1_vertical_device device
JOIN vertical_link link ON link.label = device.link_label
WHERE n.floor_id = 1
  AND n.type = device.node_type
  AND n.vertical_link_id = link.id;

CREATE TEMP TABLE floor1_gate_source ON COMMIT DROP AS
SELECT feature->'properties'->>'fid' AS source_fid,
       ST_Translate(
           ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON((feature->'geometry')::text), 4326)),
           0, 0, COALESCE(NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION, 0)
       )::geometry(PointZ, 4326) AS geom_wgs84
FROM floor1_source_feature
WHERE source_layer = 'gates';

WITH gate_matches AS (
    SELECT gate.source_fid, nearest.id AS node_id, gate.geom_wgs84
    FROM floor1_gate_source gate
    CROSS JOIN LATERAL (
        SELECT n.id
        FROM node n
        WHERE n.floor_id = 1
          AND n.type = 'gate'
          AND n.geom_wgs84 IS NOT NULL
          AND ST_DWithin(n.geom_wgs84::geography, gate.geom_wgs84::geography, 2.0)
        ORDER BY n.geom_wgs84::geography <-> gate.geom_wgs84::geography
        LIMIT 1
    ) nearest
)
UPDATE node n
SET geom_wgs84 = matches.geom_wgs84
FROM gate_matches matches
WHERE n.id = matches.node_id;

INSERT INTO node (floor_id, type, geom_wgs84)
SELECT 1, 'gate', gate.geom_wgs84
FROM floor1_gate_source gate
WHERE NOT EXISTS (
    SELECT 1 FROM node n
    WHERE n.floor_id = 1
      AND n.type = 'gate'
      AND ST_DWithin(n.geom_wgs84::geography, gate.geom_wgs84::geography, 0.05)
);

INSERT INTO edge (source, target, edge_type)
SELECT lower_floor.id, upper_floor.id, device.transfer_type
FROM floor1_vertical_device device
JOIN vertical_link link ON link.label = device.link_label
JOIN node lower_floor ON lower_floor.floor_id = 0 AND lower_floor.vertical_link_id = link.id
JOIN node upper_floor ON upper_floor.floor_id = 1 AND upper_floor.vertical_link_id = link.id
WHERE NOT EXISTS (
    SELECT 1 FROM edge existing
    WHERE existing.source = lower_floor.id AND existing.target = upper_floor.id
);

COMMIT;
