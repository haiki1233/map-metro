package com.metro.indoornav.config;

import org.n52.jackson.datatype.jts.JtsModule;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Dang ky JtsModule de Jackson serialize truc tiep org.locationtech.jts.geom.Geometry
 * (Point/LineString/Polygon) sang GeoJSON geometry object dung chuan RFC 7946 — toan bo
 * response nhom A/B/C/D deu dua vao module nay, khong tu viet lai serializer.
 */
@Configuration
public class JacksonConfig {

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jtsModuleCustomizer() {
        return builder -> builder.modulesToInstall(new JtsModule());
    }
}
