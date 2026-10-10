#!/usr/bin/env node
// Add DeepSeek + Xiaomi MiMo as first-class provider templates (v2: inline only, no const decl).
// Server-safe: both map to "openai-compatible" type on submit.
const fs = require('fs');
const FILE = 'app-DRpXG1p6.js';
let src = fs.readFileSync(FILE, 'utf8');
let n = 0;
function rep(old, nw) {
  const c = src.split(old).length - 1;
  if (c !== 1) {
    console.error(`PATTERN x${c} (expected 1): ${old.slice(0, 70)}`);
    process.exit(1);
  }
  src = src.split(old).join(nw);
  n++;
}

// 1. X6 category map: new types -> "api-key" section
rep(
  '"openai-compatible":"api-key",ollama:"local"',
  '"openai-compatible":"api-key",deepseek:"api-key",mimo:"api-key",ollama:"local"'
);

// 2. n1 provider type enum (dropdown + validation)
rep(
  'n1=Dg(["moonshot","anthropic","openai","openai-compatible","google","openrouter","azure","ollama","lmstudio","bedrock","chatgpt-pro","github-copilot","qwen-code"])',
  'n1=Dg(["moonshot","anthropic","openai","openai-compatible","google","openrouter","azure","ollama","lmstudio","bedrock","chatgpt-pro","github-copilot","qwen-code","deepseek","mimo"])'
);

// 3. K8 default model lists
rep(
  'K8={"openai-compatible":[],',
  'K8={"openai-compatible":[],deepseek:[],mimo:[],'
);

// 4. Card list: inline custom templates (no const declaration)
rep(
  'c=fE.filter(',
  'c=[...fE,{id:"deepseek",name:"DeepSeek",defaultBaseUrl:"https://api.deepseek.com",defaultModelId:"deepseek-chat",supportsImages:false,contextWindow:64000,iconType:"openai-compatible"},{id:"mimo",name:"Xiaomi MiMo",defaultBaseUrl:"https://api.xiaomimimo.com/v1",defaultModelId:"mimo-v2.5-pro",supportsImages:true,contextWindow:1000000,iconType:"openai-compatible"}].filter('
);

// 5. Card icon: allow per-template iconType override
rep(
  'icon:a.jsx($i,{type:f.id,size:26})',
  'icon:a.jsx($i,{type:f.iconType||f.id,size:26})'
);

// 6. Dropdown options: append new providers
rep(
  ',y=ij(g)',
  ',y=[...ij(g),{value:"deepseek",label:"DeepSeek"},{value:"mimo",label:"Xiaomi MiMo"}]'
);

// 7. Submit: inline type map to server-safe "openai-compatible"
rep(
  'At=r1(K)',
  'At=((T=r1(K)),{...T,type:{deepseek:"openai-compatible",mimo:"openai-compatible"}[T.type]||T.type})'
);

fs.writeFileSync(FILE, src);
console.log(`applied ${n} edits OK`);

// verify with acorn (module parse, like the browser)
const acorn = require('acorn');
const out = fs.readFileSync(FILE, 'utf8');
acorn.parse(out, { ecmaVersion: 'latest', sourceType: 'module' });
console.log('acorn module parse OK');
