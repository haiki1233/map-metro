package com.metro.indoornav.dto.geojson;

public record RoomProperties(
        Integer id,
        String name,
        String category,
        Integer floorId,
        Double baseHeight,
        Double height) {
}
