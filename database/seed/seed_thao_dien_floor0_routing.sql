-- Generated from routing_network_floor0.geojson; splits every route at each vertex.
BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM floor WHERE id = 0 AND level_order = 0) THEN
        RAISE EXCEPTION 'floor id 0 must be configured as Thao Dien ground floor';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM room WHERE floor_id = 0) THEN
        RAISE EXCEPTION 'floor_0_rooms.geojson must be seeded before floor 0 routing';
    END IF;
END;
$$;

UPDATE room SET node_id = NULL WHERE floor_id = 0;

DELETE FROM edge e
USING node source_node, node target_node
WHERE e.source = source_node.id
  AND e.target = target_node.id
  AND source_node.floor_id = 0
  AND target_node.floor_id = 0;

DELETE FROM node n
WHERE n.floor_id = 0
  AND n.type = 'gate'
  AND NOT EXISTS (
      SELECT 1
      FROM drawing_feature feature
      WHERE feature.floor_id = 0
        AND feature.layer_name = 'gates'
        AND ST_DWithin(n.geom_wgs84::GEOGRAPHY, feature.geom_wgs84::GEOGRAPHY, 0.05)
  );

DELETE FROM node
WHERE floor_id = 0
  AND type IN ('floor0_route', 'room_access', 'turn');

CREATE TEMP TABLE floor0_route_source (
    route_id INT PRIMARY KEY,
    edge_type VARCHAR(50) NOT NULL,
    name TEXT,
    base_height DOUBLE PRECISION NOT NULL,
    geom geometry(LineStringZ, 4326) NOT NULL
) ON COMMIT DROP;

