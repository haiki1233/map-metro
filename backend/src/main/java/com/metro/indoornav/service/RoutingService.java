package com.metro.indoornav.service;

import com.metro.indoornav.dto.geojson.GeoJsonFeature;
import com.metro.indoornav.dto.request.RouteRequest;
import com.metro.indoornav.dto.response.RouteResponse;
import com.metro.indoornav.dto.response.RouteStep;
import com.metro.indoornav.dto.response.TransferPoint;
import com.metro.indoornav.entity.Edge;
import com.metro.indoornav.entity.Floor;
import com.metro.indoornav.entity.Node;
import com.metro.indoornav.exception.ApiException;
import com.metro.indoornav.repository.EdgeRepository;
import com.metro.indoornav.repository.FloorRepository;
import com.metro.indoornav.repository.NodeRepository;
import com.metro.indoornav.repository.RoutingRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.LineString;
import org.locationtech.jts.geom.PrecisionModel;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Locale;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
@Slf4j
public class RoutingService {

    private static final GeometryFactory GEOMETRY_FACTORY = new GeometryFactory(new PrecisionModel(), 4326);
    private static final Set<String> VALID_CRITERIA = Set.of(
            "distance", "time", "least_stairs", "accessible",
            "shortest", "fastest", "less_stairs");

    /** Nguong phan loai goc re — GIONG HET frontend/src/utils/routeGuidance.js. Sua ben nao thi sua ca hai. */
    private static final double STRAIGHT_MAX = 20;
    private static final double SLIGHT_MAX = 45;
    private static final double UTURN_MIN = 135;
    private static final Set<String> VERTICAL_EDGE_TYPES = Set.of("stair", "elevator", "escalator");

    private final RoutingRepository routingRepository;
    private final EdgeRepository edgeRepository;
    private final NodeRepository nodeRepository;
    private final FloorRepository floorRepository;

    @Value("${app.routing.default-criteria:distance}")
    private String defaultCriteria;

