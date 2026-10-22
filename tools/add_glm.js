#!/usr/bin/env node
// Add Zhipu GLM (智谱) as a first-class provider template, on top of the v1.0.1
// build that already contains DeepSeek + Xiaomi MiMo (tools/add_providers.js).
// Run from the directory containing app-DRpXG1p6.js:  node add_glm.js
// Server-safe: "glm" maps to "openai-compatible" type on submit, same as
// deepseek/mimo. Official API (docs.bigmodel.cn, GLM-4.7-Flash page):
//   POST https://open.bigmodel.cn/api/paas/v4/chat/completions
//   model "glm-4.7-flash", Bearer auth, text-only input, 200K context.
// BrowserOS appends "/chat/completions" automatically for openai-compatible,
// so defaultBaseUrl is the base only: https://open.bigmodel.cn/api/paas/v4
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

// 1. Category map: glm -> "api-key" section
rep(
  '"openai-compatible":"api-key",deepseek:"api-key",mimo:"api-key",ollama:"local"',
  '"openai-compatible":"api-key",deepseek:"api-key",mimo:"api-key",glm:"api-key",ollama:"local"'
);

// 2. Provider type enum (dropdown + validation)
rep(
  '"deepseek","mimo"])',
  '"deepseek","mimo","glm"])'
);

// 3. Default model lists
rep(
  'K8={"openai-compatible":[],deepseek:[],mimo:[],',
  'K8={"openai-compatible":[],deepseek:[],mimo:[],glm:[],'
);

// 4. Card list: append GLM template after MiMo (text-only, so supportsImages:false)
rep(
  '{id:"mimo",name:"Xiaomi MiMo",defaultBaseUrl:"https://api.xiaomimimo.com/v1",defaultModelId:"mimo-v2.6-flash",supportsImages:true,contextWindow:1000000,iconType:"openai-compatible"}',
  '{id:"mimo",name:"Xiaomi MiMo",defaultBaseUrl:"https://api.xiaomimimo.com/v1",defaultModelId:"mimo-v2.6-flash",supportsImages:true,contextWindow:1000000,iconType:"openai-compatible"},{id:"glm",name:"智谱 GLM",defaultBaseUrl:"https://open.bigmodel.cn/api/paas/v4",defaultModelId:"glm-4.7-flash",supportsImages:false,contextWindow:200000,iconType:"openai-compatible"}'
);

// 5. Dropdown options: append GLM
rep(
  ',y=[...ij(g),{value:"deepseek",label:"DeepSeek"},{value:"mimo",label:"Xiaomi MiMo"}]',
  ',y=[...ij(g),{value:"deepseek",label:"DeepSeek"},{value:"mimo",label:"Xiaomi MiMo"},{value:"glm",label:"智谱 GLM"}]'
);

// 6. Submit: map glm -> server-safe "openai-compatible"
rep(
  '{deepseek:"openai-compatible",mimo:"openai-compatible"}',
  '{deepseek:"openai-compatible",mimo:"openai-compatible",glm:"openai-compatible"}'
);

fs.writeFileSync(FILE, src);
console.log(`applied ${n} edits OK`);

// verify with acorn (module parse, like the browser) when available
try {
  const acorn = require('acorn');
  acorn.parse(fs.readFileSync(FILE, 'utf8'), { ecmaVersion: 'latest', sourceType: 'module' });
  console.log('acorn module parse OK');
} catch (e) {
  console.log('acorn not available or parse failed:', e.message);
}
