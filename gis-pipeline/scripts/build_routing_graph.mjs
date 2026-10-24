/**
 * Build fixed-node routing SQL and map-entity SQL from the cleaned GeoJSON exports.
 *
 * Routing intersections are deliberately not planarized. Source/target IDs connect
 * fixed nodes; meaningful bends inside each route get private turn nodes and split edges.
 *
 * Usage:
 *   node build_routing_graph.mjs "<data directory>" "<graph sql>" "<map sql>"
 */
import fs from 'node:fs';
import path from 'node:path';

const [DATA_DIR, OUT_GRAPH_SQL, OUT_MAP_SQL] = process.argv.slice(2);
if (!DATA_DIR || !OUT_GRAPH_SQL || !OUT_MAP_SQL) {
  console.error('Usage: node build_routing_graph.mjs "<data directory>" "<graph sql>" "<map sql>"');
  process.exit(1);
}

const FLOOR_ID = 0;
const NODE_SNAP_TOLERANCE_M = 0.5;
const TURN_NODE_ANGLE_DEGREES = 20;
const MIN_TURN_SEGMENT_LENGTH_M = 1;
const NODE_FILES = {
  entities: '02_entity_modified_clean_v1.geojson',
  nodes: '02_node_modified_clean_v1.geojson',
  routes: 'routing_network_clean_v1.geojson',
};
const METERS_PER_DEGREE_LAT = 111320;

const readFeatureCollection = (filename) => {
  const filepath = path.join(DATA_DIR, filename);
  const collection = JSON.parse(fs.readFileSync(filepath, 'utf8'));
  if (collection.type !== 'FeatureCollection' || !Array.isArray(collection.features)) {
    throw new Error(`${filename} is not a valid GeoJSON FeatureCollection.`);
  }
  return collection.features;
};

const distanceMeters = (a, b) => {
  const metersPerDegreeLng =
    METERS_PER_DEGREE_LAT * Math.cos((((a.lat + b.lat) / 2) * Math.PI) / 180);
  return Math.hypot(
    (a.lng - b.lng) * metersPerDegreeLng,
    (a.lat - b.lat) * METERS_PER_DEGREE_LAT,
  );
};

const bearingBetween = (a, b) => {
  const toRadians = (degrees) => (degrees * Math.PI) / 180;
  const lat1 = toRadians(a.lat);
  const lat2 = toRadians(b.lat);
  const deltaLng = toRadians(b.lng - a.lng);
  const y = Math.sin(deltaLng) * Math.cos(lat2);
  const x =
    Math.cos(lat1) * Math.sin(lat2)
    - Math.sin(lat1) * Math.cos(lat2) * Math.cos(deltaLng);
  return (Math.atan2(y, x) * 180) / Math.PI;
};

const signedTurnAngle = (incoming, outgoing) =>
  ((outgoing - incoming + 540) % 360) - 180;

const sameCoordinate = (a, b) =>
  a.lng === b.lng && a.lat === b.lat && a.z === b.z;

const coordinatePoint = (coordinate, description) => {
  if (
    !Array.isArray(coordinate)
    || coordinate.length < 2
    || !Number.isFinite(coordinate[0])
    || !Number.isFinite(coordinate[1])
  ) {
    throw new Error(`Invalid coordinate in ${description}.`);
  }
  return {
    lng: coordinate[0],
    lat: coordinate[1],
    z: Number.isFinite(coordinate[2]) ? coordinate[2] : 0,
  };
};

const formatNumber = (value) => Number(value.toFixed(9)).toString();
const sqlString = (value) => `'${String(value).replaceAll("'", "''")}'`;
const geometryWkt = (type, coordinates) => {
  const coordinateText = (point) =>
    `${formatNumber(point.lng)} ${formatNumber(point.lat)} ${formatNumber(point.z)}`;
  if (type === 'POINT') return `ST_GeomFromText('POINT Z (${coordinateText(coordinates)})', 4326)`;
  if (type === 'LINESTRING') {
    const points = coordinates.map(coordinateText).join(', ');
    return `ST_GeomFromText('LINESTRING Z (${points})', 4326)`;
  }
  throw new Error(`Unsupported WKT geometry type: ${type}`);
};