INSERT INTO floor0_route_source (route_id, edge_type, name, base_height, geom) VALUES
    (1, 'stair', 'từ cổng 2 đến thang bộ 1', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73304909541777,10.800537243791343],[106.7330826542478,10.800393956735556],[106.73317367897462,10.800414257214202]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (2, 'corridor', 'cổng 2 đến thang máy', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73304909541777,10.800537243791343],[106.73308933376015,10.800362310908769],[106.73322292400672,10.800390469637213]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (3, 'corridor', 'cổng 2 đến thang cuốn', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73304909541777,10.800537243791343],[106.73307643313342,10.800420003559363],[106.73313329885443,10.80043003576222]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (4, 'gate', 'cổng 1 đến cổng soát vé 1', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73290486820193,10.80061872657166],[106.73293811519656,10.800429173141799]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (6, 'corridor', 'bãi đậu xe cổng 1 đi thang máy', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73292103624367,10.800347576690394],[106.73315350946686,10.800388177647685],[106.73315744695957,10.800376668102762],[106.73322292400672,10.800390469637213]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (7, 'stair', 'bãi đậu xe cổng 1 đi vào thang bộ', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73291416027514,10.80035805435679],[106.73317367897462,10.800414257214202]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (8, 'corridor', 'bãi đậu xe cổng 1 đi vào thang cuốn', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73291579741051,10.800350850961141],[106.73310439540568,10.800388832501834],[106.73309453663141,10.800423197363312],[106.73313329885443,10.80043003576222]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (9, 'stair', 'thang cuốn sang thang bộ 1', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73313040378605,10.800429525016682],[106.73310158244588,10.800424440379997],[106.73310832453056,10.800400095993211],[106.73317367897462,10.800414257214202]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (10, 'corridor', 'thang máy sang thang cuốn', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73322292400672,10.800390469637213],[106.73312079950213,10.800368957678382],[106.73310651180917,10.80042531001414],[106.73313040378605,10.800429525016682]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (11, 'stair', 'thang máy sang thang bộ 1', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.7332219417256,10.800392925340269],[106.73315023519619,10.800379009689584],[106.73314352294115,10.800407495845104],[106.73317367897462,10.800414257214202]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (12, 'gate', 'cổng 3 vào cổng soát vé 2', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73340897406187,10.800569286845645],[106.73343162602436,10.800484703149374],[106.73348404093898,10.800495514225057]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (13, 'motorcycle_lane', 'cổng soát vé 2 vào bãi đậu xe 2', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73348404093898,10.800495514225057],[106.73355277404208,10.80050827789877]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (14, 'corridor', 'bãi đậu xe 2 đi vào thang cuốn', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.7333538293513,10.800457854129231],[106.73321369056322,10.800429695400785],[106.73320452260512,10.800466367233179],[106.73310236535775,10.800446066754533],[106.73310651180917,10.80042531001414],[106.73313040378605,10.800429525016682]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (15, 'corridor', 'bãi đậu xe 2 vào thang máy', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.7333538293513,10.800457854129231],[106.73324710856839,10.800436410233601],[106.73326516209944,10.800372985031405],[106.73319967668446,10.800361197656708],[106.73319371751171,10.800384052066537],[106.7332186019694,10.800389618326811]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (16, 'stair', 'bãi đậu xe 2 vào thang bộ 1', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.7333538293513,10.800457854129231],[106.73321369056322,10.800429695400785],[106.73320452260512,10.800466367233179],[106.73310236535775,10.800446066754533],[106.73311263019657,10.800401765871294],[106.7331708631018,10.800413225818913]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (17, 'motorcycle_lane', 'cổng 4 vào bãi đậu xe cổng 4-1', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73427821295981,10.800631279539052],[106.73421532272818,10.800619897788614],[106.73422449068627,10.800582898529147]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (18, 'motorcycle_lane', 'cổng 4 vào bãi đậu xe cổng 4-2', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73427821295982,10.800631279539058],[106.73421532272818,10.800619897788614],[106.73420749722106,10.800656995276205]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (19, 'corridor', 'cổng 4 vào bể ngăn mùi', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73427821295982,10.80063127953906],[106.73415006651211,10.800604508716093]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (20, 'corridor', 'cổng 4 vào phòng bồn nước chữa cháy', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73427821295982,10.80063127953906],[106.73417653080543,10.8006098867058],[106.73417096454516,10.800630842038595],[106.73408750338376,10.800615583936905],[106.73409405192527,10.80059135433336],[106.73406252859911,10.800585513739575]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (21, 'corridor', 'cổng 4 vào kho phế phẩm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73427821295982,10.80063127953906],[106.73417653080543,10.8006098867058],[106.73418098381362,10.800591223362531],[106.73409378998353,10.800573280358826],[106.73409771910843,10.800556581578006],[106.73389688546541,10.800511972166097]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (22, 'stair', 'cổng 4 vào thang bộ 2', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73427821295981,10.800631279539052],[106.73417653080543,10.8006098867058],[106.73418098381362,10.800591223362531],[106.73409378998353,10.800573280358826],[106.73409771910843,10.800556581578006],[106.73394437645143,10.800522520921403],[106.73393727984183,10.800550065779214],[106.73386838918523,10.800533170542144]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (23, 'corridor', 'cổng 4 vào phòng bơm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73427821295982,10.800631279539058],[106.73417653080543,10.8006098867058],[106.73417096454516,10.800630842038595],[106.73408750338376,10.800615583936905],[106.73408566160651,10.800624088855178],[106.73384476783262,10.800577591469395]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (24, 'corridor', 'cổng 4 vào phòng DB', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73427821295981,10.800631279539052],[106.73417653080543,10.8006098867058],[106.73417096454516,10.800630842038595],[106.73387067298913,10.800571929722144],[106.73387460211403,10.800555558368398],[106.73383553765639,10.800547719636764]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (25, 'corridor', 'phòng bơm sang phòng DB', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73384476783262,10.800577591469395],[106.73386910133917,10.800582276417712],[106.73387460211403,10.800555558368398],[106.73383553765639,10.800547719636764]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (26, 'stair', 'phòng bơm sang thang bộ 2', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73384476783262,10.800577591469395],[106.73388834609274,10.800586002957745],[106.7338962777864,10.800539841868801],[106.73386838918523,10.800533170542144]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (27, 'stair', 'phòng DB sang thang bộ 2', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73383553765639,10.800547719636764],[106.73388432669817,10.800558046814166],[106.73388989295844,10.80053840118967],[106.73386838918523,10.800533170542144]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (28, 'stair', 'kho phế phẩm sang thang bộ 2', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73389688546541,10.800511972166097],[106.73392708727117,10.800518680627752],[106.73391837911396,10.800544851503046],[106.73387171493057,10.800533966104942]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (29, 'corridor', 'kho phế phẩm sang phòng DB', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73389688546541,10.800511972166097],[106.73392708727117,10.800518680627752],[106.73391042263609,10.800566167005627],[106.73383553765639,10.800547719636764]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (30, 'corridor', 'phòng bơm sang kho phế phẩm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73384068066912,10.8005756623908],[106.73390056179558,10.800588360836231],[106.73392155515663,10.800517052944386],[106.73389688546541,10.800511972166097]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (31, 'stair', 'phòng bồn nước sang thang bộ', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73406252859911,10.800585513739575],[106.73409405192527,10.80059135433336],[106.73410036308226,10.80057107841175],[106.73393062488658,10.800531590706512],[106.73392784175645,10.800547798346722],[106.73386838918523,10.800533170542144]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (32, 'corridor', 'phòng bồn nước sang phòng bơm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73406252859911,10.800585513739575],[106.73409405192527,10.80059135433336],[106.73408566160651,10.800624088855178],[106.73384068066912,10.8005756623908]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (33, 'corridor', 'phòng bồn nước sang kho phế phẩm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73406252859911,10.800585513739575],[106.73409405192527,10.80059135433336],[106.734103637353,10.800558701668319],[106.73389688546541,10.800511972166097]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (34, 'corridor', 'phòng bồn nước sang phòng DB', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73406252859911,10.800585513739575],[106.73409405192527,10.80059135433336],[106.73408566160651,10.800624088855178],[106.73391929590981,10.800592099229963],[106.73392387988886,10.800569834188867],[106.73383553765639,10.800547719636764]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (35, 'corridor', 'phòng bồn nước sang bể ngăn mùi', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73405371912715,10.80058224650956],[106.73410239313013,10.800592295686206],[106.73409584458864,10.800616852716827],[106.73417096454516,10.800630842038595],[106.73417653080543,10.8006098867058],[106.73415006651211,10.800604508716093]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (36, 'corridor', 'bể ngăn mùi sang kho phế phẩm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73415006651211,10.800604508716093],[106.73417653080543,10.8006098867058],[106.73418098381362,10.800591223362531],[106.73393062488658,10.800531590706512],[106.73393412835637,10.800519672360986],[106.73389688546541,10.800511972166097]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (37, 'stair', 'bể ngăn mùi sang thang bộ 2', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73415006651211,10.800604508716093],[106.73417653080543,10.8006098867058],[106.73418098381362,10.800591223362531],[106.73391802231542,10.800529125020816],[106.7339134808852,10.800543817883089],[106.73387171493057,10.800533966104942]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (38, 'corridor', 'bể ngăn mùi sang phòng bơm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73415006651211,10.800604508716093],[106.73417653080543,10.8006098867058],[106.73417096454516,10.800630842038595],[106.73408750338376,10.800615583936905],[106.73408566160651,10.800624088855178],[106.73384068066912,10.8005756623908]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (39, 'corridor', 'bể ngăn mùi sang phòng DB', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.7341548988001,10.800605844277163],[106.73417653080543,10.8006098867058],[106.73417096454516,10.800630842038595],[106.73387067298913,10.800571929722144],[106.73387460211403,10.800555558368398],[106.73383553765639,10.800547719636764]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (40, 'corridor', 'bãi đậu xe cổng 4-1 sang bể ngăn mùi', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73422449068627,10.800582898529147],[106.73421579320502,10.800617963408978],[106.73415006651211,10.800604508716093]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (41, 'corridor', 'bãi đậu xe cổng 4-2 sang bể ngăn mùi', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73420749722106,10.800656995276205],[106.73421579320502,10.800617963408978],[106.73415006651211,10.800604508716093]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (42, 'corridor', 'bãi đậu xe cổng 4-2 sang phòng bồn nước', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73420749722106,10.800656995276205],[106.73421193298934,10.800635928772397],[106.73408878008918,10.800609481620302],[106.73409405192527,10.80059135433336],[106.73406252859911,10.800585513739575]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (43, 'corridor', 'bãi đậu xe cổng 4-2 sang phòng bồn nước', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73422449068627,10.800582898529147],[106.73421994727785,10.80060280304654],[106.7340983972354,10.8005782258951],[106.73409405192527,10.80059135433336],[106.73406252859911,10.800585513739575]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (44, 'stair', 'bãi đậu xe cổng 4-1 sang thang bộ 2', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73422449068627,10.800582898529147],[106.73421994727785,10.80060280304654],[106.73391802231542,10.800529125020816],[106.7339134808852,10.800543817883089],[106.73387171493057,10.800533966104942]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (45, 'corridor', 'bãi đậu xe cổng 4-1 sang kho phế phẩm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73422449068627,10.800582898529147],[106.73421994727785,10.80060280304654],[106.73391802231542,10.800529125020816],[106.73392155515663,10.800517052944386],[106.73389688546541,10.800511972166097]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (46, 'corridor', 'bãi đậu xe cổng 4-2 sang phòng bơm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73420749722106,10.800656995276205],[106.73421139870337,10.800639615345112],[106.73387067298913,10.800571929722144],[106.73386910133917,10.800582276417712],[106.73384476783262,10.800577591469395]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (47, 'corridor', 'bãi đậu xe cổng 4-2 sang phòng DB', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73420749722106,10.800656995276205],[106.73421139870337,10.800639615345112],[106.73387067298913,10.800571929722144],[106.73387460211403,10.800555558368398],[106.73383553765639,10.800547719636764]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (48, 'corridor', 'bãi đậu xe cổng 4-1 sang phòng bơm', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73422449068627,10.800582898529147],[106.73421994727785,10.80060280304654],[106.73391802231542,10.800529125020816],[106.73390056179558,10.800588360836231],[106.73384068066912,10.8005756623908]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (49, 'corridor', 'bãi đậu xe cổng 4-1 sang phòng DB', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73422449068627,10.800582898529147],[106.73421994727785,10.80060280304654],[106.73391802231542,10.800529125020816],[106.73390701602563,10.800565349604886],[106.73383553765639,10.800547719636764]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326)),
    (50, 'motorcycle_lane', 'cổng soát vé 1 vào bãi đậu xe cổng 1', 0, ST_Translate(ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON('{"type":"LineString","coordinates":[[106.73293811519656,10.800429173141799],[106.7329476142334,10.800387007269356],[106.73289259341286,10.80037588603967]]}'), 4326)), 0, 0, 0)::geometry(LineStringZ, 4326));

