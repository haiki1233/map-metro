package com.metro.indoornav.repository;

import com.metro.indoornav.entity.Edge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface EdgeRepository extends JpaRepository<Edge, Integer> {

    /** Group A: chi tra edge co the ve len ban do 2D cua 1 tang (corridor cung tang, geom khong NULL). */
    @Query("""
            SELECT e FROM Edge e
            WHERE e.geomWgs84 IS NOT NULL
              AND e.source IN (SELECT n.id FROM Node n WHERE n.floorId = :floorId)
            """)
    List<Edge> findRenderableByFloor(@Param("floorId") Integer floorId);
}