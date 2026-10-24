package com.metro.indoornav.controller;

import com.metro.indoornav.entity.FloorTransform;
import com.metro.indoornav.service.DrawingFeatureService;
import com.metro.indoornav.service.FloorTransformService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

/**
 * API cong khai de frontend render ban do dong: tam ban do (floor_transform) + hinh hoc nen
 * (drawing_feature). Xem docs/RESTAPI_Spec.md nhom A.
 *
 * CORS: KHONG dung @CrossOrigin o day — da co bean CorsConfigurationSource trong SecurityConfig
 * ap cho "/**", va @CrossOrigin tren controller se bi SecurityConfig ghi de (cau hinh cua
 * Spring Security uu tien hon annotation). Sua origin thi sua `app.cors.allowed-origins`.
 *
 * Bao mat: duong dan nam duoi /api/map/** nen khop rule permitAll() cua SecurityConfig.
 */
@RestController
@RequestMapping("/api/map")
@RequiredArgsConstructor
public class MapController {

    private final FloorTransformService floorTransformService;
    private final DrawingFeatureService drawingFeatureService;

    /** Tam ban do cua 1 tang — frontend can TRUOC khi render MapContainer (center la immutable). */
    @GetMapping("/floors/{floorId}/transform")
    public FloorTransform getFloorTransform(@PathVariable Integer floorId) {
        return floorTransformService.getEntity(floorId);
    }

    /**
     * Hinh hoc nen cua 1 tang dang GeoJSON FeatureCollection.
     *
     * Tra ve String kem MediaType.APPLICATION_JSON (khong phai text/plain): chuoi da la JSON hop
     * le tu PostgreSQL, khai bao dung content-type de axios/trinh duyet parse san thanh object —
     * neu tra text/plain, `data` o frontend se la String va <GeoJSON data={...}> se hong.
     */
    @GetMapping(value = "/features/{floorId}", produces = MediaType.APPLICATION_JSON_VALUE)
    public String getFloorFeatures(@PathVariable Integer floorId) {
        return drawingFeatureService.getFeatureCollectionGeoJson(floorId);
    }
}
