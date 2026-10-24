package com.metro.indoornav.entity;

import jakarta.persistence.*;
import lombok.*;

/** Dai dien 1 thang may/thang bo/thang cuon VAT LY, co the noi node o nhieu tang. */
@Entity
@Table(name = "vertical_link")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VerticalLink {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(length = 100)
    private String label;

    @Column(name = "transfer_type", nullable = false, length = 20)
    private String transferType; // stair | elevator | escalator

    @Column(name = "avg_time_per_floor", nullable = false)
    private Double avgTimePerFloor;
}
