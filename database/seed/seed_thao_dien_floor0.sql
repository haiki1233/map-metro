-- Generated from floor_0_*.geojson for Thao Dien ground floor (floor id 0).
-- Geometry Z is preserved from coordinates and shifted by each feature's base_height.
BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM floor WHERE id = 0 AND level_order = 0) THEN
        RAISE EXCEPTION 'floor id 0 must be configured as Thao Dien ground floor';
    END IF;
END;
$$;

UPDATE room
SET node_id = NULL
WHERE floor_id = 0;

DELETE FROM edge e
WHERE EXISTS (
    SELECT 1
    FROM node n
    WHERE n.floor_id = 0
      AND n.id IN (e.source, e.target)
);

DELETE FROM node
WHERE floor_id = 0;

CREATE TEMP TABLE floor0_source_feature (
    source_layer VARCHAR(20) NOT NULL,
    source_file VARCHAR(120) NOT NULL,
    feature JSONB NOT NULL
) ON COMMIT DROP;

INSERT INTO floor0_source_feature (source_layer, source_file, feature) VALUES
        ('gates', 'floor_0_gates.geojson', $feature${"type":"Feature","properties":{"fid":1,"level":0,"type":"gate","name":"cổng soát vé xe cổng 1","radius":1.2,"base_height":0,"height":1},"geometry":{"type":"Point","coordinates":[106.73293811519656,10.800429173141799]}}$feature$::jsonb),
        ('gates', 'floor_0_gates.geojson', $feature${"type":"Feature","properties":{"fid":2,"level":0,"type":"gate","name":"cổng 1","radius":1.2,"base_height":0,"height":1},"geometry":{"type":"Point","coordinates":[106.73290486820193,10.80061872657166]}}$feature$::jsonb),
        ('gates', 'floor_0_gates.geojson', $feature${"type":"Feature","properties":{"fid":3,"level":0,"type":"gate","name":"cổng 2","radius":1.2,"base_height":0,"height":1},"geometry":{"type":"Point","coordinates":[106.73304909541777,10.800537243791343]}}$feature$::jsonb),
        ('gates', 'floor_0_gates.geojson', $feature${"type":"Feature","properties":{"fid":4,"level":0,"type":"gate","name":"cổng 3","radius":1.2,"base_height":0,"height":1},"geometry":{"type":"Point","coordinates":[106.73340897406187,10.800569286845645]}}$feature$::jsonb),
        ('gates', 'floor_0_gates.geojson', $feature${"type":"Feature","properties":{"fid":5,"level":0,"type":"gate","name":"cổng soát vé xe cổng 3","radius":1.2,"base_height":0,"height":1},"geometry":{"type":"Point","coordinates":[106.73348404093898,10.800495514225057]}}$feature$::jsonb),
        ('gates', 'floor_0_gates.geojson', $feature${"type":"Feature","properties":{"fid":6,"level":0,"type":"gate","name":"cổng 4","radius":1.2,"base_height":0,"height":1},"geometry":{"type":"Point","coordinates":[106.73427821295981,10.800631279539052]}}$feature$::jsonb),
    ('room', 'floor_0_rooms.geojson', $feature${"type":"Feature","properties":{"fid":1,"level":0,"type":"room","name":"bể ngăn mùi và chắn dầu","height":3,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.7341302874634,10.800614247198896],[106.73416032870657,10.800621243104837],[106.73416567851699,10.800594494052708],[106.73413604879771,10.800587909670645],[106.7341302874634,10.800614247198896]]]}}$feature$::jsonb),
    ('room', 'floor_0_rooms.geojson', $feature${"type":"Feature","properties":{"fid":2,"level":0,"type":"room","name":"phòng bồn nước chữa cháy","height":3,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73403226247548,10.800598444681945],[106.73406888810071,10.800607498207283],[106.73407794162604,10.800574576296968],[106.73404255057245,10.80056634581939],[106.73403226247548,10.800598444681945]]]}}$feature$::jsonb),
    ('room', 'floor_0_rooms.geojson', $feature${"type":"Feature","properties":{"fid":3,"level":0,"type":"room","name":"phòng bơm/khu vực bơm","height":3,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73382131533519,10.800584535174846],[106.7338505335306,10.800591119556907],[106.73385752943655,10.800564370504778],[106.73382831124114,10.80055943221823],[106.73382131533519,10.800584535174846]]]}}$feature$::jsonb),
    ('room', 'floor_0_rooms.geojson', $feature${"type":"Feature","properties":{"fid":4,"level":0,"type":"room","name":"phòng DB","height":3,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73382250875444,10.80055439105071],[106.7338467886633,10.800559843742105],[106.73385110966403,10.800538650262341],[106.73382796144584,10.800533094689976],[106.73382250875444,10.80055439105071]]]}}$feature$::jsonb),
    ('room', 'floor_0_rooms.geojson', $feature${"type":"Feature","properties":{"fid":5,"level":0,"type":"room","name":"kho phế phẩm","height":3,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73387222083903,10.800523506183602],[106.73390534851129,10.800531736661181],[106.73391543084632,10.800502518465777],[106.73388168588825,10.80049408222626],[106.73387222083903,10.800523506183602]]]}}$feature$::jsonb),
    ('room', 'floor_0_rooms.geojson', $feature${"type":"Feature","properties":{"fid":12,"level":0,"type":"parking","name":"bãi đậu xe cổng 3","height":0.1,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.7335317115661,10.800533253074368],[106.73370861411674,10.800568757943422],[106.73372841235636,10.800472670004304],[106.733561354057,10.800437867729954],[106.7333414618346,10.800393734706812],[106.7333223575568,10.80048892152371],[106.73339863538884,10.800504230711898],[106.73340979480028,10.800455571741535],[106.73354812704353,10.800483335434972],[106.7335317115661,10.800533253074368]]]}}$feature$::jsonb),
    ('room', 'floor_0_rooms.geojson', $feature${"type":"Feature","properties":{"fid":13,"level":0,"type":"parking","name":"bãi đậu xe cổng 1","height":0.1,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73291066398178,10.800454878516753],[106.73294967292986,10.800295389828777],[106.73272419309535,10.800250135354094],[106.73269191222221,10.800410974386757],[106.73291066398178,10.800454878516753]]]}}$feature$::jsonb),
    ('room', 'floor_0_rooms.geojson', $feature${"type":"Feature","properties":{"fid":14,"level":0,"type":"parking","name":"bãi đậu xe cổng 4-2","height":0.1,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73415502858039,10.80065792627776],[106.73415941853948,10.800638025129903],[106.73426389956573,10.800657779945789],[106.73425936327467,10.800679144413344],[106.73415502858039,10.80065792627776]]]}}$feature$::jsonb),
    ('room', 'floor_0_rooms.geojson', $feature${"type":"Feature","properties":{"fid":15,"level":0,"type":"parking","name":"bãi đậu xe cổng 4-1","height":0.1,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73417763798919,10.800561557752713],[106.73417361274052,10.800581394657689],[106.73426521655344,10.800598954494033],[106.73426946018056,10.800580224001932],[106.73417763798919,10.800561557752713]]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":1,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73291267363292,10.800638566325057],[106.73290367371554,10.800608896248168],[106.73293165720656,10.80046094278124]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":2,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73290264884014,10.800640968331889],[106.73291174652768,10.80063483306552]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":3,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.7329222624341,10.800636268784702],[106.7329037102396,10.800609033859018]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":4,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73285402414508,10.800652572996471],[106.73290647904467,10.80061815474927]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":5,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73287198029188,10.80062677685247],[106.73290440397558,10.800605233658613]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":6,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73293420107467,10.800633408207247],[106.7329068146574,10.80059225936106]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":7,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73287829724559,10.80061565026356],[106.73290596743982,10.800597424523051]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":8,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73294017039497,10.800631977918517],[106.73290834947177,10.800584161680401]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":9,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73288375497211,10.800598174203923],[106.73290834947177,10.800584161680401]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":10,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73295210903554,10.800629117341057],[106.73291141193802,10.800567981667207]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":11,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73293060540664,10.800586416469983],[106.73291305623577,10.800559762224598]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":12,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.7329309140981,10.80056608615016],[106.73291601126506,10.800543660998555]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":13,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73293412085151,10.800550108542776],[106.73291908089382,10.800527498379928]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":14,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73293893098163,10.800526142131696],[106.73292366359371,10.800503206105343]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":15,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73294213773505,10.800510164524315],[106.73292672631581,10.800487017139076]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":16,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73294694786516,10.800486198113235],[106.73293130472628,10.800462699009652]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":17,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73294855124188,10.800478209309544],[106.73293788978184,10.800462193677676]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":18,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73295015461858,10.80047022050585],[106.73294587858554,10.800463797054382]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":19,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73291101237612,10.800462364541149],[106.73291743582759,10.800458088508107]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":20,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.7329094089994,10.800470353344842],[106.73292542463128,10.800459691884813]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":21,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.7329078056227,10.800478342148537],[106.73293130472628,10.800462699009653]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":22,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73290299549258,10.800502308559613],[106.73292672631581,10.800487017139076]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":23,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73291908089382,10.800527498379928],[106.73289497860905,10.800542252578074]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":24,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73291601126506,10.800543660998555],[106.73289177185563,10.800558230185459]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":25,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73291305623577,10.800559762224598],[106.73288856510223,10.800574207792845]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":26,"level":0,"type":"line","name":"nét đường","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73291141193802,10.800567981667207],[106.73288696172553,10.800582196596537]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":27,"level":0,"type":"line","name":"vạch","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73308360992249,10.800489539167502],[106.73309134505782,10.800483275586654],[106.73333336674173,10.8005321736239]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":28,"level":0,"type":"line","name":"vạch","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73302261755204,10.800544904384925],[106.73303566097974,10.800479915671803]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":29,"level":0,"type":"line","name":"vạch","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73284096115907,10.800654692603594],[106.73306209331518,10.800601997900728],[106.73323208377535,10.800572084737626],[106.73337511979365,10.800555439278833],[106.73360974119343,10.80055607643853]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":30,"level":0,"type":"line","name":"vạch","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73307308335032,10.800593664730934],[106.73314541383053,10.800587293724911]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":31,"level":0,"type":"line","name":"vạch","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.7330705664948,10.80055452788063],[106.73324489808087,10.800526616442072],[106.73324859812352,10.800537962527782],[106.7333307926982,10.800559667103949]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":32,"level":0,"type":"line","name":"vạch","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73306137439168,10.80060259038156],[106.73311597658409,10.800561555589862],[106.73318233780086,10.800548831320322]]}}$feature$::jsonb),
    ('site_lines', 'floor_0_site_lines.geojson', $feature${"type":"Feature","properties":{"fid":33,"level":0,"type":"line","name":"vạch","base_height":0,"height":0.05,"width":0.1},"geometry":{"type":"LineString","coordinates":[[106.73320024665381,10.800545893700244],[106.7332471011204,10.800540047005873]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":1,"level":0,"type":"curb","name":"lề đường","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.73293855165747,10.800528032109376],[106.73294033085031,10.800528389198684],[106.73293129289993,10.800576243061375],[106.73292957390782,10.800575670064006],[106.73293855165747,10.800528032109376]]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":2,"level":0,"type":"curb","name":"lề đường","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.73291030689249,10.800456657709589],[106.73291219163838,10.800457035983706],[106.73288173482405,10.80060737635523],[106.73287998420966,10.800606898454381],[106.73291030689249,10.800456657709589]]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":3,"level":0,"type":"curb","name":"lề đường","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.73284096115907,10.800654692603594],[106.73284022988632,10.800653031796536],[106.7328637112707,10.800636266648523],[106.73286504463023,10.80063749757999],[106.73284096115907,10.800654692603594]]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":4,"level":0,"type":"curb","name":"lề đường","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.7328637112707,10.800636266648523],[106.73287998420966,10.800606898454381],[106.73288173482405,10.80060737635523],[106.73286504463023,10.80063749757999],[106.7328637112707,10.800636266648523]]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":5,"level":0,"type":"curb","name":"lề đường","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.73298383159498,10.800621523480435],[106.73298347792571,10.800619743604598],[106.73295884588761,10.800617547985956],[106.73295819103348,10.800619512548362],[106.73298383159498,10.800621523480435]]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":6,"level":0,"type":"curb","name":"lề đường","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.73292957390782,10.800575670064006],[106.73293624916587,10.800600633962773],[106.73293779879377,10.800599689667647],[106.73293129289993,10.800576243061375],[106.73292957390782,10.800575670064006]]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":7,"level":0,"type":"curb","name":"lề đường","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.73295819103348,10.800619512548362],[106.73293624916587,10.800600633962773],[106.73293779879377,10.800599689667647],[106.73295884588761,10.800617547985956],[106.73295819103348,10.800619512548362]]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":8,"level":0,"type":"walkway","name":"lối đi bộ","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.73302261755204,10.800544904384925],[106.7330705664948,10.80055452788063],[106.73308360992249,10.800489539167502],[106.73303566097974,10.800479915671803],[106.73303566097974,10.800479915671803],[106.73302261755204,10.800544904384925]]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":9,"level":0,"type":"entrance","name":"lối vào xe máy và khuyết tật","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.7334838429303,10.800553178126199],[106.73347058351257,10.80052514914173],[106.73332607862353,10.800512574880663],[106.73334209581559,10.80055654484681],[106.7334838429303,10.800553178126199]]]}}$feature$::jsonb),
    ('site', 'floor_0_site.geojson', $feature${"type":"Feature","properties":{"fid":10,"level":0,"type":"entrance","name":"lối vào xe máy","base_height":0,"height":0.1},"geometry":{"type":"Polygon","coordinates":[[[106.7342680967844,10.800685052192037],[106.73444113326947,10.800711431934502],[106.73429269464233,10.800566604064006],[106.7342680967844,10.800685052192037]]]}}$feature$::jsonb),
    ('vertical', 'floor_0_vertical.geojson', $feature${"type":"Feature","properties":{"fid":1,"level":0,"type":"escalator_stair","name":"thang cuốn","height":1.2,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73311098396805,10.800439761074246,0],[106.73315295940368,10.800447991551822,0],[106.73315789769023,10.800426592310124,0],[106.73311551073071,10.800418773356427,0],[106.73311098396805,10.800439761074246,0]]]}}$feature$::jsonb),
    ('vertical', 'floor_0_vertical.geojson', $feature${"type":"Feature","properties":{"fid":2,"level":0,"type":"stairs","name":"thang bộ 1","height":1.2,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.7331542351277,10.800422723985658,0],[106.73319106651485,10.800430337177415,0],[106.73319662208722,10.800407086078264,0],[106.73315876189037,10.800400913220082,0],[106.7331542351277,10.800422723985658,0]]]}}$feature$::jsonb),
    ('vertical', 'floor_0_vertical.geojson', $feature${"type":"Feature","properties":{"fid":3,"level":0,"type":"elevator","name":"thang máy","height":5,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73320223938815,10.800400974948666,0],[106.73323865925143,10.800408073735575,0],[106.7332448321096,10.800381530445392,0],[106.73320779496052,10.800375769111088,0],[106.73320223938815,10.800400974948666,0]]]}}$feature$::jsonb),
    ('vertical', 'floor_0_vertical.geojson', $feature${"type":"Feature","properties":{"fid":4,"level":0,"type":"stairs","name":"thang bộ 2","height":1.2,"base_height":0},"geometry":{"type":"Polygon","coordinates":[[[106.73384763228725,10.800536253135723,0],[106.73387988547125,10.800543403363118,0],[106.73388379494811,10.800527559693784,0],[106.7338508627497,10.800520543211647,0],[106.73384763228725,10.800536253135723,0]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":1,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73294033085031,10.800528389198684],[106.73293855165748,10.80052803210938],[106.73296872570371,10.80037769031446],[106.73297050489654,10.800378047403765],[106.73294033085031,10.800528389198684]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":2,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73291994205057,10.80041787255367],[106.73291206490052,10.800457120351949],[106.73291030689249,10.800456657709589],[106.73291816285774,10.800417515464364],[106.73291994205057,10.80041787255367]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":3,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73291030689249,10.800456657709589],[106.73291066398178,10.800454878516753],[106.7326918232479,10.80041095660537],[106.73269155513292,10.800412753579598],[106.73291030689249,10.800456657709589]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":4,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73268434940185,10.800411307367886],[106.73269146617326,10.800412735725134],[106.73272455018466,10.800248356161255],[106.73271734445359,10.800246909949543],[106.73268434940185,10.800411307367886]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":5,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73272419309535,10.800250135354094],[106.73272455018466,10.800248356161255],[106.73298420613898,10.800300493194028],[106.73298386629023,10.800302252538096],[106.73272419309535,10.800250135354094]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":6,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73298600257236,10.800300830434562],[106.73298420613898,10.800300493194028],[106.73297509974779,10.80034593172229],[106.73297687894063,10.800346288811596],[106.73298600257236,10.800300830434562]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":7,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73379140822925,10.80056686636311],[106.7337878373188,10.800584658282089],[106.73378605812634,10.800584301190861],[106.73378962903641,10.80056650927381],[106.73379140822925,10.80056686636311]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":8,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73375226599073,10.800559010378752],[106.73375404518357,10.80055936746806],[106.73375047427017,10.800577159401719],[106.73374869507752,10.80057680231143],[106.73375226599073,10.800559010378752]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":9,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73375047427032,10.800577159400982],[106.73374967077868,10.800581162787672],[106.73347058351257,10.80052514914173],[106.73347141761532,10.80052116675903],[106.73375047427032,10.800577159400982]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":10,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73354776995423,10.800485114627808],[106.73354812704353,10.800483335434972],[106.73340979480028,10.800455571741535],[106.7334094315786,10.800457371687758],[106.73354776995423,10.800485114627808]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":11,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73338293782224,10.80050293102523],[106.73338329491155,10.800501151832389],[106.73340183117773,10.80050480359133],[106.73340139694794,10.800506635826762],[106.73338293782224,10.80050293102523]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":12,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.7333999748444,10.80050449954462],[106.73340183117773,10.80050480359133],[106.73341121690382,10.800457708023682],[106.7334094315786,10.800457371687758],[106.7333999748444,10.80050449954462]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":13,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73336648028848,10.800499627949165],[106.73336683737779,10.800497848756326],[106.73332053922256,10.80048851409472],[106.73332022127465,10.800490343627244],[106.73336648028848,10.800499627949165]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":14,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73332053922256,10.80048851409472],[106.7333223575568,10.80048892152371],[106.73332646444568,10.80046845900301],[106.73332468525284,10.800468101913705],[106.73332468525284,10.800468101913705],[106.73332053922256,10.80048851409472]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":15,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73333013050286,10.800440971025958],[106.73333190969569,10.800441328115262],[106.7333418137962,10.80039185762438],[106.73334003973106,10.800391598424667],[106.73333013050286,10.800440971025958]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":16,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73338594165557,10.800402661939428],[106.73338629874488,10.800400882746588],[106.7333418137962,10.80039185762438],[106.7333414618346,10.800393734706812],[106.73338594165557,10.800402661939428]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":17,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73340275627864,10.800404185822659],[106.73340239918933,10.800405965015495],[106.73350047719481,10.800425649562328],[106.7335008342839,10.800423870370576],[106.73340275627864,10.800404185822659]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":18,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73351061984451,10.800425834361754],[106.7335102627552,10.800427613554593],[106.73361167674705,10.800447967644931],[106.73361203383635,10.800446188452133],[106.73351061984451,10.800425834361754]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":19,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73362181939697,10.800448152443279],[106.73362146230767,10.800449931636106],[106.73372287629971,10.800470285725392],[106.7337232333888,10.800468506533655],[106.73362181939697,10.800448152443279]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":20,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73371338529135,10.800559073077467],[106.73371516448418,10.800559430166773],[106.73373105495824,10.80048025608542],[106.7337292757654,10.800479898996114],[106.73371338529135,10.800559073077467]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":21,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.7337860581271,10.800584301187117],[106.73378525467616,10.800588304371004],[106.7342680967844,10.800685052192037],[106.73426903813723,10.800681131252905],[106.7337860581271,10.800584301187117]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":22,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73427384666991,10.800648423574636],[106.73427562586275,10.80064878066395],[106.73426903813723,10.800681131252905],[106.7342673109594,10.800680779268804],[106.73427384666991,10.800648423574636]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":23,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73428080991134,10.800613729314287],[106.73428258910418,10.800614086403591],[106.73429269464233,10.800566604064006],[106.7342914259628,10.800566081567032],[106.73428080991134,10.800613729314287]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":24,"level":0,"type":"fare_barrier","name":"hảng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73417763798919,10.800561557752713],[106.7341779950785,10.800559778559878],[106.73427923115105,10.800580096941298],[106.73427887406174,10.800581876134137],[106.73417763798919,10.800561557752713]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":25,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73444149404406,10.800709653432257],[106.73444113450459,10.800711432131584],[106.73429269464233,10.800566604064006],[106.73429305173198,10.800564824871232],[106.73444149404406,10.800709653432257]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":26,"level":0,"type":"column","name":"cột","base_height":0,"height":5},"geometry":{"type":"Polygon","coordinates":[[[106.7330107113592,10.800334148603728],[106.73306048027347,10.800342006853349],[106.7330650642524,10.800300751042839],[106.73301660504642,10.800293547647351],[106.7330107113592,10.800334148603728]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":27,"level":0,"type":"column","name":"cột","base_height":0,"height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73329937106195,10.800380774218144],[106.73333211376871,10.800386013051225],[106.7333393171642,10.800359164031686],[106.73330657445744,10.80035458005274],[106.73329937106195,10.800380774218144]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":28,"level":0,"type":"column","name":"cột","base_height":0,"height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73353405441262,10.800423961848352],[106.73354592364382,10.800426499408125],[106.7335491979145,10.800413893466025],[106.73353724682653,10.800411437763017],[106.73353405441262,10.800423961848352]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":29,"level":0,"type":"column","name":"cột","base_height":0,"height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73375979900436,10.800465946184092],[106.73376765725398,10.800467869818114],[106.73376966274478,10.800460134353644],[106.73376172263838,10.800458251648005],[106.73375979900436,10.800465946184092]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":30,"level":0,"type":"column","name":"cột","base_height":0,"height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73408667763155,10.800534509412037],[106.734103376412,10.80053892967745],[106.73410730553681,10.800524359172943],[106.73409191646464,10.800520593761666],[106.73408667763155,10.800534509412037]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":31,"level":0,"type":"column","name":"cột","base_height":0,"height":5},"geometry":{"type":"Polygon","coordinates":[[[106.73421024860689,10.800558902728568],[106.7342297305174,10.800562504426312],[106.73423300478808,10.800549571057143],[106.73421368659109,10.800545641932333],[106.73421024860689,10.800558902728568]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":32,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1.5},"geometry":{"type":"Polygon","coordinates":[[[106.73429305173121,10.80056482487109],[106.73429269464233,10.800566604064006],[106.73306409015687,10.800312055462332],[106.73306441758395,10.800308617478123],[106.73429305173121,10.80056482487109]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":33,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73375430641526,10.80058213367901],[106.73375528869646,10.800578286410966],[106.73376069124308,10.800579432405703],[106.73375970896187,10.80058344338728],[106.73375430641526,10.80058213367901]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":34,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73376417834135,10.800584687610137],[106.73376532433608,10.800580594771793],[106.73377162730714,10.800581945408446],[106.733770440384,10.80058616103194],[106.73376417834135,10.800584687610137]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":35,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73377561373168,10.800586840443106],[106.73378072977961,10.800587740867542],[106.73378195763112,10.800583729885965],[106.73377696436835,10.800582583891227],[106.73377561373168,10.800586840443106]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":36,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73371050076643,10.80056825895702],[106.73371050076643,10.800568238492827],[106.73371091005028,10.800566376251382],[106.73371301786202,10.80056672414264],[106.73371215836596,10.800568668240855],[106.73371050076643,10.80056825895702]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":37,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73371181456756,10.80056343759345],[106.73371246942169,10.800561145603977],[106.7337148841963,10.800561554887812],[106.73371410655702,10.800564010590818],[106.73371181456756,10.80056343759345]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":38,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.7337260903877,10.800469028091358],[106.73372568110388,10.800470419656396],[106.73372778891562,10.800470726619272],[106.73372803448592,10.800469355518427],[106.7337260903877,10.800469028091358]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":39,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73372971664247,10.800478650354306],[106.73373000314116,10.800476890433817],[106.7337321314171,10.800477381574417],[106.73373127192104,10.800479141494906],[106.73372971664247,10.800478650354306]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":40,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73373069892368,10.800474230088893],[106.73373102635074,10.800472592953556],[106.73373344112537,10.800472920380622],[106.73373266348608,10.800474721229493],[106.73373069892368,10.800474230088893]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":41,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73372995402708,10.800471078603366],[106.73373019959737,10.80046968703833],[106.73373216415979,10.800470137250548],[106.73373185719691,10.800471406030434],[106.73372995402708,10.800471078603366]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":42,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.7336133613412,10.800448068666192],[106.73361368876826,10.800446533851813],[106.73361575565163,10.800446963599839],[106.7336153259036,10.800448457485835],[106.7336133613412,10.800448068666192]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":43,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73361793304161,10.800448776727224],[106.73361991806821,10.800449247403634],[106.73362032735206,10.80044777398183],[106.7336182195403,10.800447364697996],[106.73361793304161,10.800448776727224]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":44,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73350200339547,10.800425734047343],[106.73350353820986,10.800426020546027],[106.73350411120722,10.800424485731648],[106.73350235128673,10.800424240161346],[106.73350200339547,10.800425734047343]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":45,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73350596117017,10.800426442108376],[106.73350821223126,10.800426851392212],[106.73350849872993,10.800425255185257],[106.73350657509592,10.800425009614957],[106.73350596117017,10.800426442108376]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":46,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73338838620303,10.800402805966932],[106.73339063726412,10.800403256179152],[106.73339114886892,10.800401537187046],[106.73338873409429,10.80040133254513],[106.73338838620303,10.800402805966932]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":47,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73339367005732,10.800403604070405],[106.7333962076171,10.80040425892454],[106.73339653504418,10.80040270364597],[106.73339391562763,10.800402171576986],[106.73339367005732,10.800403604070405]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":48,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73339841365697,10.800404647744186],[106.7334008284316,10.800405241205747],[106.73340123771543,10.800403829176517],[106.73339892526177,10.800403317571725],[106.73339841365697,10.800404647744186]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":49,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73336819623151,10.80050004771315],[106.73337081564804,10.80050053885375],[106.73337114307512,10.800499229145482],[106.73336889201403,10.800498656148113],[106.73336819623151,10.80050004771315]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":50,"level":0,"type":"bollard","name":"cột chắn lối đi dnahf cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73337339413621,10.800500866280819],[106.73337621819466,10.80050148020657],[106.73337654562172,10.8005001704983],[106.73337384434842,10.800499802142848],[106.73337339413621,10.800500866280819]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":51,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73337846925575,10.800501971347172],[106.73337879668281,10.800500825352435],[106.7333810477439,10.80050123463627],[106.73338084310198,10.800502380631006],[106.73337846925575,10.800501971347172]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":52,"level":0,"type":"bollard","name":"cột chắn lối đi dnahf cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73332490218746,10.800466126268951],[106.7333252705429,10.800464243563313],[106.73332690767825,10.800464489133613],[106.73332658025117,10.800466289982486],[106.73332490218746,10.800466126268951]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":53,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho ngươi đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73332563889836,10.800462057987636],[106.73332608911058,10.800460011568463],[106.73332772624592,10.800460298067147],[106.73332723510532,10.800462180772787],[106.73332563889836,10.800462057987636]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":54,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.7333267848931,10.800457252995422],[106.73332723510532,10.800454879149182],[106.73332862667036,10.800455206576249],[106.73332809460138,10.800457457637338],[106.7333267848931,10.800457252995422]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":55,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73332759527509,10.800452865472714],[106.73332808641568,10.800450573483241],[106.73332923241043,10.800450655340008],[106.73332915055366,10.80045294732948],[106.73332759527509,10.800452865472714]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":56,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73332852844223,10.800448019552116],[106.7333288149409,10.800446546130312],[106.73333024743432,10.800446709843845],[106.73332987907888,10.800448019552116],[106.73332852844223,10.800448019552116]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":57,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73332918329636,10.80044449971114],[106.73332975629373,10.800442289578434],[106.733331066002,10.800442576077119],[106.73333069764655,10.800444581567907],[106.73332918329636,10.80044449971114]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":58,"level":0,"type":"fare_barrier","name":"hàng rào","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73347141761532,10.80052116675903],[106.73347469188516,10.800505728572773],[106.73347976700471,10.800506710853975],[106.73347539018809,10.800521949205972],[106.73347141761532,10.80052116675903]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":59,"level":0,"type":"bollard","name":"cột chắn lối đi dnahf cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73296919360686,10.80037528162907],[106.7329696028907,10.80037290778283],[106.7329715674531,10.800373317066665],[106.73297091259897,10.800375445342603],[106.73296919360686,10.80037528162907]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":60,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73296997943186,10.800370599422],[106.73297055242922,10.800367652578393],[106.73297251699162,10.800368307432526],[106.7329721077078,10.800370844992301],[106.73296997943186,10.800370599422]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":61,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73297096171305,10.80036536058892],[106.73297137099689,10.800362823029145],[106.73297366298637,10.800363396026514],[106.7329728444187,10.800365933586287],[106.73297096171305,10.80036536058892]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":62,"level":0,"type":"bollard","name":"cột chắn lối đi danhc ho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73297202585103,10.800360776609974],[106.73297235327809,10.800358484620501],[106.7329743178405,10.800358893904335],[106.73297390855666,10.800361349607341],[106.73297202585103,10.800360776609974]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":63,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73297284441867,10.80035620900238],[106.73297317184573,10.800353998869674],[106.7329749726946,10.800354244439974],[106.7329747271243,10.80035645457268],[106.73297284441867,10.80035620900238]]]}}$feature$::jsonb),
    ('walls', 'floor_0_walls.geojson', $feature${"type":"Feature","properties":{"fid":64,"level":0,"type":"bollard","name":"cột chắn lối đi dành cho người đi bộ","base_height":0,"height":1},"geometry":{"type":"Polygon","coordinates":[[[106.73297366298634,10.800350888312533],[106.73297431784047,10.800348187039225],[106.73297652797318,10.80034835075276],[106.73297554569197,10.800351133882833],[106.73297366298634,10.800350888312533]]]}}$feature$::jsonb)
