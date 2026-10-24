package com.metro.indoornav.dto.response;

import com.metro.indoornav.dto.geojson.EdgeProperties;
import com.metro.indoornav.dto.geojson.GeoJsonFeatureCollection;
import com.metro.indoornav.dto.geojson.NodeProperties;
import com.metro.indoornav.dto.geojson.RoomProperties;

/** GET /api/floors/{floorId}/map — docs/RESTAPI_Spec.md muc A.2 */
public record FloorMapResponse(
        GeoJsonFeatureCollection<NodeProperties> nodes,
        GeoJsonFeatureCollection<EdgeProperties> edges,
        GeoJsonFeatureCollection<RoomProperties> rooms
) {
}
