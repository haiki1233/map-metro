package com.metro.indoornav.dto.geojson;

/** properties cua 1 Node trong GeoJSON tra ve tu GET /api/floors/{id}/map */
public record NodeProperties(Integer id, String type, Integer floorId) {
}