CREATE TEMP TABLE floor0_route_vertex ON COMMIT DROP AS
SELECT r.route_id,
       r.edge_type,
       r.name,
       (dumped.path)[1]::INT AS vertex_order,
       round(ST_X(dumped.geom)::NUMERIC, 8) AS x_key,
       round(ST_Y(dumped.geom)::NUMERIC, 8) AS y_key,
       ST_SetSRID(ST_MakePoint(
           round(ST_X(dumped.geom)::NUMERIC, 8)::DOUBLE PRECISION,
           round(ST_Y(dumped.geom)::NUMERIC, 8)::DOUBLE PRECISION,
           ST_Z(dumped.geom)
       ), 4326)::geometry(PointZ, 4326) AS geom,
       NULL::INT AS node_id
FROM floor0_route_source r
CROSS JOIN LATERAL ST_DumpPoints(r.geom) AS dumped;

CREATE TEMP TABLE floor0_route_coordinate ON COMMIT DROP AS
WITH endpoint_points AS (
    SELECT DISTINCT v.x_key,
           v.y_key,
           ST_SetSRID(ST_MakePoint(v.x_key::DOUBLE PRECISION, v.y_key::DOUBLE PRECISION), 4326) AS geom
    FROM floor0_route_vertex v
    WHERE v.vertex_order = 1
       OR v.vertex_order = (
           SELECT max(last_vertex.vertex_order)
           FROM floor0_route_vertex last_vertex
           WHERE last_vertex.route_id = v.route_id
       )
),
endpoint_clusters AS (
    SELECT x_key,
           y_key,
           geom,
           ST_ClusterDBSCAN(geom, eps := 0.000014, minpoints := 1) OVER () AS cluster_id
    FROM endpoint_points
),
route_coordinates AS (
    SELECT DISTINCT x_key, y_key, geom
    FROM floor0_route_vertex
)
SELECT route_coordinates.x_key,
       route_coordinates.y_key,
       COALESCE('endpoint:' || nearest.cluster_id::TEXT,
                'vertex:' || route_coordinates.x_key::TEXT || ':' || route_coordinates.y_key::TEXT) AS group_key
