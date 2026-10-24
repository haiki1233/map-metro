// File: TransferPoint.java
package com.metro.indoornav.dto.response;

public record TransferPoint(
        Integer nodeId, 
        String transferType, 
        Integer fromFloorId, 
        Integer toFloorId, 
        Double avgTime // <-- Đổi thành avgTime cho khớp Spec
) {
}