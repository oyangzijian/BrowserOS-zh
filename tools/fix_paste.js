#!/usr/bin/env node
// Fix image pasting in the chat input (component V6 in app-DRpXG1p6.js).
// Run from the directory containing app-DRpXG1p6.js:  node fix_paste.js
//
// What was wrong:
// 1) The paste handler only read clipboardData.items with kind==="file".
//    Some macOS apps put the image only in clipboardData.files, so pasting
//    silently did nothing. Fix: fall back to clipboardData.files.
// 2) On the new-tab home input, attachments were gated to ACP agents only
//    (attachmentsEnabled: c?.kind==="acp"), so pasting/attaching an image
//    with a normal LLM provider always errored "该智能体暂不支持附件。".
//    The send flow for inline-chat already carries attachments via handoff
//    to /home/chat, so enable attachments there too. The sidepanel mode is
//    intentionally left gated: that flow sends text only and would silently
//    drop the image.
const fs = require('fs');
const FILE = 'app-DRpXG1p6.js';
let src = fs.readFileSync(FILE, 'utf8');
let n = 0;
function rep(old, nw) {
  const c = src.split(old).length - 1;
  if (c !== 1) {
    console.error(`PATTERN x${c} (expected 1): ${old.slice(0, 80)}`);
    process.exit(1);
  }
  src = src.split(old).join(nw);
  n++;
}

// 1. Paste handler: add clipboardData.files fallback
rep(
  'J=U=>{const ee=U.clipboardData?.items;if(!ee)return;const Y=[];for(const z of ee)if(z.kind==="file"){const re=z.getAsFile();re&&Y.push(re)}Y.length>0&&(U.preventDefault(),j(Y))}',
  'J=U=>{const ee=U.clipboardData?.items;const Y=[];if(ee)for(const z of ee)if(z.kind==="file"){const re=z.getAsFile();re&&Y.push(re)}if(Y.length===0&&U.clipboardData?.files?.length)for(const re of U.clipboardData.files)Y.push(re);Y.length>0&&(U.preventDefault(),j(Y))}'
);

// 2. Home input: allow attachments for inline-chat (not just ACP agents)
rep(
  'attachmentsEnabled:c?.kind==="acp"',
  'attachmentsEnabled:c?.kind==="acp"||o==="inline-chat"'
);

fs.writeFileSync(FILE, src);
console.log(`applied ${n} edits OK`);

try {
  const acorn = require('acorn');
  acorn.parse(fs.readFileSync(FILE, 'utf8'), { ecmaVersion: 'latest', sourceType: 'module' });
  console.log('acorn module parse OK');
} catch (e) {
  console.log('acorn not available or parse failed:', e.message);
}