const inferNodeType = (node) => {
  const text = node.text.toLowerCase();
  if (/^ev(?:-|\b)/i.test(node.text)) return 'elevator';
  if (/^st(?:-|\b)/i.test(node.text) || text.includes('cầu thang')) return 'stair';
  if (text.includes('thang cuốn') || text.includes('escalator')) return 'escalator';
  if (text.includes('bãi') || text.includes('bãi xe')) return 'parking';
  if (text.includes('cổng') || text.includes('gate')) return 'gate';
  if (node.layer.toUpperCase().startsWith('ARC_TAG_ROOM NAME')) return 'room';
  return 'gate';
};

const entities = readFeatureCollection(NODE_FILES.entities);
const nodeFeatures = readFeatureCollection(NODE_FILES.nodes);
const routeFeatures = readFeatureCollection(NODE_FILES.routes);
const floorNodes = nodeFeatures.map((feature, index) => {
  if (feature.geometry?.type !== 'Point') {
    throw new Error(`Node feature ${index} must have Point geometry.`);
  }
  const point = coordinatePoint(feature.geometry.coordinates, `node feature ${index}`);
  const fid = Number(feature.properties?.fid);
  if (!Number.isInteger(fid) || fid < 1) {
    throw new Error(`Node feature ${index} has invalid fid '${feature.properties?.fid}'.`);
  }
  return {
    fid,
    point,
    layer: String(feature.properties?.Layer ?? ''),
    text: String(feature.properties?.Text ?? '').trim(),
    feature,
  };
});

const routes = routeFeatures.map((feature, index) => {
  if (feature.geometry?.type !== 'LineString' || feature.geometry.coordinates.length < 2) {
    throw new Error(`Routing feature ${index} must have LineString geometry with at least 2 points.`);
  }
  const source = Number(feature.properties?.source);
  const target = Number(feature.properties?.target);
  if (!Number.isInteger(source) || !Number.isInteger(target) || source === target) {
    throw new Error(`Routing feature ${index} has invalid source/target IDs.`);
  }
  const coordinates = feature.geometry.coordinates.map((coordinate, pointIndex) =>
    coordinatePoint(coordinate, `route feature ${index}, coordinate ${pointIndex}`));
  return {
    routeIndex: index,
    source,
    target,
    edgeType: String(feature.properties?.edge_type || 'corridor'),
    sourceEdgeId: feature.properties?.edge_id ?? null,
    coordinates,
  };
});

const endpointReferences = routes.flatMap((route) => [
  { id: route.source, point: route.coordinates[0] },
  { id: route.target, point: route.coordinates.at(-1) },
]);
const nodesByFid = new Map();
for (const node of floorNodes) {
  if (!nodesByFid.has(node.fid)) nodesByFid.set(node.fid, []);
  nodesByFid.get(node.fid).push(node);
}

// Unique FIDs are stable node IDs. Duplicate FIDs are resolved from routing endpoint IDs
// by matching endpoint coordinates; no node is inferred from a crossing or line vertex.
for (const [fid, candidates] of nodesByFid) {
  if (candidates.length === 1) {
    candidates[0].id = fid;
    continue;
  }
  for (const candidate of candidates) {
    const ids = new Set(
      endpointReferences
        .filter((reference) => distanceMeters(candidate.point, reference.point) <= NODE_SNAP_TOLERANCE_M)
        .map((reference) => reference.id),
    );
    if (ids.size !== 1) {
      throw new Error(
        `Duplicate node fid ${fid} cannot be resolved uniquely from route endpoints; found IDs ${[...ids].join(', ')}.`,
      );
    }
    candidate.id = [...ids][0];
  }
}

const ids = new Set();
for (const node of floorNodes) {
  if (ids.has(node.id)) throw new Error(`Resolved node ID ${node.id} is duplicated.`);
  ids.add(node.id);
  node.type = inferNodeType(node);
}

