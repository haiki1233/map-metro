package com.metro.indoornav.controller;

import com.metro.indoornav.dto.response.FloorMapResponse;
import com.metro.indoornav.dto.response.FloorResponse;
import com.metro.indoornav.service.FloorMapService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Nhom A — docs/RESTAPI_Spec.md muc A */
@RestController
@RequestMapping("/api/floors")
@RequiredArgsConstructor
public class FloorController {

    private final FloorMapService floorMapService;

    @GetMapping
    public List<FloorResponse> listFloors() {
        return floorMapService.listFloors();
    }

    @GetMapping("/{floorId}/map")
    public FloorMapResponse getFloorMap(@PathVariable Integer floorId) {
        return floorMapService.getFloorMap(floorId);
    }
}