FROM route_coordinates
LEFT JOIN LATERAL (
    SELECT cluster_id
    FROM endpoint_clusters
    WHERE ST_DWithin(route_coordinates.geom, endpoint_clusters.geom, 0.000014)
    ORDER BY ST_Distance(route_coordinates.geom, endpoint_clusters.geom)
    LIMIT 1
) nearest ON TRUE;

CREATE TEMP TABLE floor0_route_point ON COMMIT DROP AS
SELECT row_number() OVER (ORDER BY coordinates.group_key)::INT AS point_id,
       coordinates.group_key,
       ST_SetSRID(ST_MakePoint(
           avg(coordinates.x_key)::DOUBLE PRECISION,
           avg(coordinates.y_key)::DOUBLE PRECISION,
           max(ST_Z(vertex.geom))
       ), 4326)::geometry(PointZ, 4326) AS geom,
       NULL::INT AS node_id
FROM floor0_route_coordinate coordinates
JOIN floor0_route_vertex vertex
  ON vertex.x_key = coordinates.x_key
 AND vertex.y_key = coordinates.y_key
GROUP BY coordinates.group_key;

WITH matches AS (
    SELECT p.point_id, nearby.id AS node_id
    FROM floor0_route_point p
    CROSS JOIN LATERAL (
        SELECT n.id
        FROM node n
        WHERE n.floor_id = 0
          AND n.type IN ('gate', 'parking', 'elevator', 'stair', 'escalator')
          AND n.geom_wgs84 IS NOT NULL
          AND EXISTS (
              SELECT 1
              FROM floor0_route_vertex v
              JOIN floor0_route_coordinate coordinate
                ON coordinate.x_key = v.x_key
               AND coordinate.y_key = v.y_key
              WHERE coordinate.group_key = p.group_key
                AND v.vertex_order IN (
                    1,
                    (SELECT max(last_vertex.vertex_order)
                     FROM floor0_route_vertex last_vertex
                     WHERE last_vertex.route_id = v.route_id)
                )
          )
          AND ST_DWithin(
              n.geom_wgs84::GEOGRAPHY,
              p.geom::GEOGRAPHY,
              CASE WHEN n.type = 'parking' THEN 5.0 ELSE 2.0 END
          )
        ORDER BY n.geom_wgs84::GEOGRAPHY <-> p.geom::GEOGRAPHY
        LIMIT 1
    ) nearby
)
UPDATE floor0_route_point p
SET node_id = matches.node_id
FROM matches
WHERE p.point_id = matches.point_id;