const endpointCorrections = [];
for (const [index, route] of routes.entries()) {
  for (const role of ['source', 'target']) {
    const endpoint = role === 'source' ? route.coordinates[0] : route.coordinates.at(-1);
    const nearest = floorNodes
      .map((node) => ({ node, distance: distanceMeters(endpoint, node.point) }))
      .sort((a, b) => a.distance - b.distance);
    if (!nearest.length || nearest[0].distance > NODE_SNAP_TOLERANCE_M) {
      throw new Error(
        `Route ${index} ${role} endpoint is ${nearest[0]?.distance.toFixed(2) ?? '?'} m from every fixed node.`,
      );
    }
    if (nearest[1] && nearest[1].distance - nearest[0].distance < 0.01) {
      throw new Error(`Route ${index} ${role} endpoint is ambiguous between fixed nodes.`);
    }
    const propertyId = route[role];
    const endpointId = nearest[0].node.id;
    if (propertyId !== endpointId) {
      endpointCorrections.push({
        routeIndex: index,
        sourceEdgeId: route.sourceEdgeId,
        role,
        propertyId,
        endpointId,
      });
      route[role] = endpointId;
    }
  }
}

const turnNodes = [];
const graphEdges = [];
let nextTurnNodeId = Math.max(...ids) + 1;

for (const [routeIndex, route] of routes.entries()) {
  const coordinates = route.coordinates.filter(
    (coordinate, index, all) => index === 0 || !sameCoordinate(coordinate, all[index - 1]),
  );
  if (coordinates.length < 2) {
    throw new Error(`Route ${route.sourceEdgeId ?? routeIndex} has no usable geometry after deduplication.`);
  }

  const cumulativeDistances = [0];
  for (let index = 1; index < coordinates.length; index++) {
    cumulativeDistances.push(
      cumulativeDistances[index - 1] + distanceMeters(coordinates[index - 1], coordinates[index]),
    );
  }
  const routeLength = cumulativeDistances.at(-1);
  const turns = [];
  let lastTurnDistance = 0;
  for (let index = 1; index < coordinates.length - 1; index++) {
    const incoming = bearingBetween(coordinates[index - 1], coordinates[index]);
    const outgoing = bearingBetween(coordinates[index], coordinates[index + 1]);
    const turnAngle = signedTurnAngle(incoming, outgoing);
    if (Math.abs(turnAngle) < TURN_NODE_ANGLE_DEGREES) continue;
    const distanceFromLastNode = cumulativeDistances[index] - lastTurnDistance;
    const distanceToRouteEnd = routeLength - cumulativeDistances[index];
    if (
      distanceFromLastNode < MIN_TURN_SEGMENT_LENGTH_M
      || distanceToRouteEnd < MIN_TURN_SEGMENT_LENGTH_M
    ) continue;

    const nearbyFixedNodes = floorNodes
      .map((node) => ({ node, distance: distanceMeters(coordinates[index], node.point) }))
      .filter(
        ({ node, distance }) =>
          distance <= NODE_SNAP_TOLERANCE_M
          && node.id !== route.source
          && node.id !== route.target,
      )
      .sort((a, b) => a.distance - b.distance);
    const fixedNode = nearbyFixedNodes[0]
      && (!nearbyFixedNodes[1] || nearbyFixedNodes[1].distance - nearbyFixedNodes[0].distance >= 0.01)
      ? nearbyFixedNodes[0].node
      : null;
    const node = fixedNode || {
      id: nextTurnNodeId++,
      point: coordinates[index],
      type: 'turn',
      sourceEdgeId: route.sourceEdgeId,
      sourceRouteIndex: route.routeIndex,
      turnAngle: Number(turnAngle.toFixed(1)),
    };
    if (!fixedNode) turnNodes.push(node);
    turns.push({ coordinateIndex: index, node });
    lastTurnDistance = cumulativeDistances[index];
  }

  let startIndex = 0;
  let source = route.source;
  for (const [turnIndex, turn] of turns.entries()) {
    graphEdges.push({
      ...route,
      source,
      target: turn.node.id,
      coordinates: coordinates.slice(startIndex, turn.coordinateIndex + 1),
      segmentIndex: turnIndex + 1,
    });
    source = turn.node.id;
    startIndex = turn.coordinateIndex;
  }
  graphEdges.push({
    ...route,
    source,
    target: route.target,
    coordinates: coordinates.slice(startIndex),
    segmentIndex: turns.length + 1,
  });
}

