# class：課程資料彙整站

修課筆記、互動課程手冊與自製教材的彙整站。**每門課一個資料夾**，資料夾內自成一個小網站，彼此不互相依賴。

正式站：https://fdexpert.github.io/class/

## 收錄的課程

### text-as-data — 文本即數據：社會科學研究的計算方法

國立臺灣大學國家發展研究所，115-1（2026 秋季），2 學分，課號 NTLDEV7191。

- 課程頁：https://fdexpert.github.io/class/text-as-data/
- 雙語互動課程手冊：https://fdexpert.github.io/class/text-as-data/text-as-data-course.html
- RStudio 入門課前教材：https://fdexpert.github.io/class/text-as-data/rstudio-intro.html

內容詳見該資料夾。依 2026-09-17 版課綱整理。

## 設計系統：紙與墨

全站共用一套設計語言，定義在 `design/`：

- `design/DESIGN.md` — 設計規範（色彩、字體、版面、元件、主題行為）
- `design/AI-BRIEF.md` — **一頁版指令，要用任何 AI 工具做新頁面時整頁貼給它**
- `design/tokens.css` — 唯一真實來源；站台頁 `<link>` 引用，單檔教材內嵌副本
- `design/tokens.json` — 同一組值的機器可讀版
- `design/theme.js` — 主題切換（三態 system／light／dark，跨頁保持）
- `design/page-template.html` — 新頁面起手式

改完任何頁面請執行 `node tools/check-design.mjs`，它會檢查硬寫色碼、主題腳本、返回連結與內嵌 tokens 是否漂移。

**目前狀態**：全部四個頁面（首頁、課程頁、RStudio 教材、雙語課程手冊）皆已套用，檢查腳本零失敗零提醒。

## 目錄結構

```
class/
├── index.html          課程清單（站台首頁）
├── .nojekyll
├── README.md
├── design/             全站設計系統
├── tools/              檢查腳本
├── text-as-data/       一門課一個資料夾
│   ├── index.html         該課程首頁
│   ├── text-as-data-course.html
│   ├── rstudio-intro.html
│   └── data/              該課程的資料與腳本
└── <next-course>/      下一門課照樣擺
```

根目錄另有兩個轉址檔 `text-as-data-course.html` 與 `rstudio-intro.html`，以及 `data/index.html`，用來讓 2026-09-18 目錄調整前分享出去的舊網址繼續可用。新連結請一律使用 `text-as-data/` 底下的路徑。

## 新增一門課程

1. 建立課程資料夾，名稱用小寫英文與連字號（例如 `research-methods`）。
2. 放入該課程的 `index.html` 與內容檔；課程資料夾內部一律使用相對路徑。
3. 頁面設計一律遵守 `design/AI-BRIEF.md`；用 AI 工具做的話，把那一頁整頁貼給它。
4. 編輯根目錄 `index.html`，複製課程卡片（`<section class="c-card course">` 區塊），改掉標題、連結、學期與說明。
5. 在本 README 的「收錄的課程」新增一節。
6. 執行 `node tools/check-design.mjs` 確認全綠。

課程資料夾彼此獨立，刪掉任何一個都不影響其他課。

## 部署與更新

GitHub Pages 使用 `main` 分支根目錄，`.nojekyll` 表示直接發布靜態檔案。提交到 `main` 後會自動發布。所有 HTML 均已內嵌資料、樣式與程式，不依賴 CDN 或建置流程。

另有一個早期的 Vercel 鏡像 `text-as-data-course.vercel.app`，只有「文本即數據」的課程手冊、未連接本儲存庫，推送不會同步過去；若要更新該鏡像需自行重新上傳單一 HTML 檔。內容一律以 GitHub Pages 為準。

## 權利

各課程之課綱、教材與所引用文獻的權利歸各自權利人所有；本站未另行授予其內容的再授權。課程資料整理 © Jerry。
