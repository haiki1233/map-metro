package com.metro.indoornav.controller;

import com.metro.indoornav.dto.request.RouteRequest;
import com.metro.indoornav.dto.response.RouteResponse;
import com.metro.indoornav.service.RoutingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Nhom C — docs/RESTAPI_Spec.md muc C.1, API trung tam cua he thong (Dijkstra qua pgRouting) */
@RestController
@RequestMapping("/api/route")
@RequiredArgsConstructor
public class RouteController {

    private final RoutingService routingService;

    @PostMapping
    public RouteResponse findRoute(@Valid @RequestBody RouteRequest request) {
        return routingService.findRoute(request);
    }
}