const roomFeatures = entities.filter(
  (feature) =>
    feature.geometry?.type === 'Polygon'
    && String(feature.properties?.Layer ?? '').toUpperCase() === 'ARC_TAG_ROOM NAME 2',
);
const rooms = roomFeatures.map((feature, index) => {
  const ring = feature.geometry.coordinates?.[0];
  if (!Array.isArray(ring) || ring.length < 4) {
    throw new Error(`Room entity ${feature.properties?.fid ?? index} has an invalid polygon ring.`);
  }
  const centroid = ring.reduce(
    (sum, coordinate) => ({ lng: sum.lng + coordinate[0], lat: sum.lat + coordinate[1] }),
    { lng: 0, lat: 0 },
  );
  centroid.lng /= ring.length;
  centroid.lat /= ring.length;
  const node = floorNodes
    .map((candidate) => ({ candidate, distance: distanceMeters(centroid, candidate.point) }))
    .sort((a, b) => a.distance - b.distance)[0];
  if (!node || node.distance > 3) {
    throw new Error(`Room entity ${feature.properties?.fid ?? index} has no nearby fixed label node.`);
  }
  return {
    feature,
    node: node.candidate,
    name: node.candidate.text || `Room ${feature.properties?.fid ?? index}`,
  };
});
if (new Set(rooms.map((room) => room.node.id)).size !== rooms.length) {
  throw new Error('More than one room polygon resolves to the same fixed label node.');
}

const nodeValues = [...floorNodes, ...turnNodes]
  .map(
    (node) =>
      `  (${node.id}, ${FLOOR_ID}, ${sqlString(node.type)}, ${geometryWkt('POINT', node.point)})`,
  )
  .join(',\n');
const routeValues = graphEdges
  .map((route) => {
    const line = geometryWkt('LINESTRING', route.coordinates);
    return `  (${route.source}, ${route.target}, ${sqlString(route.edgeType)}, ${line})`;
  })
  .join(',\n');
const retainedNodeIds = [...ids, ...turnNodes.map((node) => node.id)]
  .sort((a, b) => a - b)
  .join(', ');
const turnNodesGeoJson = {
  type: 'FeatureCollection',
  features: turnNodes.map((node) => ({
    type: 'Feature',
    geometry: {
      type: 'Point',
      coordinates: [node.point.lng, node.point.lat, node.point.z],
    },
    properties: {
      id: node.id,
      type: node.type,
      floorId: FLOOR_ID,
      source_edge_id: node.sourceEdgeId,
      source_route_index: node.sourceRouteIndex,
      turn_angle: node.turnAngle,
    },
  })),
};
const segmentedRoutesGeoJson = {
  type: 'FeatureCollection',
  features: graphEdges.map((edge, index) => ({
    type: 'Feature',
    geometry: {
      type: 'LineString',
      coordinates: edge.coordinates.map(({ lng, lat, z }) => [lng, lat, z]),
    },
    properties: {
      source: edge.source,
      target: edge.target,
      edge_type: edge.edgeType,
      edge_id: `${edge.routeIndex + 1}.${edge.sourceEdgeId ?? index + 1}.${edge.segmentIndex}`,
      source_edge_id: edge.sourceEdgeId,
      source_route_index: edge.routeIndex,
      segment_index: edge.segmentIndex,
    },
  })),
};

