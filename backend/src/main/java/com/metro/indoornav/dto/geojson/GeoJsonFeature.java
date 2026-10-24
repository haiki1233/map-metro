package com.metro.indoornav.dto.geojson;

import lombok.Getter;
import org.locationtech.jts.geom.Geometry;

/**
 * 1 Feature GeoJSON chuan RFC 7946. Geometry duoc serialize sang GeoJSON tu dong nho
 * module com.bedatadriven:jackson-datatype-jts (dang ky trong config/JacksonConfig).
 */
@Getter
public class GeoJsonFeature<P> {

    private final String type = "Feature";
    private final Geometry geometry;
    private final P properties;

    public GeoJsonFeature(Geometry geometry, P properties) {
        this.geometry = geometry;
        this.properties = properties;
    }

    public static <P> GeoJsonFeature<P> of(Geometry geometry, P properties) {
        return new GeoJsonFeature<>(geometry, properties);
    }
}
