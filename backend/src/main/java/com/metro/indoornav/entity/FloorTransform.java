package com.metro.indoornav.entity;

import jakarta.persistence.*;
import lombok.*;

/**
 * Map 1-1 voi bang `floor_transform` — tham so Affine quy doi met (local) <-> WGS84.
 * PK trung voi FK (floor_id) nen dung @Id tren chinh cot do (shared primary key).
 */
@Entity
@Table(name = "floor_transform")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FloorTransform {

    @Id
    @Column(name = "floor_id")
    private Integer floorId;

    @Column(name = "origin_lat", nullable = false)
    private Double originLat;

    @Column(name = "origin_lng", nullable = false)
    private Double originLng;

    @Column(name = "scale_x", nullable = false)
    private Double scaleX;

    @Column(name = "scale_y", nullable = false)
    private Double scaleY;

    @Column(name = "rotation_deg", nullable = false)
    private Double rotationDeg;
}
