package com.metro.indoornav.dto.response;

import org.locationtech.jts.geom.Point;

/** GET /api/nodes/nearest — docs/RESTAPI_Spec.md muc B.2 */
public record NearestNodeResponse(Integer nodeId, Double distance, Point geometry) {
}
