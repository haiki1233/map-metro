package com.metro.indoornav.service;

import com.metro.indoornav.entity.FloorTransform;
import com.metro.indoornav.exception.ApiException;
import com.metro.indoornav.repository.FloorTransformRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/** Cau hinh phep bien doi toa do theo tang — phuc vu luong render ban do. */
@Service
@RequiredArgsConstructor
public class FloorTransformService {

    private final FloorTransformRepository floorTransformRepository;

    /**
     * Ban entity cho luong render ban do (GET /api/map/floors/{floorId}/transform) — can ca
     * scale/rotation chu khong chi origin.
     */
    @Transactional(readOnly = true)
    public FloorTransform getEntity(Integer floorId) {
        return floorTransformRepository.findById(floorId)
                .orElseThrow(() -> ApiException.notFound("NOT_FOUND", "Chua cau hinh transform cho floorId = " + floorId));
    }
}