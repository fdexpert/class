suppressPackageStartupMessages({
  library(readr);library(dplyr);library(stringr);library(purrr)
  library(quanteda);library(quanteda.textstats);library(jiebaR);library(ggplot2)
})
sep <- function(x) cat("\n##### ", x, " #####\n", sep="")
d <- read_csv("../data/立法院質詢_第11屆.csv", show_col_types = FALSE) |>
  mutate(說明清理 = str_replace_all(說明, "(?<=\\p{Han})\\s+(?=\\p{Han})", ""))

sep("ch11 corpus 基本")
co <- corpus(d, text_field = "說明清理", docid_field = "質詢編號")
cat("ndoc:", ndoc(co), " docvars:", paste(names(docvars(co)), collapse=", "), "\n")
print(summary(co, n = 4)[, 1:4])
cat("\n單篇取用：\n"); cat(str_sub(as.character(co)[1], 1, 45), "...\n")

sep("ch12 英文斷詞")
ten <- tokens("Text as data: a method for social science!")
print(ten)
print(tokens(ten, remove_punct = TRUE))

sep("ch12 quanteda 內建斷詞器處理中文")
test <- c("能源政策與經濟發展的平衡",
          "行政院環境保護署與國家發展委員會",
          "本院羅委員智強就文化成年禮金政策提出質詢",
          "加熱菸產品通通被海關沒收")
for (s in test) cat("ICU  :", paste(as.character(tokens(s))[[1]] %||% unlist(tokens(s)), collapse="/"), "\n")

sep("ch12 jieba 斷同樣四句")
w <- worker()
for (s in test) cat("jieba:", paste(segment(s, w), collapse="/"), "\n")

sep("ch12 自訂詞典")
cat("加詞前:", paste(segment("文化成年禮金政策", w), collapse="/"), "\n")
new_user_word(w, c("文化成年禮金", "加熱菸", "國健署"))
cat("加詞後:", paste(segment("文化成年禮金政策", w), collapse="/"), "\n")
cat("加熱菸:", paste(segment("加熱菸產品通通被海關沒收", w), collapse="/"), "\n")

sep("ch12 全語料斷詞")
seg <- map_chr(d$說明清理, \(s) paste(segment(s, w), collapse = " "))
co2 <- corpus(seg, docvars = d |> select(委員, 會期, 會次))
tk <- tokens(co2, remove_punct = TRUE, remove_numbers = TRUE)
cat("ntoken 前五篇:", paste(head(ntoken(tk), 5), collapse=", "), "\n")
cat("總詞數:", sum(ntoken(tk)), " 不重複詞型:", length(unique(unlist(as.list(tk)))), "\n")

sep("ch13 dfm 未去停用詞")
dm0 <- dfm(tk)
cat("dim:", paste(dim(dm0), collapse=" x "), " sparsity:", round(sparsity(dm0), 4), "\n")
print(topfeatures(dm0, 12))

sep("ch13 去停用詞 + trim")
stop_zh <- c("的","是","與","及","在","為","對","於","並","以","有","也","等","將","其","之","而","了","要","從","或",
             "我國","本院","委員","質詢","行政院","特向","提出","鑑於","就","應","不","及其","請","可","該","此","已","但",
             "一","二","三","中","上","後","更","至","者","因","年","月","日","無","由","被","所","都","如","個","與否")
dm <- dfm_remove(dm0, stop_zh, valuetype = "fixed") |> dfm_trim(min_termfreq = 5)
cat("dim:", paste(dim(dm), collapse=" x "), " sparsity:", round(sparsity(dm), 4), "\n")
print(topfeatures(dm, 15))

sep("ch13 tf-idf")
print(topfeatures(dfm_tfidf(dm), 8))

sep("ch14 textstat_frequency")
f <- textstat_frequency(dm, n = 10)
print(f)

sep("ch14 keyness 會期3 vs 會期1")
dmg <- dfm_subset(dm, 會期 %in% c(1, 3))
k <- textstat_keyness(dmg, target = docvars(dmg, "會期") == 3)
print(head(k, 6))

sep("ch14 畫圖")
p <- ggplot(f, aes(x = reorder(feature, frequency), y = frequency)) +
  geom_col(fill = "#3794ff") + coord_flip() +
  labs(title = "立法院第11屆書面質詢：前十高頻詞",
       subtitle = "162 筆，jieba 斷詞後去停用詞", x = NULL, y = "出現次數") +
  theme_minimal(base_family = "PingFang TC", base_size = 13)
ggsave("../data/top10.png", p, width = 7, height = 4.4, dpi = 130)
cat("圖已存，大小:", file.size("../data/top10.png"), "bytes\n")
