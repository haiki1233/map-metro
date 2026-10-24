// Kiem chung gia thuyet: mang luoi roi rac vi cac duong CAT NHAU nhung chua duoc "node"
// (chua tach doan tai giao diem / diem cham chu T). Neu dung thi chi can planarize.
import fs from 'node:fs';

const SRC = 'data/processed/02. THAO DIEN/routing_network_clean.geojson';
const net = JSON.parse(fs.readFileSync(SRC, 'utf8'));

const M_LAT = 111320;
let lng0 = 0, lat0 = 0, n = 0;
for (const f of net.features) for (const c of f.geometry.coordinates) { lng0 += c[0]; lat0 += c[1]; n++; }
lng0 /= n; lat0 /= n;
const MLNG = M_LAT * Math.cos((lat0 * Math.PI) / 180);
const toXY = (c) => [(c[0] - lng0) * MLNG, (c[1] - lat0) * M_LAT];

const segs = [];
net.features.forEach((f, fi) => {
  const cs = f.geometry.coordinates.map(toXY);
  for (let i = 0; i + 1 < cs.length; i++) segs.push({ f: fi, a: cs[i], b: cs[i + 1] });
});
console.log(`features ${net.features.length}, doan thang ${segs.length}`);

const TOL = 0.5; // m — dung sai khi coi 1 diem nam TREN 1 doan

function projT(p, S) {
  const dx = S.b[0] - S.a[0], dy = S.b[1] - S.a[1];
  const L2 = dx * dx + dy * dy;
  if (L2 < 1e-18) return null;
  let t = ((p[0] - S.a[0]) * dx + (p[1] - S.a[1]) * dy) / L2;
  if (t < -1e-9 || t > 1 + 1e-9) return null;
  t = Math.max(0, Math.min(1, t));
  const d = Math.hypot(p[0] - (S.a[0] + t * dx), p[1] - (S.a[1] + t * dy));
  return d <= TOL ? t : null;
}

const splits = segs.map(() => []);
const addSplit = (i, t) => { if (t > 1e-9 && t < 1 - 1e-9) splits[i].push(t); };

let crossings = 0, touchings = 0;
for (let i = 0; i < segs.length; i++) {
  for (let j = i + 1; j < segs.length; j++) {
    const P = segs[i], Q = segs[j];
    const d1 = [P.b[0] - P.a[0], P.b[1] - P.a[1]];
    const d2 = [Q.b[0] - Q.a[0], Q.b[1] - Q.a[1]];
    const den = d1[0] * d2[1] - d1[1] * d2[0];
    const ex = Q.a[0] - P.a[0], ey = Q.a[1] - P.a[1];
    if (Math.abs(den) > 1e-12) {
      const t = (ex * d2[1] - ey * d2[0]) / den;
      const u = (ex * d1[1] - ey * d1[0]) / den;
      if (t >= -1e-9 && t <= 1 + 1e-9 && u >= -1e-9 && u <= 1 + 1e-9) {
        addSplit(i, t); addSplit(j, u); crossings++;
      }
    }
    for (const p of [Q.a, Q.b]) {
      const t = projT(p, P);
      if (t !== null && t > 1e-9 && t < 1 - 1e-9) { addSplit(i, t); touchings++; }
    }
    for (const p of [P.a, P.b]) {
      const u = projT(p, Q);
      if (u !== null && u > 1e-9 && u < 1 - 1e-9) { addSplit(j, u); touchings++; }
    }
  }
}
console.log(`giao cat: ${crossings}, diem cham chu T: ${touchings}`);

const raw = [];
segs.forEach((S, i) => {
  const ts = [...new Set(splits[i].map((t) => +t.toFixed(9)))].sort((x, y) => x - y);
  const pts = [0, ...ts, 1].map((t) => [S.a[0] + t * (S.b[0] - S.a[0]), S.a[1] + t * (S.b[1] - S.a[1])]);
  for (let k = 0; k + 1 < pts.length; k++) raw.push([pts[k], pts[k + 1]]);
});
console.log(`sau khi tach: ${raw.length} doan`);

const nodes = [];
const key = new Map();
const idxOf = (p) => {
  const k = `${p[0].toFixed(3)},${p[1].toFixed(3)}`;
  if (!key.has(k)) { key.set(k, nodes.length); nodes.push(p); }
  return key.get(k);
};
const edges = raw.map(([p, q]) => [idxOf(p), idxOf(q)]);

const parent = nodes.map((_, i) => i);
const find = (x) => { while (parent[x] !== x) { parent[x] = parent[parent[x]]; x = parent[x]; } return x; };

const cell = TOL;
const buckets = new Map();
nodes.forEach((p, i) => {
  const k = `${Math.floor(p[0] / cell)},${Math.floor(p[1] / cell)}`;
  if (!buckets.has(k)) buckets.set(k, []);
  buckets.get(k).push(i);
});
for (let i = 0; i < nodes.length; i++) {
  const cx = Math.floor(nodes[i][0] / cell), cy = Math.floor(nodes[i][1] / cell);
  for (let dx = -1; dx <= 1; dx++) for (let dy = -1; dy <= 1; dy++) {
    for (const j of buckets.get(`${cx + dx},${cy + dy}`) || []) {
      if (j > i && Math.hypot(nodes[i][0] - nodes[j][0], nodes[i][1] - nodes[j][1]) <= TOL) {
        const a = find(i), b = find(j);
        if (a !== b) parent[b] = a;
      }
    }
  }
}

const adj = new Map();
const add = (a, b) => { if (!adj.has(a)) adj.set(a, new Set()); adj.get(a).add(b); };
for (const [a, b] of edges) {
  const ra = find(a), rb = find(b);
  if (ra !== rb) { add(ra, rb); add(rb, ra); }
}
const comps = [];
const seen = new Set();
for (const x of adj.keys()) {
  if (seen.has(x)) continue;
  const st = [x]; seen.add(x); let s = 0;
  while (st.length) { const y = st.pop(); s++; for (const z of adj.get(y)) if (!seen.has(z)) { seen.add(z); st.push(z); } }
  comps.push(s);
}
comps.sort((a, b) => b - a);
console.log(`\nSAU KHI PLANARIZE: ${adj.size} nut | ${comps.length} thanh phan: [${comps.join(', ')}]`);

console.log('\nDo dai mang luoi theo thanh phan (m):');
const compLen = new Map();
for (const [a, b] of edges) {
  const ra = find(a);
  const L = Math.hypot(nodes[a][0] - nodes[b][0], nodes[a][1] - nodes[b][1]);
  compLen.set(ra, (compLen.get(ra) || 0) + L);
}
[...compLen.entries()].sort((x, y) => y[1] - x[1]).forEach(([r, L]) => console.log(`  cum ${String(r).padStart(3)}: ${L.toFixed(1)} m`));