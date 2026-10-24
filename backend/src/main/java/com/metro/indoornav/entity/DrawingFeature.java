package com.metro.indoornav.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;
import org.locationtech.jts.geom.Geometry;

/**
 * Map 1-1 voi bang `drawing_feature` — hinh hoc NEN cua ban ve CAD (tuong, via he, tham co,
 * rao...), khac voi `room`/`edge`/`node` la du lieu NGHIEP VU (tim duong).
 *
 * `properties` va `style` la JSONB linh hoat nen map thanh String thay vi DTO co dinh.
 * {@code @JdbcTypeCode(SqlTypes.JSON)} bat
 * Hibernate 6 dung JSON JdbcType: bind tham so bang setObject(..., Types.OTHER) — dung dinh dang
 * PostgreSQL can cho cot jsonb (neu bind nhu varchar, INSERT/UPDATE se loi
 * "column is of type jsonb but expression is of type character varying").
 *
 * Luu y: entity nay CHI duoc doc trong luong render ban do; tang nen duoc ghi bang script GIS
 * (xem gis-pipeline/), khong qua Hibernate.
 */
@Entity
@Table(name = "drawing_feature")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DrawingFeature {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "floor_id", nullable = false)
    private Integer floorId;

    @Column(name = "layer_name", length = 120)
    private String layerName;

    @Column(name = "feature_type", length = 50)
    private String featureType;

    @Column(length = 150)
    private String name;

    /** JSONB nguon — giu nguyen dang chuoi JSON, khong deserialize o tang entity. */
    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "properties", columnDefinition = "jsonb", nullable = false)
    private String properties;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "style", columnDefinition = "jsonb", nullable = false)
    private String style;

    /**
     * Cot trong DB la geometry(GeometryZ, 4326) — co cao do Z. Entity dung Geometry (khong phai
     * Polygon/LineString) vi mot layer CAD co the lan lon ca vung va duong, dung nhu khai bao
     * `geometry(GeometryZ, ...)` cua bang. Cac API tra GeoJSON deu ST_Force2D truoc khi xuat.
     */
    @Column(name = "geom_wgs84", nullable = false)
    private Geometry geomWgs84;
}
