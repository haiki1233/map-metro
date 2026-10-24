package com.metro.indoornav.service;

import com.metro.indoornav.dto.geojson.EdgeProperties;
import com.metro.indoornav.dto.geojson.GeoJsonFeature;
import com.metro.indoornav.dto.geojson.GeoJsonFeatureCollection;
import com.metro.indoornav.dto.geojson.NodeProperties;
import com.metro.indoornav.dto.geojson.RoomProperties;
import com.metro.indoornav.dto.response.FloorMapResponse;
import com.metro.indoornav.dto.response.FloorResponse;
import com.metro.indoornav.entity.Floor;
import com.metro.indoornav.exception.ApiException;
import com.metro.indoornav.repository.EdgeRepository;
import com.metro.indoornav.repository.FloorRepository;
import com.metro.indoornav.repository.NodeRepository;
import com.metro.indoornav.repository.RoomRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;

/** Nhom A — docs/RESTAPI_Spec.md muc A (FR-01, FR-02). */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class FloorMapService {

    private final FloorRepository floorRepository;
    private final NodeRepository nodeRepository;
    private final EdgeRepository edgeRepository;
    private final RoomRepository roomRepository;

    public List<FloorResponse> listFloors() {
        return floorRepository.findAll().stream()
                .sorted(Comparator.comparing(Floor::getLevelOrder))
                .map(f -> new FloorResponse(f.getId(), f.getName(), f.getLevelOrder()))
                .toList();
    }

    public FloorMapResponse getFloorMap(Integer floorId) {
        if (!floorRepository.existsById(floorId)) {
            throw ApiException.notFound("NOT_FOUND", "Khong tim thay floorId = " + floorId);
        }

        var nodeFeatures = nodeRepository.findByFloorId(floorId).stream()
                .map(n -> GeoJsonFeature.of((org.locationtech.jts.geom.Geometry) n.getGeomWgs84(),
                        new NodeProperties(n.getId(), n.getType(), n.getFloorId())))
                .toList();

        var edgeFeatures = edgeRepository.findRenderableByFloor(floorId).stream()
                .map(e -> GeoJsonFeature.of((org.locationtech.jts.geom.Geometry) e.getGeomWgs84(),
                        new EdgeProperties(e.getId(), e.getSource(), e.getTarget(), e.getCostDistance(), e.getEdgeType())))
                .toList();

        var roomFeatures = roomRepository.findByFloorId(floorId).stream()
                .map(r -> {
                    var geometry = (org.locationtech.jts.geom.Geometry) r.getGeomWgs84();
                    double z = geometry.getCoordinate().getZ();
                    Double baseHeight = Double.isFinite(z) ? z : null;
                    return GeoJsonFeature.of(geometry, new RoomProperties(
                            r.getId(), r.getName(), r.getCategory(), r.getFloorId(), baseHeight, r.getHeight()));
                })
                .toList();

        return new FloorMapResponse(
                GeoJsonFeatureCollection.of(nodeFeatures),
                GeoJsonFeatureCollection.of(edgeFeatures),
                GeoJsonFeatureCollection.of(roomFeatures)
        );
    }
}
