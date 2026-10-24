// Throwaway: dump CAD node labels so room names can be seeded from real data.
import { readFileSync } from 'node:fs';

const src = process.argv[2];
const gj = JSON.parse(readFileSync(src, 'utf8'));
const rows = gj.features.map((f, i) => {
  const p = f.properties ?? {};
  const c = f.geometry?.coordinates;
  return { i, text: p.Text ?? p.text ?? null, layer: p.Layer, coords: c };
});
console.log(JSON.stringify(rows, null, 1));
const counts = {};
for (const r of rows) counts[r.text] = (counts[r.text] ?? 0) + 1;
console.log('total features:', rows.length);
console.log('distinct Text:', JSON.stringify(counts, null, 1));