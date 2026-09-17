# 抓取立法院書面質詢作為課程練習語料
# 資料來源：立法院開放資料 API v2  https://ly.govapi.tw/v2/interpellations
# 說明：legisTaiwan 套件 0.2.x 的 get_ly_interpellations() 目前回 404（端點已變動），
#       因此本腳本直接呼叫 API v2。查證日 2026-09-17。
library(httr2); library(jsonlite); library(dplyr); library(purrr); library(readr)

fetch_page <- function(page, limit = 100, term = 11) {
  req <- request("https://ly.govapi.tw/v2/interpellations") |>
    req_url_query(page = page, limit = limit, `屆` = term) |>
    req_user_agent("NTU text-as-data course material (teaching use)") |>
    req_throttle(capacity = 30, fill_time_s = 60)
  resp <- req_perform(req)
  resp_body_json(resp, simplifyVector = FALSE)$interpellations
}

pages <- map(1:3, fetch_page)
rows <- flatten(pages)
cat("抓到", length(rows), "筆\n")

df <- tibble(
  質詢編號 = map_chr(rows, ~ .x[["質詢編號"]] %||% NA_character_),
  屆       = map_int(rows, ~ as.integer(.x[["屆"]] %||% NA)),
  會期     = map_int(rows, ~ as.integer(.x[["會期"]] %||% NA)),
  會次     = map_int(rows, ~ as.integer(.x[["會次"]] %||% NA)),
  委員     = map_chr(rows, ~ paste(unlist(.x[["質詢委員"]]), collapse = "、")),
  刊登日期 = map_chr(rows, ~ .x[["刊登日期"]] %||% NA_character_),
  事由     = map_chr(rows, ~ .x[["事由"]] %||% NA_character_),
  說明     = map_chr(rows, ~ .x[["說明"]] %||% NA_character_)
) |>
  mutate(across(c(事由, 說明), ~ gsub("[\r\n]+", " ", .x) |> trimws())) |>
  filter(!is.na(事由), nchar(說明) > 50)

write_excel_csv(df, "立法院質詢_第11屆.csv")
cat("已寫出", nrow(df), "筆 →", getwd(), "/立法院質詢_第11屆.csv\n")
cat("欄位：", paste(names(df), collapse = ", "), "\n")
