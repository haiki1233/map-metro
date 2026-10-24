package com.metro.indoornav.dto.geojson;

/** properties cua 1 Edge trong GeoJSON — cost la met thuc (cost_distance), dung lam trong so mac dinh khi ve ban do. */
public record EdgeProperties(Integer id, Integer source, Integer target, Double cost, String edgeType) {
}
