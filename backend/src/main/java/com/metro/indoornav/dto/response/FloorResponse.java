package com.metro.indoornav.dto.response;

/** GET /api/floors — docs/RESTAPI_Spec.md muc A.1 */
public record FloorResponse(Integer id, String name, Integer levelOrder) {
}
