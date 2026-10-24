-- Chuan bi floor cho pilot "Bai xe Van Thanh Park" truoc khi chay
-- import_van_thanh_parking_pilot.py (script Admin API can floorId da ton tai).
--
-- originLat/originLng la 1 diem tham khao lay tu Google Maps cho ca ga (xem gis-pipeline/README.md
-- va docs/REVIEW_NOTES.md) — KHONG phai georeference chinh xac, chi du de test co che pipeline.

INSERT INTO floor (id, name, level_order, description) VALUES
  (3, 'Bãi xe Văn Thánh Park (thử nghiệm)', 0,
   'Du lieu that tu 44_X_PARKING SPACE.dwg - vi tri GPS la gan dung, chua georeference chinh xac')
ON CONFLICT (id) DO NOTHING;

INSERT INTO floor_transform (floor_id, origin_lat, origin_lng, scale_x, scale_y, rotation_deg) VALUES
  (3, 10.7957678, 106.7150441, 1.0, 1.0, 0.0)
ON CONFLICT (floor_id) DO NOTHING;
