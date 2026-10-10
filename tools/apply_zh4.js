#!/usr/bin/env node
// Round 4: quote-aware replacement via acorn AST positions.
// Only replaces complete string literals / template quasis, never bare substrings.
const acorn = require('acorn');
const fs = require('fs');

const FILE = 'app-DRpXG1p6.js';
const src = fs.readFileSync(FILE, 'utf8');
const MAP = JSON.parse(fs.readFileSync('zh_map3.json', 'utf8'));
// Tabs: only the visible label, not Radix internal component names
MAP['Tabs'] = '标签页';

const ast = acorn.parse(src, { ecmaVersion: 'latest', sourceType: 'module' });
const lits = [];
function walk(node) {
  if (!node || typeof node.type !== 'string') return;
  if (node.type === 'Literal' && typeof node.value === 'string') {
    lits.push({ start: node.start, end: node.end, value: node.value, template: false });
  }
  if (node.type === 'TemplateLiteral') {
    for (const q of node.quasis) {
      if (q.value.cooked !== undefined && q.value.cooked.length > 0) {
        lits.push({ start: q.start, end: q.end, value: q.value.cooked, template: true });
      }
    }
  }
  for (const k in node) {
    const v = node[k];
    if (Array.isArray(v)) v.forEach(walk);
    else if (v && typeof v.type === 'string') walk(v);
  }
}
walk(ast);
console.log('literals found:', lits.length);

const reps = [];
let skipped = 0;
for (const l of lits) {
  const nv = MAP[l.value];
  if (nv === undefined) continue;
  if (l.value === 'Tabs') {
    const before = src.slice(Math.max(0, l.start - 14), l.start);
    if (!/children:\s*["']$/.test(before)) { skipped++; continue; }
  }
  reps.push({ ...l, nv });
}
console.log('to replace:', reps.length, '| skipped Tabs:', skipped);

// apply from end to start so positions stay valid
reps.sort((a, b) => b.start - a.start);
let out = src;
for (const r of reps) {
  let rep;
  if (r.template) {
    rep = r.nv.replace(/\\/g, '\\\\').replace(/`/g, '\\`').replace(/\$\{/g, '\\${');
  } else {
    rep = JSON.stringify(r.nv);
  }
  out = out.slice(0, r.start) + rep + out.slice(r.end);
}
fs.writeFileSync(FILE, out);
console.log('done, new size:', out.length);
