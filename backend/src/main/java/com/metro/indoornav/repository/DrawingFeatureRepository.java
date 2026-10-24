package com.metro.indoornav.repository;

import com.metro.indoornav.entity.DrawingFeature;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface DrawingFeatureRepository extends JpaRepository<DrawingFeature, Integer> {

    List<DrawingFeature> findByFloorId(Integer floorId);

    /**
     * Gom toan bo hinh hoc nen cua 1 tang thanh MOT chuoi GeoJSON FeatureCollection, dung ngay
     * trong PostgreSQL.
     *
     * Vi sao khong tra List&lt;DrawingFeature&gt; roi tu serialize o Java: mot tang CAD that co the
     * vai tram nghin feature; build GeoJSON bang jsonb_agg giu 1 dong ket qua duy nhat, khong
     * phai map N entity -> N object -> N string, giam manh bo nho va thoi gian.
     *
     * Vi sao phai ST_Force2D: cot `geom_wgs84` la geometry(GeometryZ, 4326) — GeoJSON (RFC 7946)
     * chi dinh nghia toa do 2D, de nguyen Z se sinh ra GeoJSON khong chuan.
     *
     * Các cột phân loại/tên/style được đưa vào properties để GeoJSON và MapLibre dùng trực tiếp.
     *
     * Tra ve String tho (khong phai entity/DTO) de Controller tra thang voi
     * MediaType.APPLICATION_JSON — chuoi da la JSON hop le, khong can parse lai roi serialize.
     */
    @Query(value = """
            SELECT jsonb_build_object(
                'type', 'FeatureCollection',
                'features', COALESCE(jsonb_agg(feature), '[]'::jsonb)
            )::text
            FROM (
                SELECT jsonb_build_object(
                    'type', 'Feature',
                    'geometry', ST_AsGeoJSON(ST_Force2D(geom_wgs84))::jsonb,
                    'properties', properties || jsonb_build_object(
                        'layer_name', layer_name,
                        'feature_type', feature_type,
                        'name', name,
                        'style', style
                    )
                ) AS feature
                FROM drawing_feature
                WHERE floor_id = :floorId
            ) AS features_collection
            """, nativeQuery = true)
    String findGeoJsonByFloorId(@Param("floorId") Integer floorId);
}
