package com.metro.indoornav.entity;

import jakarta.persistence.*;
import lombok.*;
import org.locationtech.jts.geom.LineString;

/**
 * Map bang `edge` — input cho pgr_dijkstra. geom_local/geom_wgs84/cost_* co the duoc trigger
 * DB tu tinh (xem trg_fn_edge_before_insert trong database/schema.sql) neu insert NULL, nen
 * cac field nay de insertable=true nhung nullable o tang Java — gia tri cuoi cung phai doc lai
 * tu DB sau khi insert (xem EdgeRepository/AdminEdgeService).
 */
@Entity
@Table(name = "edge")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Edge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    private Integer source;

    @Column(nullable = false)
    private Integer target;

    @Column(name = "edge_type", nullable = false, length = 20)
    private String edgeType; // corridor | stair | elevator | escalator

    @Column(name = "geom_local")
    private LineString geomLocal;

    @Column(name = "geom_wgs84")
    private LineString geomWgs84;

    @Column(name = "cost_distance")
    private Double costDistance;

    @Column(name = "cost_time")
    private Double costTime;

    @Column(name = "cost_least_stairs")
    private Double costLeastStairs;

    @Column(name = "reverse_cost_distance")
    private Double reverseCostDistance;

    @Column(name = "reverse_cost_time")
    private Double reverseCostTime;

    @Column(name = "reverse_cost_least_stairs")
    private Double reverseCostLeastStairs;
}
