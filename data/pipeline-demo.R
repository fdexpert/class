# 課程貫穿範例：立法院書面質詢 → 清理 → 斷詞 → dfm → 描述統計
suppressPackageStartupMessages({
  library(readr); library(dplyr); library(quanteda)
  library(jiebaR); library(quanteda.textstats)
})

d <- read_csv("立法院質詢_第11屆.csv", show_col_types = FALSE)

# 原始 PDF 排版在漢字間留下空白（「被 沒 收」），先清掉
d$說明 <- gsub("(?<=[\\p{Han}])\\s+(?=[\\p{Han}])", "", d$說明, perl = TRUE)
cat("筆數:", nrow(d), " 清理後說明平均字數:", round(mean(nchar(d$說明))), "\n")

w <- worker()
seg <- vapply(d$說明, function(s) paste(segment(s, w), collapse = " "), character(1), USE.NAMES = FALSE)

co <- corpus(seg, docvars = data.frame(委員 = d$委員, 會期 = d$會期))
stop_zh <- c("的","是","與","及","在","為","對","於","並","以","有","也","等","將","其","之","而","了","要","從","或",
             "我國","本院","委員","質詢","行政院","特向","提出","鑑於","就","應","不","及其","請","可","該","此","已","但","並且")
dfmat <- dfm(tokens(co, remove_punct = TRUE)) |>
  dfm_remove(stop_zh, valuetype = "fixed") |>
  dfm_trim(min_termfreq = 5)

cat("dfm 維度:", paste(dim(dfmat), collapse = " x "), "\n\n")
print(topfeatures(dfmat, 20))
cat("\n--- textstat_frequency 前 5 ---\n")
print(head(textstat_frequency(dfmat), 5))
