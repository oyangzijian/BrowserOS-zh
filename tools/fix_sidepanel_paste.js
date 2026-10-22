#!/usr/bin/env node
// Fix image pasting in the BrowserOS Assistant side panel (v1.1.1).
// Target: chunks/mermaid-HWGCJPDP-ndandfc4.js (the shared chunk that renders
// the side panel ChatInput). The app/settings chunk is NOT involved.
//
// Root cause: upstream 0.0.161.0 side panel has NO paste handling at all -
// the ChatInput textarea only has onChange/onKeyDown. The send pipeline
// itself already supports files (sendMessage({text, files}) -> AI SDK,
// which requires a real FileList), so this patch only bridges paste -> send:
//   1. ChatInput (dxe): add a staged-image count state.
//   2. ChatInput submit: clear the staged preview on submit.
//   3. ChatInput form: show a small orange pill when images are staged
//      (click it to cancel the staged images).
//   4. Textarea onPaste: collect clipboard files into a DataTransfer
//      (so .files is a genuine FileList), stash on window for the sender.
//   5. Panel sendMessage (yu in bPt): if the outgoing message has no files
//      but staged paste files exist, attach them and clear the stash.
// Usage: node fix_sidepanel_paste.js [path-to-mermaid-*.js]
// Prints an error and changes nothing if any pattern does not match
// exactly once (e.g. a different extension version).
const fs = require('fs');
const FILE = process.argv[2] || 'mermaid-HWGCJPDP-ndandfc4.js';
let src = fs.readFileSync(FILE, 'utf8');

if (src.includes('__bosPasteFiles')) {
  console.log('already patched (__bosPasteFiles present), nothing to do');
  process.exit(0);
}

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

// 1. ChatInput: staged-image count state
rep(
  'const p=T.useRef(null),[m,v]=T.useState({isOpen:!1,filterText:"",startPosition:0}),b=T.useRef(e)',
  'const p=T.useRef(null),[m,v]=T.useState({isOpen:!1,filterText:"",startPosition:0}),[pf,psf]=T.useState(0),b=T.useRef(e)'
);

// 2. ChatInput submit: clear staged preview when the form actually submits
rep(
  'M=U=>{if(_.current.isOpen){U.preventDefault(),x();return}if(D){U.preventDefault();return}s(U)}',
  'M=U=>{if(_.current.isOpen){U.preventDefault(),x();return}if(D){U.preventDefault();return}psf(0),s(U)}'
);

// 3. Form children: staged-image pill (click to cancel), inserted before textarea
rep(
  'C.jsx(LIt,{variant:"mention",isOpen:m.isOpen,filterText:m.filterText,selectedTabs:a,onToggleTab:l,onClose:x,anchorRef:p}),C.jsx("textarea",{ref:p,',
  'C.jsx(LIt,{variant:"mention",isOpen:m.isOpen,filterText:m.filterText,selectedTabs:a,onToggleTab:l,onClose:x,anchorRef:p}),pf>0?C.jsx("div",{onClick:()=>{window.__bosPasteFiles=void 0,window.__bosPasteDT=void 0,psf(0)},className:"absolute -top-10 left-0 z-10 cursor-pointer rounded-full bg-[var(--accent-orange)] px-3 py-1.5 text-white text-xs shadow-md",children:`🖼 已粘贴 ${pf} 张图片，输入一句话后发送将一起发出 · 点击取消`}):null,C.jsx("textarea",{ref:p,'
);

// 4. Textarea onPaste: build a real FileList via DataTransfer and stash it
rep(
  'onKeyDown:L,placeholder:n==="chat"?"Ask about this page...":"What should I do?"',
  'onKeyDown:L,onPaste:U=>{try{const dt=new DataTransfer;const ee=U.clipboardData?.items;if(ee)for(const z of ee)if(z.kind==="file"){const re=z.getAsFile();re&&dt.items.add(re)}if(dt.files.length===0&&U.clipboardData?.files?.length)for(const re of U.clipboardData.files)dt.items.add(re);if(dt.files.length>0){U.preventDefault(),window.__bosPasteDT=dt,window.__bosPasteFiles=dt.files,psf(dt.files.length)}}catch{}},placeholder:n==="chat"?"Ask about this page...":"What should I do?"'
);

// 5. Panel sendMessage: attach staged paste files when the message has none
rep(
  'const yu=wt=>{const ft=A9t({isRestoring:Z,',
  'const yu=wt=>{if(!wt.files&&window.__bosPasteFiles?.length){wt={...wt,files:window.__bosPasteFiles},window.__bosPasteFiles=void 0,window.__bosPasteDT=void 0}const ft=A9t({isRestoring:Z,'
);

fs.writeFileSync(FILE, src);
console.log(`applied ${n} edits OK`);

try {
  const acorn = require('acorn');
  acorn.parse(fs.readFileSync(FILE, 'utf8'), { ecmaVersion: 'latest', sourceType: 'module' });
  console.log('acorn module parse OK');
} catch (e) {
  if (e.code === 'MODULE_NOT_FOUND') {
    console.log('（跳过语法复检：acorn 未安装；补丁已按精确匹配完成）');
  } else {
    console.log('acorn parse failed:', e.message);
  }
}
