package com.metro.indoornav.controller;

import com.metro.indoornav.dto.response.NearestNodeResponse;
import com.metro.indoornav.dto.response.RoomSearchResult;
import com.metro.indoornav.service.SearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/** Nhom B — docs/RESTAPI_Spec.md muc B (FR-03, FR-04, FR-05) */
@RestController
@RequiredArgsConstructor
public class SearchController {

    private final SearchService searchService;

    @GetMapping("/api/rooms/search")
    public List<RoomSearchResult> searchRooms(@RequestParam(defaultValue = "") String q,
                                               @RequestParam(required = false) String category,
                                               @RequestParam(required = false) Integer floorId) {
        return searchService.searchRooms(q, category, floorId);
    }

    @GetMapping("/api/nodes/nearest")
    public NearestNodeResponse findNearestNode(@RequestParam Double lat,
                                                @RequestParam Double lng,
                                                @RequestParam Integer floorId,
                                                @RequestParam(defaultValue = "15") Double maxDistance) {
        return searchService.findNearest(lat, lng, floorId, maxDistance);
    }
}
