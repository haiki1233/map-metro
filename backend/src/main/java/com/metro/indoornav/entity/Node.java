package com.metro.indoornav.entity;

import jakarta.persistence.*;
import lombok.*;
import org.locationtech.jts.geom.Point;

/**
 * Map bang `node`. floorId/verticalLinkId co tinh la plain FK id (khong @ManyToOne) de tranh
 * lazy-loading proxy bi serialize nham thanh JSON long nhau trong response GeoJSON — API chi
 * can tra ve id, khong can toan bo object Floor/VerticalLink long trong Node.
 */
@Entity
@Table(name = "node")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Node {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "floor_id", nullable = false)
    private Integer floorId;

    @Column(nullable = false, length = 20)
    private String type; // junction | gate | stair | elevator | escalator | room_entrance

    /** Toa do cuc bo (met), SRID 0 — chi dung noi bo cho routing/nghiep vu quan tri. */
    @Column(name = "geom_local", nullable = false)
    private Point geomLocal;

    /** Toa do WGS84 — trigger DB tu tinh tu geom_local, LUON la nguon duy nhat tra ve public API. */
    @Column(name = "geom_wgs84", insertable = false, updatable = false)
    private Point geomWgs84;

    @Column(name = "vertical_link_id")
    private Integer verticalLinkId;
}
