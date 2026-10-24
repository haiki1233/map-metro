package com.metro.indoornav.service;

import com.metro.indoornav.dto.response.NearestNodeResponse;
import com.metro.indoornav.dto.response.RoomSearchResult;
import com.metro.indoornav.entity.Node;
import com.metro.indoornav.exception.ApiException;
import com.metro.indoornav.repository.NodeRepository;
import com.metro.indoornav.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.ArrayList;

/** Nhom B — docs/RESTAPI_Spec.md muc B (FR-03, FR-04, FR-05). */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class SearchService {

    private final RoomRepository roomRepository;
    private final NodeRepository nodeRepository;

    public List<RoomSearchResult> searchRooms(String q, String category, Integer floorId) {
        List<RoomSearchResult> results = new ArrayList<>(
                roomRepository.search(q, category, floorId).stream()
                        .map(r -> new RoomSearchResult(
                                r.getId(), r.getName(), r.getFloorId(), r.getCategory(), r.getNodeId(), "room"))
                        .toList());

        nodeRepository.searchPlaceNodes(q, category, floorId).stream()
                .map(row -> {
                    Integer nodeId = ((Number) row[0]).intValue();
                    String type = (String) row[1];
                    Integer nodeFloorId = ((Number) row[2]).intValue();
                    String name = (String) row[3];
                    return new RoomSearchResult(nodeId, name, nodeFloorId, type, nodeId, "node");
                })
                .forEach(results::add);

        return results;
    }

    public NearestNodeResponse findNearest(Double lat, Double lng, Integer floorId, Double maxDistance) {
        List<Object[]> rows = nodeRepository.findNearestRaw(floorId, lat, lng, maxDistance);
        if (rows.isEmpty()) {
            throw ApiException.notFound("NO_NEARBY_NODE", "Khong tim thay vi tri hop le gan diem da chon");
        }
        Object[] row = rows.get(0);
        Integer nodeId = ((Number) row[0]).intValue();
        Double distance = ((Number) row[1]).doubleValue();

        Node node = nodeRepository.findById(nodeId)
                .orElseThrow(() -> ApiException.notFound("NO_NEARBY_NODE", "Khong tim thay vi tri hop le gan diem da chon"));

        return new NearestNodeResponse(node.getId(), distance, node.getGeomWgs84());
    }
}
