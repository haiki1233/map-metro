package com.metro.indoornav.dto.response;

import com.metro.indoornav.dto.geojson.GeoJsonFeature;

/**
 * 1 buoc huong dan trong steps cua POST /api/route — FR-09, docs/RESTAPI_Spec.md muc C.1.
 *
 * <p>{@code maneuver} de frontend biet ve mui ten re huong nao. Tap gia tri:
 * DEPART | STRAIGHT | SLIGHT_LEFT | LEFT | SLIGHT_RIGHT | RIGHT | U_TURN
 * | ELEVATOR | ESCALATOR | STAIR. Nguong phan loai goc giong het
 * frontend/src/utils/routeGuidance.js — sua ben nao thi sua ca hai.
 *
 * <p>{@code floorId} la tang dang di TRONG buoc nay (khong phai tang dich) de ban do biet
 * phai hien tang nao. Voi buoc chuyen tang, day la tang xuat phat — nguoi dung con phai di
 * tren tang do moi toi duoc thang may/cau thang.
 *
 * <p>{@code geometry} la LineString WGS84 cua RIENG buoc nay, NULL voi buoc chuyen tang: trigger
 * DB (trg_fn_edge_before_insert trong database/schema.sql) khong sinh geom_wgs84 cho
 * stair/elevator/escalator, va ban do 2D tung tang cung khong the ve duong xuyen tang.
 */
public record RouteStep(
        Integer order,
        String instruction,
        Double distance,
        Double duration,
        Integer floorId,
        String maneuver,
        GeoJsonFeature<Object> geometry
) {
}