;

DELETE FROM drawing_feature
WHERE floor_id = 0
  AND properties->>'_source_file' IN (
      'floor_0_gates.geojson',
      'floor_0_site.geojson',
      'floor_0_site_lines.geojson',
      'floor_0_vertical.geojson',
      'floor_0_walls.geojson'
  );

DELETE FROM room WHERE floor_id = 0;

INSERT INTO room (floor_id, name, category, height, geom_wgs84)
SELECT
    0,
    btrim(feature->'properties'->>'name'),
    btrim(feature->'properties'->>'type', E' \t\n\r'),
    COALESCE(NULLIF(feature->'properties'->>'height', '')::DOUBLE PRECISION, 3.5),
    ST_Translate(
        ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON((feature->'geometry')::text), 4326)),
        0, 0, COALESCE(NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION, 0)
    )::geometry(PolygonZ, 4326)
FROM floor0_source_feature
WHERE source_layer = 'room';

INSERT INTO drawing_feature (
    floor_id, layer_name, feature_type, name, properties, style, geom_wgs84
)
SELECT
    0,
    source_layer,
    btrim(feature->'properties'->>'type', E' \t\n\r'),
    NULLIF(btrim(feature->'properties'->>'name'), ''),
    jsonb_set(
        feature->'properties',
        '{type}',
        to_jsonb(btrim(feature->'properties'->>'type', E' \t\n\r'))
    ) || jsonb_build_object(
        '_source_file', source_file,
        '_source_fid', feature->'properties'->'fid'
    ),
    jsonb_strip_nulls(jsonb_build_object(
        'color', CASE btrim(feature->'properties'->>'type', E' \t\n\r')
            WHEN 'fare_barrier' THEN '#F97316'
            WHEN 'bollard' THEN '#475569'
            WHEN 'column' THEN '#334155'
            WHEN 'elevator' THEN '#FDE047'
            WHEN 'stairs' THEN '#FCA5A5'
            WHEN 'escalator_stair' THEN '#FDBA74'
            WHEN 'gate' THEN '#16A34A'
            WHEN 'walkway' THEN '#DCFCE7'
            WHEN 'entrance' THEN '#DBEAFE'
            WHEN 'curb' THEN '#94A3B8'
            ELSE '#64748B'
        END,
        'height', NULLIF(feature->'properties'->>'height', '')::DOUBLE PRECISION,
        'base_height', NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION,
        'radius', NULLIF(feature->'properties'->>'radius', '')::DOUBLE PRECISION,
        'width', NULLIF(feature->'properties'->>'width', '')::DOUBLE PRECISION,
        'opacity', 0.95
    )),
    ST_Translate(
        ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON((feature->'geometry')::text), 4326)),
        0, 0, COALESCE(NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION, 0)
    )::geometry(GeometryZ, 4326)