INSERT INTO node (floor_id, type, geom_wgs84)
SELECT 0, 'floor0_route', geom
FROM floor0_route_point
WHERE node_id IS NULL;

UPDATE floor0_route_point p
SET node_id = n.id
FROM node n
WHERE p.node_id IS NULL
  AND n.floor_id = 0
  AND n.type = 'floor0_route'
  AND ST_DWithin(n.geom_wgs84::GEOGRAPHY, p.geom::GEOGRAPHY, 0.02);

UPDATE floor0_route_vertex v
SET node_id = p.node_id,
    geom = n.geom_wgs84
FROM floor0_route_coordinate coordinate
JOIN floor0_route_point p ON p.group_key = coordinate.group_key
JOIN node n ON n.id = p.node_id
WHERE v.x_key = coordinate.x_key
  AND v.y_key = coordinate.y_key;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM floor0_route_vertex WHERE node_id IS NULL) THEN
        RAISE EXCEPTION 'Could not resolve all floor 0 route vertices to graph nodes';
    END IF;
END;
$$;

CREATE TEMP TABLE floor0_route_edge_source ON COMMIT DROP AS
SELECT route_id,
       edge_type,
       name,
       source,
       target,
       ST_MakeLine(previous_geom, geom)::geometry(LineStringZ, 4326) AS geom
FROM (
    SELECT route_id,
           edge_type,
           name,
           node_id AS target,
           geom,
           lag(node_id) OVER (PARTITION BY route_id ORDER BY vertex_order) AS source,
           lag(geom) OVER (PARTITION BY route_id ORDER BY vertex_order) AS previous_geom
    FROM floor0_route_vertex
) segments
WHERE source IS NOT NULL;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM floor0_route_edge_source WHERE source = target) THEN
        RAISE EXCEPTION 'A floor 0 route collapsed to a self-loop';
    END IF;
END;
$$;

INSERT INTO edge (source, target, edge_type, geom_wgs84)
SELECT source, target, edge_type, geom
FROM floor0_route_edge_source;

