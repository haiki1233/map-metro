package com.metro.indoornav.entity;

import jakarta.persistence.*;
import lombok.*;

/** Map 1-1 voi bang `floor` trong database/schema.sql */
@Entity
@Table(name = "floor")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Floor {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 50)
    private String name;

    @Column(name = "level_order", nullable = false, unique = true)
    private Integer levelOrder;

    @Column(length = 255)
    private String description;
}