FROM floor0_source_feature
WHERE source_layer IN ('gates', 'site', 'site_lines', 'vertical', 'walls');

CREATE TEMP TABLE floor0_vertical_device ON COMMIT DROP AS
SELECT
    feature->'properties'->>'fid' AS source_fid,
    btrim(feature->'properties'->>'name') AS name,
    'TD_F1:' || (feature->'properties'->>'fid') || ' - ' || btrim(feature->'properties'->>'name') AS link_label,
    CASE btrim(feature->'properties'->>'type', E' \t\n\r')
        WHEN 'elevator' THEN 'elevator'
        WHEN 'escalator_stair' THEN 'escalator'
        WHEN 'stairs' THEN 'stair'
        ELSE NULL
    END AS node_type,
    ST_Translate(
        ST_Force3DZ(ST_SetSRID(
            ST_Centroid(ST_GeomFromGeoJSON((feature->'geometry')::text)), 4326
        )),
        0, 0, COALESCE(NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION, 0)
    )::geometry(PointZ, 4326) AS geom_wgs84
FROM floor0_source_feature
WHERE source_layer = 'vertical';

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM floor0_vertical_device WHERE node_type IS NULL) THEN
        RAISE EXCEPTION 'Unsupported floor 0 vertical device type';
    END IF;