CREATE TEMP TABLE floor0_room_access ON COMMIT DROP AS
SELECT r.id AS room_id,
       nearby.node_id AS route_node_id,
       CASE
           WHEN r.category = 'parking' AND ST_Covers(r.geom_wgs84, nearby.geom_wgs84) THEN
               ST_Force3DZ(nearby.geom_wgs84)
           ELSE
               ST_SetSRID(ST_MakePoint(
                   ST_X(ST_ClosestPoint(ST_Boundary(r.geom_wgs84), nearby.geom_wgs84)),
                   ST_Y(ST_ClosestPoint(ST_Boundary(r.geom_wgs84), nearby.geom_wgs84)),
                   0
               ), 4326)
       END::geometry(PointZ, 4326) AS geom,
       nearby.distance
FROM room r
CROSS JOIN LATERAL (
    SELECT n.id AS node_id,
           n.geom_wgs84,
           ST_Distance(n.geom_wgs84::GEOGRAPHY, r.geom_wgs84::GEOGRAPHY) AS distance
    FROM node n
    WHERE n.floor_id = 0
      AND n.type IN ('floor0_route', 'gate', 'parking', 'elevator', 'stair', 'escalator')
      AND n.geom_wgs84 IS NOT NULL
    ORDER BY
        CASE WHEN r.category = 'parking' AND ST_Covers(r.geom_wgs84, n.geom_wgs84) THEN 0 ELSE 1 END,
        n.geom_wgs84::GEOGRAPHY <-> r.geom_wgs84::GEOGRAPHY
    LIMIT 1
) nearby
WHERE r.floor_id = 0;

DO $$
BEGIN
    IF (SELECT count(*) FROM floor0_room_access) <> (SELECT count(*) FROM room WHERE floor_id = 0) THEN
        RAISE EXCEPTION 'Could not find floor 0 access points for all rooms';
    END IF;
    IF EXISTS (SELECT 1 FROM floor0_room_access WHERE distance > 20) THEN
        RAISE EXCEPTION 'A floor 0 room is more than 20m from the routing graph';
    END IF;
END;
$$;

INSERT INTO node (floor_id, type, geom_wgs84)
SELECT 0, 'room_access', geom
FROM floor0_room_access;

UPDATE floor0_room_access access
SET geom = n.geom_wgs84
FROM node n
WHERE n.floor_id = 0
  AND n.type = 'room_access'
  AND ST_DWithin(n.geom_wgs84::GEOGRAPHY, access.geom::GEOGRAPHY, 0.02);

CREATE TEMP TABLE floor0_room_access_node ON COMMIT DROP AS
SELECT access.room_id, access.route_node_id, access.geom, n.id AS access_node_id
FROM floor0_room_access access
JOIN node n
  ON n.floor_id = 0
 AND n.type = 'room_access'
 AND ST_DWithin(n.geom_wgs84::GEOGRAPHY, access.geom::GEOGRAPHY, 0.02);

DO $$
BEGIN
    IF (SELECT count(*) FROM floor0_room_access_node) <> (SELECT count(*) FROM room WHERE floor_id = 0) THEN
        RAISE EXCEPTION 'Could not resolve all floor 0 room access nodes';
    END IF;
END;
$$;

UPDATE room r
SET node_id = access.access_node_id
FROM floor0_room_access_node access
WHERE r.id = access.room_id;

DELETE FROM node n
WHERE n.floor_id = 0
  AND n.type = 'room'
  AND NOT EXISTS (SELECT 1 FROM room r WHERE r.node_id = n.id);

INSERT INTO edge (source, target, edge_type, geom_wgs84)
SELECT access.route_node_id,
       access.access_node_id,
       'corridor',
       ST_MakeLine(route_node.geom_wgs84, access_node.geom_wgs84)::geometry(LineStringZ, 4326)
FROM floor0_room_access_node access
JOIN node route_node ON route_node.id = access.route_node_id
JOIN node access_node ON access_node.id = access.access_node_id
WHERE access.route_node_id <> access.access_node_id;

DO $$
DECLARE
    route_count INT;
    edge_count INT;
BEGIN
    SELECT count(*) INTO route_count FROM floor0_route_source;
    SELECT count(DISTINCT route_id) INTO edge_count FROM floor0_route_edge_source;
    IF route_count <> edge_count THEN
        RAISE EXCEPTION 'Expected graph edges for % floor 0 routes, found %',
            route_count, edge_count;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM room
        WHERE floor_id = 0
          AND (node_id IS NULL OR NOT EXISTS (
              SELECT 1 FROM node WHERE id = room.node_id AND floor_id = 0
          ))
    ) THEN
        RAISE EXCEPTION 'A floor 0 room is missing its graph access node';
    END IF;
END;
$$;

COMMIT;
