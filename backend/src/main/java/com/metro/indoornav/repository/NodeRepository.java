package com.metro.indoornav.repository;

import com.metro.indoornav.entity.Node;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface NodeRepository extends JpaRepository<Node, Integer> {

    List<Node> findByFloorId(Integer floorId);

    @Query(value = """
            SELECT n.id, n.type, n.floor_id,
                   CASE
                       WHEN n.type IN ('elevator', 'stair', 'escalator') THEN
                           COALESCE(
                               NULLIF(regexp_replace(vl.label, '^TD_F1:[0-9]+ - ', ''), ''),
                               CASE n.type
                                   WHEN 'elevator' THEN 'Thang máy ' || n.id::text
                                   WHEN 'stair' THEN 'Thang bộ ' || n.id::text
                                   ELSE 'Thang cuốn ' || n.id::text
                               END
                           )
                       WHEN n.type = 'gate' THEN 'Cổng ' || n.id::text
                       ELSE 'Bãi đỗ xe ' || n.id::text
                   END AS name
            FROM node n
            LEFT JOIN vertical_link vl ON vl.id = n.vertical_link_id
            WHERE n.type IN ('gate', 'parking', 'elevator', 'stair', 'escalator')
              AND (:category IS NULL OR n.type = :category)
              AND (:floorId IS NULL OR n.floor_id = :floorId)
              AND (
                  :q = ''
                  OR n.id::text = :q
                  OR immutable_unaccent(
                      CASE n.type
                          WHEN 'gate' THEN 'Cổng gate entrance '
                          WHEN 'parking' THEN 'Bãi đỗ xe bãi xe parking '
                          WHEN 'elevator' THEN 'Thang máy elevator lift '
                          WHEN 'stair' THEN 'Thang bộ cầu thang stair '
                          ELSE 'Thang cuốn escalator '
                      END
                      || COALESCE(vl.label, '')
                      || ' ' || n.id::text
                  ) ILIKE immutable_unaccent('%' || :q || '%')
              )
            ORDER BY n.type, name, n.floor_id, n.id
            LIMIT 50
            """, nativeQuery = true)
    List<Object[]> searchPlaceNodes(@Param("q") String q,
                                    @Param("category") String category,
                                    @Param("floorId") Integer floorId);

    /**
     * B.2 GET /api/nodes/nearest — tim node gan nhat trong ban kinh maxDistance (met) quanh diem
     * (lat,lng) da cho, gioi han trong 1 tang.
     *
     * Do tren ellipsoid qua phep ep kieu ::geography thay vi tren geom_local: geom_local chi duoc
     * sinh khi ban ghi duoc nap bang toa do cuc bo, con du lieu CAD/nhap tay chi co geom_wgs84.
     * ST_DWithin + toan tu <-> tren geography deu tinh bang met va deu dung duoc chi muc GIST
     * idx_node_geom_wgs84.
     */
    @Query(value = """
            WITH p AS (SELECT ST_SetSRID(ST_MakePoint(:lng, :lat, 0), 4326)::geography AS g)
            SELECT n.id AS node_id, ST_Distance(n.geom_wgs84::geography, p.g) AS distance
            FROM node n, p
            WHERE n.floor_id = :floorId
              AND n.geom_wgs84 IS NOT NULL
              AND ST_DWithin(n.geom_wgs84::geography, p.g, :maxDistance)
            ORDER BY n.geom_wgs84::geography <-> p.g
            LIMIT 1
            """, nativeQuery = true)
    List<Object[]> findNearestRaw(@Param("floorId") Integer floorId,
                                   @Param("lat") Double lat,
                                   @Param("lng") Double lng,
                                   @Param("maxDistance") Double maxDistance);
}