package com.metro.indoornav.dto.geojson;

import lombok.Getter;

import java.util.List;

@Getter
public class GeoJsonFeatureCollection<P> {

    private final String type = "FeatureCollection";
    private final List<GeoJsonFeature<P>> features;

    public GeoJsonFeatureCollection(List<GeoJsonFeature<P>> features) {
        this.features = features;
    }

    public static <P> GeoJsonFeatureCollection<P> of(List<GeoJsonFeature<P>> features) {
        return new GeoJsonFeatureCollection<>(features);
    }
}
