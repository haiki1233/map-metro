package com.metro.indoornav.repository;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Goi truc tiep cac ham SQL cua database/schema.sql khong ung voi 1 entity JPA cu the
 * (fn_find_route) — dung JdbcTemplate cho gon thay vi @Query tra ve kieu du lieu TABLE(...) phuc tap.
 */
@Repository
@RequiredArgsConstructor
public class RoutingRepository {

    private final JdbcTemplate jdbcTemplate;

    /** Ung voi C.1 POST /api/route — chay pgr_dijkstra qua wrapper fn_find_route. */
    public List<RouteHop> findRoute(int startNodeId, int endNodeId, String criteria) {
        return jdbcTemplate.query(
                "SELECT seq, node, edge, cost, agg_cost FROM fn_find_route(?, ?, ?)",
                (rs, rowNum) -> new RouteHop(
                        rs.getInt("seq"),
                        rs.getLong("node"),
                        rs.getLong("edge"),
                        rs.getDouble("cost"),
                        rs.getDouble("agg_cost")
                ),
                startNodeId, endNodeId, criteria
        );
    }

    /** 1 dong ket qua tra ve tu fn_find_route: seq trong tuyen, node/edge id, cost cua chang, agg_cost luy ke. */
    public record RouteHop(int seq, long node, long edge, double cost, double aggCost) {
    }
}