    public RouteResponse findRoute(RouteRequest request) {
        if (request.startNodeId().equals(request.endNodeId())) {
            throw ApiException.badRequest("Điểm xuất phát và điểm đến không được trùng nhau");
        }
        String criteria = request.criteria() == null || request.criteria().isBlank()
                ? defaultCriteria : request.criteria();
        if (!VALID_CRITERIA.contains(criteria)) {
            throw ApiException.badRequest(
                    "Criteria không hợp lệ, chỉ chấp nhận distance|time|least_stairs|accessible");
        }

        // 1. Dùng từ khóa 'var' để Java tự suy luận kiểu, hoàn toàn không sợ bị lỗi mất dấu < >
        var hops = routingRepository.findRoute(
                request.startNodeId(), request.endNodeId(), criteria);

        if (hops.isEmpty() || hops.get(hops.size() - 1).node() != request.endNodeId()) {
            throw ApiException.notFound("ROUTE_NOT_FOUND", "Không tìm thấy tuyến đường phù hợp");
        }

        // 2. Tối ưu Query với 'var'
        var edgeIds = hops.stream()
                .filter(h -> h.edge() >= 0).map(h -> (int) h.edge()).toList();
        var nodeIds = hops.stream()
                .map(h -> (int) h.node()).toList();

        var edgesById = edgeRepository.findAllById(edgeIds).stream()
                .collect(Collectors.toMap(Edge::getId, e -> e));
        var nodesById = nodeRepository.findAllById(nodeIds).stream()
                .collect(Collectors.toMap(Node::getId, n -> n));

        // Ten tang that (vd "B2 - Sân ga") thay vi in ra so id. Doc 1 lan, khong query trong vong lap.
        Map<Integer, String> floorNames = floorRepository.findAll().stream()
                .collect(Collectors.toMap(Floor::getId, Floor::getName));

        // 3. Khởi tạo mảng — phải khai báo đầy đủ generic type. Nếu để raw List thì
        // coordinates.toArray(new Coordinate[0]) trả về Object[] và không tạo được LineString.
        List<Coordinate> coordinates = new ArrayList<>();
        List<TransferPoint> transferPoints = new ArrayList<>();
        List<RouteStep> steps = new ArrayList<>();
        double totalDistance = 0;
        double totalTimeEstimate = 0;

        // Bearing cuoi cua buoc truoc — de biet buoc nay re trai/phai hay di thang.
        Double previousArrivalBearing = null;

        // 4. Xử lý logic tuyến đường theo CẶP ĐIỂM
        for (int i = 0; i < hops.size() - 1; i++) {
            var currentHop = hops.get(i);
            var nextHop = hops.get(i + 1);

            var edge = edgesById.get((int) currentHop.edge());
            var fromNode = nodesById.get((int) currentHop.node());
            var toNode = nodesById.get((int) nextHop.node());

            // Du lieu mang luoi co the thieu: chi phi la cot nullable, va node/edge co the khong
            // con ton tai neu bang bi sua tay. Truoc day cac cho nay unbox Double -> NPE -> 500
            // khong ro nguyen nhan. Gio bo qua chang hong va ghi log thay vi lam sap ca tuyen.
            if (edge == null || fromNode == null || toNode == null) {
                log.warn("Bo qua chang khong day du du lieu: seq={}, edgeId={}, fromNodeId={}, toNodeId={}",
                        currentHop.seq(), currentHop.edge(), currentHop.node(), nextHop.node());
                continue;
            }

            totalDistance += costOrZero(edge.getCostDistance());
            totalTimeEstimate += costOrZero(edge.getCostTime());

            boolean isReversed = edge.getTarget() != null && edge.getTarget().equals(fromNode.getId());

            // Toa do cua RIENG buoc nay, gom song song voi `coordinates` toan tuyen.
            List<Coordinate> stepCoordinates = new ArrayList<>();

            if (edge.getGeomWgs84() != null) {
                Coordinate[] edgeCoords = edge.getGeomWgs84().getCoordinates();
                if (isReversed) {
                    for (int j = edgeCoords.length - 1; j >= 0; j--) {
                        appendIfNotDuplicate(coordinates, edgeCoords[j]);
                        appendIfNotDuplicate(stepCoordinates, edgeCoords[j]);
                    }
                } else {
                    for (Coordinate c : edgeCoords) {
                        appendIfNotDuplicate(coordinates, c);
                        appendIfNotDuplicate(stepCoordinates, c);
                    }
                }
            } else {
                // stair/elevator/escalator: trigger DB set geom_wgs84 = NULL (xem database/schema.sql)
                // nen khong co duong de ve. Van noi tiep tuyen toan cuc bang toa do 2 node; thuong
                // trung nhau (thang may cung truc X,Y giua 2 tang) nen appendIfNotDuplicate se bo qua.
                // Node cung co the thieu geom_wgs84 (du lieu nhap tay / node moi chua chuan hoa) —
                // phai kiem tra null truoc khi getCoordinate(), neu khong se NPE -> 500 ca tuyen.
                if (fromNode.getGeomWgs84() != null) {
                    appendIfNotDuplicate(coordinates, fromNode.getGeomWgs84().getCoordinate());
                }
                if (toNode.getGeomWgs84() != null) {
                    appendIfNotDuplicate(coordinates, toNode.getGeomWgs84().getCoordinate());
                }
            }

            if (!Objects.equals(fromNode.getFloorId(), toNode.getFloorId())) {
                transferPoints.add(new TransferPoint(
                        fromNode.getId(),
                        edge.getEdgeType(),
                        fromNode.getFloorId(),
                        toNode.getFloorId(),
                        costOrZero(edge.getCostTime())
                ));
            }

            // --- Phan loai huong re + sinh cau huong dan ---
            Integer floorId = fromNode.getFloorId();
            String maneuver;
            String instruction;
            boolean isTransfer = isTransferEdge(
                    edge.getEdgeType(), fromNode.getFloorId(), toNode.getFloorId());

            if (isTransfer) {
                String edgeType = normalizeEdgeType(edge.getEdgeType());
                maneuver = switch (edgeType) {
                    case "elevator" -> "ELEVATOR";
                    case "escalator" -> "ESCALATOR";
                    case "stair" -> "STAIR";
                    default -> "TRANSFER";
                };
                instruction = switch (edgeType) {
                    case "elevator" -> "Sử dụng thang máy chuyển sang " + floorName(floorNames, toNode.getFloorId());
                    case "escalator" -> "Sử dụng thang cuốn chuyển sang " + floorName(floorNames, toNode.getFloorId());
                    case "stair" -> "Sử dụng cầu thang bộ chuyển sang " + floorName(floorNames, toNode.getFloorId());
                    default -> "Chuyển sang " + floorName(floorNames, toNode.getFloorId());
                };
            } else {
                Double departureBearing = departureBearing(stepCoordinates);
                if (i == 0 || previousArrivalBearing == null || departureBearing == null) {
                    // Khong co huong vao (buoc dau, hoac buoc truoc la thang may khong co hinh hoc).
                    maneuver = i == 0 ? "DEPART" : "STRAIGHT";
                } else {
                    maneuver = classifyManeuver(previousArrivalBearing, departureBearing);
                }
                instruction = buildInstruction(maneuver, costOrZero(edge.getCostDistance()));
            }

            previousArrivalBearing = isTransfer ? null : arrivalBearing(stepCoordinates);

            // Hinh hoc rieng cua buoc: NULL khi chuyen tang (khong ve duoc duong xuyen tang tren
            // ban do 2D tung tang). Duoi 2 diem cung khong tao duoc LineString.
            GeoJsonFeature<Object> stepGeometry = null;
            if (stepCoordinates.size() >= 2) {
                stepGeometry = GeoJsonFeature.of(
                        GEOMETRY_FACTORY.createLineString(stepCoordinates.toArray(new Coordinate[0])),
                        Map.of());
            }

            steps.add(new RouteStep(
                    i + 1,
                    instruction,
                    costOrZero(edge.getCostDistance()),
                    costOrZero(edge.getCostTime()),
                    floorId,
                    maneuver,
                    stepGeometry
            ));
        }

        LineString finalGeometry = createRouteLineString(coordinates);

        return new RouteResponse(
                round1(totalDistance),
                round1(totalTimeEstimate),
                GeoJsonFeature.of(finalGeometry, Map.of()),
                transferPoints,
                steps
        );
    }

