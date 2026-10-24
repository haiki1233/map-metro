"""
PILOT SCRIPT — thu nghiem pipeline CAD -> GeoJSON -> DB that (khong phai code san xuat).

Trich xuat du lieu THAT tu data/processed/01. VAN THANH PARK/44_X_PARKING SPACE.dxf
(178 o do xe may + 2 cong ra vao, da xac nhan bang mat qua anh render truoc khi viet
script nay) va nap vao floorId=3 (da tao san, xem gis-pipeline/scripts/setup_pilot_floor.sql)
qua chinh REST Admin API dang chay that o localhost:8080 — khong insert thang vao DB de
test luon ca tang Backend.

GIOI HAN DA BIET (khong che giau):
- Toa do GPS goc (floor_transform.origin_lat/lng) la 1 diem tham khao lay tu Google Maps
  cho ca ga, KHONG phai georeference chinh xac bang 2-3 diem goc toa nha that trong QGIS.
  Vi tri hien tren ban do se lech so voi thuc te, chi dung de test co che, chua dung de
  dieu huong that.
- Mang luoi node/edge (2 cong + 1 nut giao vao khu do xe) la DON GIAN HOA — cac o do xe
  deu tro ve CHUNG 1 node dai dien (khong co duong di tung hang xe rieng), vi du lieu CAD
  khong co san lop "duong di bo" noi tu cong toi khu do xe nay (xem gis-pipeline/README.md
  phan BLOCKER). Muon co duong di chi tiet hon can nguoi so hoa them trong QGIS.
"""
import math
import sys
import ezdxf
import requests

DXF_PATH = "data/processed/01. VAN THANH PARK/44_X_PARKING SPACE.dxf"
API_BASE = "http://localhost:8080"
FLOOR_ID = 3
THRESH = 1e6  # loc bo cac INSERT block loi (toa do hang ty do ODA convert sinh ra)
MM_TO_M = 1000.0

# Phai khop CHINH XAC voi database/schema.sql::fn_local_to_wgs84 (rotation=0, scale=1 o day)
ORIGIN_LAT = 10.7957678
ORIGIN_LNG = 106.7150441
METERS_PER_DEG_LAT = 111320.0
METERS_PER_DEG_LNG = METERS_PER_DEG_LAT * math.cos(math.radians(ORIGIN_LAT))


def local_point(x_mm, y_mm):
    """DXF don vi mm -> met (geom_local cua schema.sql la SRID 0, don vi met) — dung cho Node (Admin API tu convert sang WGS84)."""
    return [round(x_mm / MM_TO_M, 3), round(y_mm / MM_TO_M, 3)]


def wgs84_point(x_mm, y_mm):
    """DXF mm -> WGS84 (lng,lat) — dung cho Room, vi AdminRoomRequest.geometry luu THANG vao geom_wgs84,
    khong co conversion o Backend nhu Node (xem AdminRoomService, khac AdminNodeService)."""
    x_m, y_m = x_mm / MM_TO_M, y_mm / MM_TO_M
    lat = ORIGIN_LAT + (y_m / METERS_PER_DEG_LAT)
    lng = ORIGIN_LNG + (x_m / METERS_PER_DEG_LNG)
    return [round(lng, 9), round(lat, 9)]


def extract():
    doc = ezdxf.readfile(DXF_PATH)
    msp = doc.modelspace()

    stalls = []
    for e in msp.query('LWPOLYLINE[layer=="ARC-PAKING-AR"]'):
        pts = [(p[0], p[1]) for p in e.get_points("xy")]
        if e.closed and all(abs(x) < THRESH and abs(y) < THRESH for x, y in pts):
            stalls.append(pts)

    gate_pts = {"top": [], "bottom": []}
    for e in msp.query('LWPOLYLINE[layer=="gate"]'):
        for p in e.get_points("xy"):
            bucket = "top" if p[1] > 0 else "bottom"
            gate_pts[bucket].append((p[0], p[1]))
    for e in msp.query('ARC[layer=="gate"]'):
        c = e.dxf.center
        bucket = "top" if c.y > 0 else "bottom"
        gate_pts[bucket].append((c.x, c.y))

    def centroid(pts):
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        return sum(xs) / len(xs), sum(ys) / len(ys)

    gate_top = centroid(gate_pts["top"])
    gate_bottom = centroid(gate_pts["bottom"])

    return stalls, gate_top, gate_bottom


def login():
    r = requests.post(f"{API_BASE}/api/auth/login", json={"username": "admin", "password": "admin123"})
    r.raise_for_status()
    return r.json()["token"]


def main():
    stalls, gate_top, gate_bottom = extract()
    print(f"Trich xuat: {len(stalls)} cho do xe, cong tren={gate_top}, cong duoi={gate_bottom}")

    token = login()
    headers = {"Authorization": f"Bearer {token}"}

    # --- 3 node: 2 cong + 1 nut giao dai dien khu do xe ---
    junction_local = local_point(-1900, 1000)  # canh tay-phia khu do xe, DON GIAN HOA (xem docstring)

    def create_node(local_xy, node_type):
        body = {"localCoordinates": {"x": local_xy[0], "y": local_xy[1]}, "type": node_type, "floorId": FLOOR_ID}
        r = requests.post(f"{API_BASE}/api/admin/nodes", json=body, headers=headers)
        r.raise_for_status()
        return r.json()["id"]

    n_gate_top = create_node(local_point(*gate_top), "gate")
    n_gate_bottom = create_node(local_point(*gate_bottom), "gate")
    n_junction = create_node(junction_local, "junction")
    print(f"Node: cong_tren={n_gate_top} cong_duoi={n_gate_bottom} junction={n_junction}")

    def create_edge(source, target):
        body = {"source": source, "target": target, "edgeType": "corridor", "costOverride": None}
        r = requests.post(f"{API_BASE}/api/admin/edges", json=body, headers=headers)
        r.raise_for_status()
        return r.json()["id"]

    edge_pairs = [
        (n_gate_top, n_gate_bottom), (n_gate_bottom, n_gate_top),
        (n_gate_top, n_junction), (n_junction, n_gate_top),
        (n_gate_bottom, n_junction), (n_junction, n_gate_bottom),
    ]
    for s, t in edge_pairs:
        create_edge(s, t)
    print(f"Da tao {len(edge_pairs)} edge (2 chieu giua 3 node)")

    # --- rooms: 178 cho do xe, deu tro ve node junction dai dien ---
    def create_room(idx, ring_mm):
        ring_wgs84 = [wgs84_point(x, y) for x, y in ring_mm]
        ring_wgs84.append(ring_wgs84[0])  # GeoJSON Polygon phai khep vong
        geometry = {"type": "Polygon", "coordinates": [ring_wgs84]}
        body = {
            "name": f"Cho do xe may #{idx+1}",
            "geometry": geometry,
            "floorId": FLOOR_ID,
            "category": "parking_space",
            "nodeId": n_junction,
        }
        r = requests.post(f"{API_BASE}/api/admin/rooms", json=body, headers=headers)
        r.raise_for_status()
        return r.json()["id"]

    created = 0
    for i, ring in enumerate(stalls):
        try:
            create_room(i, ring)
            created += 1
        except requests.HTTPError as ex:
            print(f"  loi room #{i+1}: {ex.response.status_code} {ex.response.text}", file=sys.stderr)
    print(f"Da tao {created}/{len(stalls)} room (cho do xe)")


if __name__ == "__main__":
    main()