const graphSql = [
  '-- Generated by gis-pipeline/scripts/build_routing_graph.mjs; do not edit by hand.',
  `-- Source: ${NODE_FILES.nodes} (${floorNodes.length} fixed nodes), ${NODE_FILES.routes} (${routes.length} routes).`,
  `-- Added ${turnNodes.length} hidden turn nodes at bends of ${graphEdges.length} routing segments (angle >= ${TURN_NODE_ANGLE_DEGREES} degrees; segments >= ${MIN_TURN_SEGMENT_LENGTH_M} m).`,
  '-- Nodes are generated only at bends within an edge; crossings do not connect edges.',
  '-- Duplicate node FIDs are resolved from route endpoint IDs and coordinates.',
  ...endpointCorrections.map(
    (correction) =>
      `-- Corrected edge_id ${correction.sourceEdgeId} ${correction.role}: GeoJSON property ${correction.propertyId} did not match its fixed geometry endpoint; using node ${correction.endpointId}.`,
  ),
  '',
  'BEGIN;',
  '',
  '-- Upsert fixed point features and generated turn points.',
  'INSERT INTO node (id, floor_id, type, geom_wgs84) VALUES',
  nodeValues,
  'ON CONFLICT (id) DO UPDATE',
  '  SET floor_id = EXCLUDED.floor_id,',
  '      type = EXCLUDED.type,',
  '      geom_local = NULL,',
  '      geom_wgs84 = EXCLUDED.geom_wgs84;',
  '',
  '-- Replace same-floor graph edges and any edges attached to obsolete floor nodes.',
  'DELETE FROM edge e',
  'WHERE (',
  `    EXISTS (SELECT 1 FROM node s WHERE s.id = e.source AND s.floor_id = ${FLOOR_ID})`,
  `    AND EXISTS (SELECT 1 FROM node t WHERE t.id = e.target AND t.floor_id = ${FLOOR_ID})`,
  '  )',
  `  OR EXISTS (SELECT 1 FROM node s WHERE s.id = e.source AND s.floor_id = ${FLOOR_ID} AND s.id NOT IN (${retainedNodeIds}))`,
  `  OR EXISTS (SELECT 1 FROM node t WHERE t.id = e.target AND t.floor_id = ${FLOOR_ID} AND t.id NOT IN (${retainedNodeIds}));`,
  '',
  `DELETE FROM node WHERE floor_id = ${FLOOR_ID} AND id NOT IN (${retainedNodeIds});`,
  '',
  '-- Split routes retain their original geometry and type; triggers calculate segment costs.',
  'INSERT INTO edge (source, target, edge_type, geom_wgs84) VALUES',
  routeValues,
  ';',
  '',
  "SELECT setval(pg_get_serial_sequence('node', 'id'), (SELECT max(id) FROM node));",
  '',
  '-- Diagnostics: lists fixed nodes outside the component containing the lowest-ID floor node.',
  `SELECT * FROM fn_check_graph_connectivity((SELECT min(id) FROM node WHERE floor_id = ${FLOOR_ID}));`,
  'COMMIT;',
  '',
].join('\n');

const drawingFeatureValues = entities.map((feature, index) => {
  if (feature.geometry?.type !== 'Polygon' && feature.geometry?.type !== 'MultiPolygon') {
    throw new Error(`Entity feature ${index} must have Polygon or MultiPolygon geometry.`);
  }
  const fid = feature.properties?.fid ?? index;
  const properties = {
    ...feature.properties,
    _source_file: NODE_FILES.entities,
    _source_fid: fid,
  };
  const layerName = feature.properties?.Layer ?? null;
  const geojson = JSON.stringify(feature.geometry);
  return `  (${FLOOR_ID}, ${layerName == null ? 'NULL' : sqlString(layerName)}, ${sqlString(JSON.stringify(properties))}::jsonb, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON(${sqlString(geojson)}), 4326)))`;
});