    /** Cot chi phi la nullable trong schema — thieu du lieu thi coi nhu 0 chu khong nem NPE. */
    private static double costOrZero(Double value) {
        return value == null ? 0.0 : value;
    }

    static boolean isTransferEdge(String edgeType, Integer fromFloorId, Integer toFloorId) {
        return !Objects.equals(fromFloorId, toFloorId)
                || VERTICAL_EDGE_TYPES.contains(normalizeEdgeType(edgeType));
    }

    private static String normalizeEdgeType(String edgeType) {
        return edgeType == null ? "" : edgeType.toLowerCase(Locale.ROOT);
    }

    private void appendIfNotDuplicate(List<Coordinate> coordinates, Coordinate c) {
        if (coordinates.isEmpty() || !coordinates.get(coordinates.size() - 1).equals2D(c)) {
            coordinates.add(c);
        }
    }

    static LineString createRouteLineString(List<Coordinate> coordinates) {
        Coordinate[] points = coordinates.size() < 2
                ? new Coordinate[0]
                : coordinates.toArray(new Coordinate[0]);
        return GEOMETRY_FACTORY.createLineString(points);
    }

    /**
     * Huong re tai cho giao nhau giua doan vao va doan ra.
     *
     * @param inBearing  bearing luc DEN giao lo (do)
     * @param outBearing bearing luc ROI giao lo (do)
     * @return STRAIGHT | SLIGHT_LEFT | LEFT | U_TURN | SLIGHT_RIGHT | RIGHT
     */
    static String classifyManeuver(double inBearing, double outBearing) {
        // Bearing tang theo chieu kim dong ho => delta duong la re PHAI.
        double delta = ((outBearing - inBearing + 540) % 360) - 180;
        double magnitude = Math.abs(delta);
        if (magnitude < STRAIGHT_MAX) return "STRAIGHT";
        if (magnitude < SLIGHT_MAX) return delta > 0 ? "SLIGHT_RIGHT" : "SLIGHT_LEFT";
        if (magnitude <= UTURN_MIN) return delta > 0 ? "RIGHT" : "LEFT";
        return "U_TURN";
    }

    private static String buildInstruction(String maneuver, Double distance) {
        String meters = "khoảng " + Math.round(distance) + "m";
        return switch (maneuver) {
            case "DEPART" -> "Đi thẳng " + meters;
            case "STRAIGHT" -> "Tiếp tục đi thẳng " + meters;
            case "SLIGHT_LEFT" -> "Chếch sang trái rồi đi thẳng " + meters;
            case "SLIGHT_RIGHT" -> "Chếch sang phải rồi đi thẳng " + meters;
            case "LEFT" -> "Rẽ trái và đi thẳng " + meters;
            case "RIGHT" -> "Rẽ phải và đi thẳng " + meters;
            case "U_TURN" -> "Quay đầu rồi đi thẳng " + meters;
            default -> "Đi thẳng " + meters;
        };
    }

    /** Bearing luc roi diem dau cua doan — lay 2 diem khac nhau dau tien (doan CAD co the lap dinh). */
    private static Double departureBearing(List<Coordinate> coords) {
        if (coords.size() < 2) return null;
        Coordinate first = coords.get(0);
        for (int i = 1; i < coords.size(); i++) {
            if (!first.equals2D(coords.get(i))) return bearingBetween(first, coords.get(i));
        }
        return null;
    }

    /** Bearing luc den diem cuoi cua doan — lay 2 diem khac nhau cuoi cung. */
    private static Double arrivalBearing(List<Coordinate> coords) {
        if (coords.size() < 2) return null;
        Coordinate last = coords.get(coords.size() - 1);
        for (int i = coords.size() - 2; i >= 0; i--) {
            if (!last.equals2D(coords.get(i))) return bearingBetween(coords.get(i), last);
        }
        return null;
    }

    /** Bearing tu a den b, do theo chieu kim dong ho tu Bac (0..360). */
    private static double bearingBetween(Coordinate a, Coordinate b) {
        double lat1 = Math.toRadians(a.getY());
        double lat2 = Math.toRadians(b.getY());
        double deltaLon = Math.toRadians(b.getX() - a.getX());
        double y = Math.sin(deltaLon) * Math.cos(lat2);
        double x = Math.cos(lat1) * Math.sin(lat2) - Math.sin(lat1) * Math.cos(lat2) * Math.cos(deltaLon);
        return (Math.toDegrees(Math.atan2(y, x)) + 360) % 360;
    }

    private Double round1(double value) {
        return Math.round(value * 10.0) / 10.0;
    }

    private String floorName(Map<Integer, String> floorNames, Integer floorId) {
        if (floorId == null) return "tầng khác";
        return floorNames.getOrDefault(floorId, "tầng " + floorId);
    }
}