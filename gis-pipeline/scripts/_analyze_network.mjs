// Phan tich mang luoi routing_network_clean.geojson: co lien thong khong, va ho bao nhieu met.
// Snap theo lang gieng gan nhat (union-find) — dung dan hon lam tron luoi.
import fs from 'node:fs';

const SRC = 'data/processed/02. THAO DIEN/routing_network_clean.geojson';
const net = JSON.parse(fs.readFileSync(SRC, 'utf8'));

const M_LAT = 111320;
const mPerLng = (lat) => M_LAT * Math.cos((lat * Math.PI) / 180);
const distM = (a, b) =>
  Math.hypot((b[1] - a[1]) * M_LAT, (b[0] - a[0]) * mPerLng((a[1] + b[1]) / 2));

console.log(`features: ${net.features.length}`);

// 1. Thu thap toan bo dinh, kem chi so feature
const verts = [];   // { p, f }
net.features.forEach((f, fi) => {
  const coords = f.geometry.coordinates;
  coords.forEach((c, ci) => verts.push({ p: c, f: fi, ci, end: ci === 0 || ci === coords.length - 1 }));
});
console.log(`tong so dinh (co lap lai): ${verts.length}`);

// So dinh phan biet o cac muc lam tron khac nhau
for (const d of [7, 6, 5, 4]) {
  const set = new Set(verts.map((v) => `${v.p[0].toFixed(d)},${v.p[1].toFixed(d)}`));
  console.log(`  lam tron ${d} chu so -> ${set.size} dinh phan biet`);
}

// 2. Union-Find voi snap theo nguong met
const parent = verts.map((_, i) => i);
const find = (x) => (parent[x] === x ? x : (parent[x] = find(parent[x])));

function build(tolM) {
  for (let i = 0; i < verts.length; i++) parent[i] = i;
  // Luoi khong gian tho de giam so cap phai so sanh
  const cell = Math.max(tolM, 0.5);
  const buckets = new Map();
  const keyOf = (p) => [
    Math.floor((p[0] * mPerLng(p[1])) / cell),
    Math.floor((p[1] * M_LAT) / cell),
  ];
  verts.forEach((v, i) => {
    const [cx, cy] = keyOf(v.p);
    const k = `${cx},${cy}`;
    if (!buckets.has(k)) buckets.set(k, []);
    buckets.get(k).push(i);
  });
  for (let i = 0; i < verts.length; i++) {
    const [cx, cy] = keyOf(verts[i].p);
    for (let dx = -1; dx <= 1; dx++)
      for (let dy = -1; dy <= 1; dy++)
        for (const j of buckets.get(`${cx + dx},${cy + dy}`) || [])
          if (j > i && distM(verts[i].p, verts[j].p) <= tolM) {
            const a = find(i), b = find(j);
            if (a !== b) parent[b] = a;
          }
  }
  // Do thi: moi doan thang noi 2 cum dinh
  const adj = new Map();
  const add = (a, b) => { if (!adj.has(a)) adj.set(a, new Set()); adj.get(a).add(b); };
  net.features.forEach((f, fi) => {
    const ids = f.geometry.coordinates.map((_, ci) => find(verts.findIndex((v) => v.f === fi && v.ci === ci)));
    for (let i = 0; i + 1 < ids.length; i++) {
      if (ids[i] !== ids[i + 1]) { add(ids[i], ids[i + 1]); add(ids[i + 1], ids[i]); }
    }
  });
  const comps = [];
  const seen = new Set();
  for (const n of adj.keys()) {
    if (seen.has(n)) continue;
    const st = [n]; seen.add(n); let size = 0;
    while (st.length) { const x = st.pop(); size++; for (const y of adj.get(x)) if (!seen.has(y)) { seen.add(y); st.push(y); } }
    comps.push(size);
  }
  comps.sort((a, b) => b - a);
  return { nodes: adj.size, comps };
}

console.log('\n== Snap theo nguong met (union-find) ==');
for (const tol of [0.05, 0.1, 0.25, 0.5, 1, 2, 5, 10]) {
  const r = build(tol);
  console.log(`snap ${String(tol).padStart(5)} m -> ${String(r.nodes).padStart(3)} nut | ${r.comps.length} thanh phan: [${r.comps.join(', ')}]`);
}

// 3. Khoang cach nho nhat giua cac thanh phan (o muc snap 0.1 m)
const r = build(0.1);
console.log(`\n== Khoang cach nho nhat giua cac cum (snap 0.1 m) ==`);
console.log(`So thanh phan: ${r.comps.length}`);