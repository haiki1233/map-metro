package com.metro.indoornav.entity;

import jakarta.persistence.*;
import lombok.*;
import org.locationtech.jts.geom.Polygon;

@Entity
@Table(name = "room")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Room {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "floor_id", nullable = false)
    private Integer floorId;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(length = 50)
    private String category;

    @Column(nullable = false)
    private Double height;

    @Column(name = "geom_wgs84", nullable = false)
    private Polygon geomWgs84;

    /** Node dai dien loi vao room nay — dung khi tim duong DEN room (khong tham gia routing truc tiep). */
    @Column(name = "node_id")
    private Integer nodeId;
}