END;
$$;

INSERT INTO vertical_link (label, transfer_type, avg_time_per_floor)
SELECT link_label, node_type, 20
FROM floor0_vertical_device
ON CONFLICT (label) WHERE label LIKE 'TD_F1:%'
DO UPDATE SET transfer_type = EXCLUDED.transfer_type,
              avg_time_per_floor = EXCLUDED.avg_time_per_floor;

UPDATE node n
SET geom_wgs84 = device.geom_wgs84
FROM floor0_vertical_device device
JOIN vertical_link link ON link.label = device.link_label
WHERE n.floor_id = 0
  AND n.vertical_link_id = link.id;

INSERT INTO node (floor_id, type, geom_wgs84, vertical_link_id)
SELECT 0, device.node_type, device.geom_wgs84, link.id
FROM floor0_vertical_device device
JOIN vertical_link link ON link.label = device.link_label
WHERE NOT EXISTS (
    SELECT 1 FROM node n
    WHERE n.floor_id = 0
      AND n.vertical_link_id = link.id
);

CREATE TEMP TABLE floor0_gate_source ON COMMIT DROP AS
SELECT feature->'properties'->>'fid' AS source_fid,
       btrim(feature->'properties'->>'name') AS name,
       ST_Translate(
           ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON((feature->'geometry')::text), 4326)),
           0, 0, COALESCE(NULLIF(feature->'properties'->>'base_height', '')::DOUBLE PRECISION, 0)
       )::geometry(PointZ, 4326) AS geom_wgs84
