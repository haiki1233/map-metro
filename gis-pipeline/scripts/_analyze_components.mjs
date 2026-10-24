// Sau khi planarize mang luoi con 2 thanh phan. Do khoang ho, bbox tung cum
// de biet la ho that (2 khu tach biet) hay chi lech vai met.
import fs from 'node:fs';

const SRC = 'data/processed/02. THAO DIEN/routing_network_clean.geojson';
const net = JSON.parse(fs.readFileSync(SRC, 'utf8'));

const M_LAT = 111320;
let lng0 = 0, lat0 = 0, n = 0;
for (const f of net.features) for (const c of f.geometry.coordinates) { lng0 += c[0]; lat0 += c[1]; n++; }
lng0 /= n; lat0 /= n;
const MLNG = M_LAT * Math.cos((lat0 * Math.PI) / 180);
const toXY = (c) => [(c[0] - lng0) * MLNG, (c[1] - lat0) * M_LAT];

const TOL_SPLIT = 0.5;
const segs = [];
net.features.forEach((f, fi) => {
  const cs = f.geometry.coordinates.map(toXY);
  for (let i = 0; i + 1 < cs.length; i++) segs.push({ f: fi, a: cs[i], b: cs[i + 1] });
});

function projT(p, S) {
  const dx = S.b[0] - S.a[0], dy = S.b[1] - S.a[1];
  const L2 = dx * dx + dy * dy;
  if (L2 < 1e-18) return null;
  let t = ((p[0] - S.a[0]) * dx + (p[1] - S.a[1]) * dy) / L2;
  if (t < -1e-9 || t > 1 + 1e-9) return null;
  t = Math.max(0, Math.min(1, t));
  const d = Math.hypot(p[0] - (S.a[0] + t * dx), p[1] - (S.a[1] + t * dy));
  return d <= TOL_SPLIT ? t : null;
}

const splits = segs.map(() => []);
for (let i = 0; i < segs.length; i++) {
  for (let j = i + 1; j < segs.length; j++) {
    const P = segs[i], Q = segs[j];
    const d1 = [P.b[0] - P.a[0], P.b[1] - P.a[1]];
    const d2 = [Q.b[0] - Q.a[0], Q.b[1] - Q.a[1]];
    const den = d1[0] * d2[1] - d1[1] * d2[0];
    const ex = Q.a[0] - P.a[0], ey = Q.a[1] - P.a[1];
    if (Math.abs(den) > 1e-12) {
      const t = (ex * d2[1] - ey * d2[0]) / den, u = (ex * d1[1] - ey * d1[0]) / den;
      if (t >= -1e-9 && t <= 1 + 1e-9 && u >= -1e-9 && u <= 1 + 1e-9) {
        if (t > 1e-9 && t < 1 - 1e-9) splits[i].push(t);
        if (u > 1e-9 && u < 1 - 1e-9) splits[j].push(u);
      }
    }
    for (const p of [Q.a, Q.b]) { const t = projT(p, P); if (t !== null && t > 1e-9 && t < 1 - 1e-9) splits[i].push(t); }
    for (const p of [P.a, P.b]) { const u = projT(p, Q); if (u !== null && u > 1e-9 && u < 1 - 1e-9) splits[j].push(u); }
  }
}

const raw = [];
segs.forEach((S, i) => {
  const ts = [...new Set(splits[i].map((t) => +t.toFixed(9)))].sort((x, y) => x - y);
  const pts = [0, ...ts, 1].map((t) => [S.a[0] + t * (S.b[0] - S.a[0]), S.a[1] + t * (S.b[1] - S.a[1])]);
  for (let k = 0; k + 1 < pts.length; k++) raw.push({ a: pts[k], b: pts[k + 1] });
});

const TOL = 0.5;
const key = new Map();
const nodes = [];
const idxOf = (p) => {
  const k = `${Math.round(p[0] / TOL)},${Math.round(p[1] / TOL)}`;
  if (!key.has(k)) { key.set(k, nodes.length); nodes.push(p); }
  return key.get(k);
};
const pairs = raw.map((s) => [idxOf(s.a), idxOf(s.b), Math.hypot(s.b[0] - s.a[0], s.b[1] - s.a[1])]);