const roomValues = rooms.map(({ feature, node, name }) => {
  const category = node.type === 'room' ? 'room' : node.type;
  const geojson = JSON.stringify(feature.geometry);
  return `  (${FLOOR_ID}, ${sqlString(name)}, ${sqlString(category)}, ST_Force3DZ(ST_SetSRID(ST_GeomFromGeoJSON(${sqlString(geojson)}), 4326)), ${node.id})`;
});

const mapSql = [
  '-- Generated by gis-pipeline/scripts/build_routing_graph.mjs; do not edit by hand.',
  `-- Source: ${NODE_FILES.entities} (${entities.length} polygon features).`,
  `-- Room polygons: ${rooms.length}; each room is linked to its nearest fixed label node.`,
  '',
  'BEGIN;',
  '',
  `DELETE FROM room WHERE floor_id = ${FLOOR_ID};`,
  "SELECT setval(pg_get_serial_sequence('room', 'id'), COALESCE((SELECT max(id) FROM room), 1), EXISTS (SELECT 1 FROM room));",
  'INSERT INTO room (floor_id, name, category, geom_wgs84, node_id) VALUES',
  roomValues.join(',\n'),
  ';',
  '',
  '-- Replace only drawing features previously imported from this source; preserve other CAD layers.',
  `DELETE FROM drawing_feature WHERE floor_id = ${FLOOR_ID} AND properties->>'_source_file' = ${sqlString(NODE_FILES.entities)};`,
  "SELECT setval(pg_get_serial_sequence('drawing_feature', 'id'), COALESCE((SELECT max(id) FROM drawing_feature), 1), EXISTS (SELECT 1 FROM drawing_feature));",
  'INSERT INTO drawing_feature (floor_id, layer_name, properties, geom_wgs84) VALUES',
  drawingFeatureValues.join(',\n'),
  ';',
  'COMMIT;',
  '',
].join('\n');

const turnNodesGeoJsonPath = path.join(DATA_DIR, 'routing_turn_nodes.geojson');
const segmentedRoutesGeoJsonPath = path.join(DATA_DIR, 'routing_network_turn_nodes.geojson');
for (const output of [OUT_GRAPH_SQL, OUT_MAP_SQL, turnNodesGeoJsonPath, segmentedRoutesGeoJsonPath]) {
  fs.mkdirSync(path.dirname(path.resolve(output)), { recursive: true });
}
fs.writeFileSync(OUT_GRAPH_SQL, graphSql, 'utf8');
fs.writeFileSync(OUT_MAP_SQL, mapSql, 'utf8');
fs.writeFileSync(turnNodesGeoJsonPath, `${JSON.stringify(turnNodesGeoJson, null, 2)}\n`, 'utf8');
fs.writeFileSync(
  segmentedRoutesGeoJsonPath,
  `${JSON.stringify(segmentedRoutesGeoJson, null, 2)}\n`,
  'utf8',
);

const edgeTypeCounts = routes.reduce((counts, route) => {
  counts[route.edgeType] = (counts[route.edgeType] ?? 0) + 1;
  return counts;
}, {});
console.log(`Fixed nodes: ${floorNodes.length} (${[...ids].sort((a, b) => a - b).join(', ')}).`);
console.log(`Routes: ${routes.length}; segments: ${graphEdges.length}; hidden turn nodes: ${turnNodes.length}.`);
if (endpointCorrections.length) {
  console.warn(`Corrected route endpoint metadata: ${JSON.stringify(endpointCorrections)}.`);
}
console.log(`Route types: ${JSON.stringify(edgeTypeCounts)}.`);
console.log(`Room polygons linked to fixed nodes: ${rooms.map((room) => `${room.name} -> ${room.node.id}`).join('; ')}.`);
console.log(`Graph SQL: ${path.resolve(OUT_GRAPH_SQL)}`);
console.log(`Map SQL: ${path.resolve(OUT_MAP_SQL)}`);
console.log(`Turn-node GeoJSON: ${path.resolve(turnNodesGeoJsonPath)}`);
console.log(`Segmented-route GeoJSON: ${path.resolve(segmentedRoutesGeoJsonPath)}`);
