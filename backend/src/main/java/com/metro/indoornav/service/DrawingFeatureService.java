package com.metro.indoornav.service;

import com.metro.indoornav.repository.DrawingFeatureRepository;
import com.metro.indoornav.repository.FloorRepository;
import com.metro.indoornav.exception.ApiException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Hinh hoc NEN cua ban ve CAD theo tang (render ban do 2D dong).
 *
 * Tra ve String tho la JSON da dung san tu PostgreSQL — khong parse lai thanh Object roi
 * serialize lai, vi (a) khong can thiet, (b) voi vai tram nghin feature moi tang thi buoc
 * round-trip qua Jackson ton them thoi gian va bo nho vo ich.
 */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class DrawingFeatureService {

    private final DrawingFeatureRepository drawingFeatureRepository;
    private final FloorRepository floorRepository;

    public String getFeatureCollectionGeoJson(Integer floorId) {
        if (!floorRepository.existsById(floorId)) {
            throw ApiException.notFound("NOT_FOUND", "Khong tim thay floorId = " + floorId);
        }
        String geoJson = drawingFeatureRepository.findGeoJsonByFloorId(floorId);
        // Tang chua co du lieu CAD nao cung la truong hop hop le (nen tra FeatureCollection rong
        // de frontend ve duoc tile nen, thay vi 404). COALESCE trong query da lo phan nay, nhung
        // van giu fallback phong khi query tra NULL vi ly do khac.
        return geoJson != null ? geoJson : "{\"type\":\"FeatureCollection\",\"features\":[]}";
    }
}
