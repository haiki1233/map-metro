package com.metro.indoornav.service;

import org.locationtech.jts.geom.Coordinate;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class RoutingServiceTest {

    @Test
    void walkingEdgeTypesAreNotTreatedAsFloorTransfers() {
        assertFalse(RoutingService.isTransferEdge("corridor", 1, 1));
        assertFalse(RoutingService.isTransferEdge("walkway", 1, 1));
        assertFalse(RoutingService.isTransferEdge("gate", 1, 1));
        assertFalse(RoutingService.isTransferEdge("entrance", 1, 1));
    }

    @Test
    void verticalEdgesAndFloorChangesAreTransfers() {
        assertTrue(RoutingService.isTransferEdge("elevator", 1, 1));
        assertTrue(RoutingService.isTransferEdge("ESCALATOR", 1, 1));
        assertTrue(RoutingService.isTransferEdge("stair", 1, 1));
        assertTrue(RoutingService.isTransferEdge("walkway", 1, 2));
    }

    @Test
    void transferOnlyRouteHasAnEmptyLineInsteadOfAnInvalidSinglePointLine() {
        var geometry = RoutingService.createRouteLineString(
                List.of(new Coordinate(106.7332, 10.8004)));

        assertTrue(geometry.isEmpty());
    }
}
