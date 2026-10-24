package com.metro.indoornav.dto.request;

import jakarta.validation.constraints.NotNull;

/**
 * Body cua POST /api/route. `criteria` khong bat buoc — service se mac dinh "distance" neu null
 * (xem application.yml app.routing.default-criteria).
 */
public record RouteRequest(
        @NotNull Integer startNodeId,
        @NotNull Integer endNodeId,
        String criteria // distance/shortest | time/fastest | least_stairs/less_stairs | accessible
) {
}
