// Throwaway: extract TEXT/MTEXT entities (value + insertion point) from a DXF.
// Minimal group-code pair parser: DXF is a flat stream of (code, value) lines.
import { readFileSync } from 'node:fs';

const src = process.argv[2];
const raw = readFileSync(src, 'latin1').split(/\r?\n/).map((s) => s.trim());

const pairs = [];
for (let i = 0; i + 1 < raw.length; i += 2) pairs.push([raw[i], raw[i + 1]]);

const entities = [];
let cur = null;
for (const [code, val] of pairs) {
  if (code === '0') {
    if (cur && (cur.type === 'TEXT' || cur.type === 'MTEXT')) entities.push(cur);
    cur = { type: val, text: null, layer: null, x: null, y: null, h: null };
    continue;
  }
  if (!cur) continue;
  if (code === '8') cur.layer = val;
  if (code === '1') cur.text = cur.text ? `${cur.text} ${val}` : val;
  if (code === '10' && cur.x === null) cur.x = parseFloat(val);
  if (code === '20' && cur.y === null) cur.y = parseFloat(val);
  if (code === '40') cur.h = parseFloat(val);
}
if (cur && (cur.type === 'TEXT' || cur.type === 'MTEXT')) entities.push(cur);

const clean = entities
  .map((e) => ({ ...e, text: (e.text ?? '').replace(/\\[A-Za-z][^;]*;/g, '').replace(/[{}]/g, '').trim() }))
  .filter((e) => e.text);

console.log('TEXT/MTEXT entities with content:', clean.length);
for (const e of clean) {
  console.log(`${e.type}\t${e.layer}\t(${e.x},${e.y})\t${JSON.stringify(e.text)}`);
}