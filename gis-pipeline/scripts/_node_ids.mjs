// Throwaway: map node id (geojson feature order = seeded node id) -> CAD Text code.
import { readFileSync } from 'node:fs';

const g = JSON.parse(readFileSync(process.argv[2], 'utf8'));
g.features.forEach((f, i) => {
  const c = f.geometry.coordinates;
  console.log(`${i + 1}\t${String(f.properties.Text)}\t${c[0].toFixed(7)},${c[1].toFixed(7)}`);
});