FROM floor0_source_feature
WHERE source_layer = 'gates';

WITH gate_matches AS (
    SELECT gate.source_fid, nearest.id AS node_id, gate.geom_wgs84
    FROM floor0_gate_source gate
    CROSS JOIN LATERAL (
        SELECT n.id
        FROM node n
        WHERE n.floor_id = 0
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
SELECT 0, 'gate', gate.geom_wgs84
FROM floor0_gate_source gate
WHERE NOT EXISTS (
    SELECT 1 FROM node n
    WHERE n.floor_id = 0
      AND n.type = 'gate'
      AND ST_DWithin(n.geom_wgs84::geography, gate.geom_wgs84::geography, 0.05)
);

DO $$
DECLARE
    expected_vertical_count INT;
    linked_vertical_count INT;
BEGIN
    SELECT count(*) INTO expected_vertical_count FROM floor0_vertical_device;
    SELECT count(DISTINCT n.vertical_link_id) INTO linked_vertical_count
    FROM node n
    JOIN vertical_link link ON link.id = n.vertical_link_id
    JOIN floor0_vertical_device device ON link.label = device.link_label
    WHERE n.floor_id = 0
      AND n.vertical_link_id IS NOT NULL;

    IF expected_vertical_count <> linked_vertical_count THEN
        RAISE EXCEPTION 'Expected % floor 0 vertical nodes linked to floor 1 devices, found %',
            expected_vertical_count, linked_vertical_count;
    END IF;
END;
$$;

COMMIT;
