#!/usr/bin/env node
/* 紙與墨 — 設計一致性檢查
   用法：node tools/check-design.mjs        （從 repo 根目錄執行）
   檢查：色碼偷渡、主題腳本、返回連結、內嵌 tokens 是否與來源漂移 */
import { readFileSync, readdirSync, statSync } from 'fs';
import { join, relative, basename } from 'path';

const ROOT = process.cwd();
const TOKENS = join(ROOT, 'design/tokens.css');
let fails = 0, warns = 0;
const bad = m => { console.log('  ✗ ' + m); fails++; };
const warn = m => { console.log('  ! ' + m); warns++; };
const ok = m => console.log('  ✓ ' + m);

const tokensCss = readFileSync(TOKENS, 'utf8');
const tokenNames = [...tokensCss.matchAll(/--([a-z0-9-]+)\s*:/gi)].map(m => m[1]);
const fingerprint = (tokensCss.match(/--bg:#[0-9a-f]{6}/i) || [''])[0]
  + (tokensCss.match(/--gold:#[0-9a-f]{6}/i) || [''])[0];

function walk(dir, out = []) {
  for (const f of readdirSync(dir)) {
    if (f === '.git' || f === 'node_modules' || f === 'design' || f === 'tools') continue;
    const p = join(dir, f);
    if (statSync(p).isDirectory()) walk(p, out);
    else if (f.endsWith('.html')) out.push(p);
  }
  return out;
}

const pages = walk(ROOT);
console.log(`紙與模 — 設計檢查｜${pages.length} 個頁面\n`.replace('模','墨'));

for (const p of pages) {
  const rel = relative(ROOT, p);
  const s = readFileSync(p, 'utf8');
  const isStub = s.length < 2000 && /http-equiv="refresh"/.test(s);
  console.log(`── ${rel}${isStub ? '（轉址檔，略過）' : ''}`);
  if (isStub) { ok('轉址檔'); continue; }

  // 1) 防閃爍腳本
  /class-theme/.test(s) && /documentElement\.setAttribute\('data-theme'/.test(s)
    ? ok('主題防閃爍腳本')
    : bad('缺少 class-theme 防閃爍腳本');

  // 2) 主題鈕
  /data-theme-toggle/.test(s) ? ok('主題切換鈕') : bad('缺少 data-theme-toggle 按鈕');

  // 3) 返回連結（根首頁除外）
  const isRoot = rel === 'index.html';
  if (!isRoot) (/class="c-back"/.test(s) ? ok('返回連結') : bad('缺少 c-back 返回連結'));

  // 4) 取得 tokens 的方式
  const linked = /href="[^"]*design\/tokens\.css"/.test(s);
  const embedded = /tokens v1/.test(s);
  if (linked) ok('外連 tokens.css');
  else if (embedded) {
    fingerprint && s.includes(fingerprint.split('--gold')[0])
      ? ok('內嵌 tokens（與來源一致）')
      : bad('內嵌 tokens 與 design/tokens.css 已漂移，請重新產生');
  } else bad('既沒有外連也沒有內嵌 tokens');

  // 5) 頁面 CSS 裡的硬色碼（排除 tokens 內嵌區與 SVG data URI）
  const styles = [...s.matchAll(/<style>([\s\S]*?)<\/style>/g)].map(m => m[1]).join('\n');
  const own = embedded ? styles.split('/* ====').slice(-1)[0] : styles;
  const hexes = [...own.matchAll(/#[0-9a-fA-F]{3,8}\b/g)].map(m => m[0])
    .filter(h => !/^#(ch|s\d)/.test(h));
  hexes.length === 0 ? ok('無硬寫色碼')
    : warn(`頁面 CSS 出現 ${hexes.length} 個硬寫色碼：${[...new Set(hexes)].slice(0,6).join(' ')}`);

  // 6) 使用到但不存在的變數
  const used = [...s.matchAll(/var\(--([a-z0-9-]+)/gi)].map(m => m[1]);
  const unknown = [...new Set(used)].filter(v => !tokenNames.includes(v));
  unknown.length === 0 ? ok('變數全部有定義')
    : warn(`用到未定義的變數：${unknown.slice(0,8).join(', ')}`);
}

console.log(`\n${fails ? '✗' : '✓'} 失敗 ${fails}｜提醒 ${warns}`);
if (fails) console.log('（尚未套用設計系統的頁面會列為失敗，這就是待辦清單。）');
process.exit(fails ? 1 : 0);
