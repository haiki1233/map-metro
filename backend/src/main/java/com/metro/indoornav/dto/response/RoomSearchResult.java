package com.metro.indoornav.dto.response;

/** GET /api/rooms/search — docs/RESTAPI_Spec.md muc B.1 */
public record RoomSearchResult(
        Integer id,
        String name,
        Integer floorId,
        String category,
        Integer nodeId,
        String resultType
) {
}
