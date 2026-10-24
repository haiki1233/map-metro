package com.metro.indoornav.dto.response;

import com.metro.indoornav.dto.geojson.GeoJsonFeature;

import java.util.List;

/** POST /api/route — docs/RESTAPI_Spec.md muc C.1, API trung tam cua he thong */
public record RouteResponse(
        Double totalDistance,
        Double totalTimeEstimate,
        GeoJsonFeature<Object> geometry,
        List<TransferPoint> transferPoints,
        List<RouteStep> steps
) {
}
