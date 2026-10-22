#!/usr/bin/env node
// Fix image pasting in the BrowserOS Assistant side panel (v2, 2026-10-22).
// Target: chunks/mermaid-HWGCJPDP-ndandfc4.js (the shared chunk that renders
// the side panel ChatInput). The app/settings chunk is NOT involved.
//
// Root cause: upstream 0.0.161.0 side panel has NO paste handling at all -
// the ChatInput textarea only has onChange/onKeyDown. The send pipeline
// itself already supports files (sendMessage({text, files}) -> AI SDK,
// which requires a real FileList), so this patch only bridges paste -> send:
//   1. ChatInput (dxe): add a staged-image count state.
//   2. ChatInput submit: clear the staged preview on submit.
//   3. ChatInput form: switch to a column layout so the staged-image pill
//      takes its own row ABOVE the textarea and can never cover it.
//      (v1 used an absolutely-positioned pill with a `-top-10` Tailwind
//      class that does not exist in the compiled CSS, so the pill landed
//      on top of the textarea. v2 uses flex-col + inline styles only.)
//   4. Form children: staged-image pill (own row, click to cancel).
//   5. Textarea: flex-1 -> w-full (correct sizing inside the column form).
//   6. Textarea onPaste: collect clipboard files into a DataTransfer
//      (so .files is a genuine FileList), stash on window for the sender.
//   7. Panel sendMessage (yu in bPt): if the outgoing message has no files
//      but staged paste files exist, attach them and clear the stash.
// If the target already has the v1 patch, only steps 3-5 are applied as an
// upgrade. Usage: node fix_sidepanel_paste.js [path-to-mermaid-*.js]
const fs = require('fs');
const FILE = process.argv[2] || 'mermaid-HWGCJPDP-ndandfc4.js';
let src = fs.readFileSync(FILE, 'utf8');

const PILL_V1 = 'pf>0?C.jsx("div",{onClick:()=>{window.__bosPasteFiles=void 0,window.__bosPasteDT=void 0,psf(0)},className:"absolute -top-10 left-0 z-10 cursor-pointer rounded-full bg-[var(--accent-orange)] px-3 py-1.5 text-white text-xs shadow-md",children:`🖼 已粘贴 ${pf} 张图片，输入一句话后发送将一起发出 · 点击取消`}):null';
const PILL_V2 = 'pf>0?C.jsx("div",{onClick:()=>{window.__bosPasteFiles=void 0,window.__bosPasteDT=void 0,psf(0)},style:{alignSelf:"flex-start",backgroundColor:"var(--accent-orange)",color:"#fff",borderRadius:999,padding:"4px 10px",fontSize:12,cursor:"pointer",boxShadow:"0 1px 4px rgba(0,0,0,.35)"},children:`🖼 已粘贴 ${pf} 张图片，输入一句话后发送将一起发出 · 点击取消`}):null';
const FORM_OLD = 'onSubmit:M,className:"relative mt-2 flex w-full items-end gap-2"';
const FORM_NEW = 'onSubmit:M,className:"relative mt-2 flex w-full flex-col items-stretch gap-2"';
const TA_OLD = 'max-h-60 min-h-[42px] flex-1 resize-none';
const TA_NEW = 'max-h-60 min-h-[42px] w-full resize-none';

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

if (src.includes('alignSelf:"flex-start",backgroundColor:"var(--accent-orange)"')) {
  console.log('already patched (v2), nothing to do');
  process.exit(0);
}

if (src.includes('__bosPasteFiles')) {
  // Upgrade v1 -> v2: only the pill presentation and form layout change.
  rep(PILL_V1, PILL_V2);
  rep(FORM_OLD, FORM_NEW);
  rep(TA_OLD, TA_NEW);
} else {
  // Fresh install on an unpatched file.
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
  // 3. Form layout: column, so the pill gets its own row above the textarea
  rep(FORM_OLD, FORM_NEW);
  // 4. Form children: staged-image pill, inserted before the textarea
  rep(
    'C.jsx(LIt,{variant:"mention",isOpen:m.isOpen,filterText:m.filterText,selectedTabs:a,onToggleTab:l,onClose:x,anchorRef:p}),C.jsx("textarea",{ref:p,',
    'C.jsx(LIt,{variant:"mention",isOpen:m.isOpen,filterText:m.filterText,selectedTabs:a,onToggleTab:l,onClose:x,anchorRef:p}),' + PILL_V2 + ',C.jsx("textarea",{ref:p,'
  );
  // 5. Textarea sizing inside the column form
  rep(TA_OLD, TA_NEW);
  // 6. Textarea onPaste: build a real FileList via DataTransfer and stash it
  rep(
    'onKeyDown:L,placeholder:n==="chat"?"Ask about this page...":"What should I do?"',
    'onKeyDown:L,onPaste:U=>{try{const dt=new DataTransfer;const ee=U.clipboardData?.items;if(ee)for(const z of ee)if(z.kind==="file"){const re=z.getAsFile();re&&dt.items.add(re)}if(dt.files.length===0&&U.clipboardData?.files?.length)for(const re of U.clipboardData.files)dt.items.add(re);if(dt.files.length>0){U.preventDefault(),window.__bosPasteDT=dt,window.__bosPasteFiles=dt.files,psf(dt.files.length)}}catch{}},placeholder:n==="chat"?"Ask about this page...":"What should I do?"'
  );
  // 7. Panel sendMessage: attach staged paste files when the message has none
  rep(
    'const yu=wt=>{const ft=A9t({isRestoring:Z,',
    'const yu=wt=>{if(!wt.files&&window.__bosPasteFiles?.length){wt={...wt,files:window.__bosPasteFiles},window.__bosPasteFiles=void 0,window.__bosPasteDT=void 0}const ft=A9t({isRestoring:Z,'
  );
}

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