const parent = nodes.map((_, i) => i);
const find = (x) => { while (parent[x] !== x) { parent[x] = parent[parent[x]]; x = parent[x]; } return x; };
const bucket = new Map();
nodes.forEach((p, i) => {
  const k = `${Math.floor(p[0] / TOL)},${Math.floor(p[1] / TOL)}`;
  if (!bucket.has(k)) bucket.set(k, []);
  bucket.get(k).push(i);
});
for (let i = 0; i < nodes.length; i++) {
  const cx = Math.floor(nodes[i][0] / TOL), cy = Math.floor(nodes[i][1] / TOL);
  for (let dx = -1; dx <= 1; dx++) for (let dy = -1; dy <= 1; dy++)
    for (const j of bucket.get(`${cx + dx},${cy + dy}`) || [])
      if (j > i && Math.hypot(nodes[i][0] - nodes[j][0], nodes[i][1] - nodes[j][1]) <= TOL) {
        const a = find(i), b = find(j); if (a !== b) parent[b] = a;
      }
}

const adj = new Map();
const compLen = new Map();
for (const [a, b, L] of pairs) {
  const ra = find(a), rb = find(b);
  compLen.set(ra, (compLen.get(ra) || 0) + L);
  if (ra === rb) continue;
  if (!adj.has(ra)) adj.set(ra, new Set());
  if (!adj.has(rb)) adj.set(rb, new Set());
  adj.get(ra).add(rb); adj.get(rb).add(ra);
}
const comps = [];
const seen = new Set();
for (const x of adj.keys()) {
  if (seen.has(x)) continue;
  const st = [x]; seen.add(x); const mem = new Set([x]);
  while (st.length) { const y = st.pop(); for (const z of adj.get(y)) if (!seen.has(z)) { seen.add(z); mem.add(z); st.push(z); } }
  comps.push({ root: x, mem: [...mem] });
}
comps.sort((a, b) => b.mem.length - a.mem.length);

console.log(`\nPLANARIZE + gop dinh ${TOL} m: ${nodes.length} dinh, ${pairs.length} canh, ${comps.length} thanh phan\n`);
for (const c of comps) {
  const lngs = c.mem.map((i) => nodes[i][0] / MLNG + lng0);
  const lats = c.mem.map((i) => nodes[i][1] / M_LAT + lat0);
  const len = c.mem.reduce((s, i) => s + (compLen.get(find(i)) || 0) / c.mem.length, 0);
  console.log(`cum root ${c.root}: ${c.mem.length} dinh`);
  console.log(`   bbox lat ${Math.min(...lats).toFixed(6)}..${Math.max(...lats).toFixed(6)}  lng ${Math.min(...lngs).toFixed(6)}..${Math.max(...lngs).toFixed(6)}`);
}
if (comps.length > 1) {
  console.log('\nKhoang ho nho nhat giua cum lon nhat va tung cum con lai:');
  for (let i = 1; i < comps.length; i++) {
    let best = Infinity, bp = null;
    for (const u of comps[0].mem) for (const v of comps[i].mem) {
      const d = Math.hypot(nodes[u][0] - nodes[v][0], nodes[u][1] - nodes[v][1]);
      if (d < best) { best = d; bp = [u, v]; }
    }
    const A = [lng0 + nodes[bp[0]][0] / MLNG, lat0 + nodes[bp[0]][1] / M_LAT];
    const B = [lng0 + nodes[bp[1]][0] / MLNG, lat0 + nodes[bp[1]][1] / M_LAT];
    console.log(`  cum ${comps[i].mem.length} dinh: ho ${best.toFixed(2)} m  [${A[1].toFixed(6)},${A[0].toFixed(6)}] -> [${B[1].toFixed(6)},${B[0].toFixed(6)}]`);
  }
}
const total = [...new Set(pairs.map((p) => find(p[0])))].reduce((s, r) => s + (compLen.get(r) || 0) / 2, 0);
console.log(`\nTong chieu dai mang luoi: ~${total.toFixed(1)} m`);