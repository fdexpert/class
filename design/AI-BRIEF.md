# 給 AI 工具的一頁指令

> 要為 `class` 站做新頁面時，把這一整頁貼給任何 AI 工具（Claude、ChatGPT、Gemini、v0…）即可。

---

你要為一個課程資料站製作頁面。這個站有既定的設計系統，**不要自己發明配色或版面語言**。

## 設計語言：紙與墨

米紙底、墨綠字、襯線標題。整體像一本印刷品，不像軟體介面。三條硬規則：

1. **不用漸層、不用陰影。** 層次只靠底色深淺與 1px 細線。
2. **圓角很小**（3–8px）。紙是方的。
3. **標題用襯線字體，內文與介面用無襯線，程式碼用等寬。**

## 取得代幣

`design/tokens.css` 是唯一真實來源，`design/tokens.json` 是同一組值的機器可讀版。**先讀其中一個**，再開始寫。

## 必須遵守

- 頁面 CSS **不得出現任何 `#色碼`**，一律用 `var(--變數名)`。需要新顏色時先問人類，不要自己加。
- `--gold`（#b19b62）**只能用於裝飾**：細線、小圖飾。它在米紙上的對比只有 2.49:1，任何承載資訊的金色請用 `--gold-ink`。
- 每頁 `<head>` 要有防閃爍腳本，**且必須在樣式之前**：
  ```html
  <script>(function(){try{var t=localStorage.getItem('class-theme');
  if(t==='light'||t==='dark')document.documentElement.setAttribute('data-theme',t);}catch(e){}})();</script>
  ```
- 主題切換鈕寫成 `<button class="c-theme" data-theme-toggle></button>`，並在頁尾載入 `design/theme.js`。**不要自己寫主題切換邏輯**，那會讓跨頁狀態不一致。
- 非首頁一定要有返回連結：`<a class="c-back" href="../">← 上一層</a>`。
- 直接用現成元件類別：`c-card`、`c-tag`、`c-note`、`c-foot`、`c-rule-gold`。
- 站台頁用 `<link rel="stylesheet" href="../design/tokens.css">`；若成品必須是**單一 HTML 檔**（可離線開啟的教材），改為把 `tokens.css` 全文內嵌在 `<style>` 最前面，並在開頭保留註解 `/* tokens v1 — 由 design/tokens.json 產生，勿手改 */`。

## 起手式

複製 `design/page-template.html`，它已經包含上述全部規定。

## 完成前自檢

- [ ] 頁面 CSS 裡 `#` 色碼數為 0
- [ ] 淺色、深色、跟隨系統三種狀態都看過
- [ ] 手機寬度 390px 無水平捲動
- [ ] 從別頁切成淺色後進到這一頁，仍是淺色
- [ ] 有 `c-back`、有主題鈕、有 `c-foot`
- [ ] 跑過 `node tools/check-design.mjs`

## 語言與語氣

繁體中文，技術名詞保留英文原文（如 corpus、dfm、Overleaf）。敘述為主，清單節制使用。
