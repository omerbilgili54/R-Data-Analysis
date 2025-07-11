# PDF Metin Analizi ve Duygu Çıkarımı Projesi
# Temizlenmiş, sadeleştirilmiş ve açıklamalı versiyondur

#--------------------------
# 1. Gerekli Paketler
#--------------------------
required_packages <- c(
  "pdftools", "tm", "stringr", "wordcloud", "wordcloud2", "RColorBrewer", 
  "ggplot2", "syuzhet", "tidytext", "dplyr", "tidyr"
)
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
lapply(required_packages, library, character.only = TRUE)

#--------------------------
# 2. PDF'den Metin Okuma
#--------------------------
pdf_path <- "makale.pdf" # Kendi dosya yolunuzu girin
pdf_text <- pdf_text(pdf_path)
cat(pdf_text[1]) # İlk sayfayı görüntüle

#--------------------------
# 3. Metni Birleştirme ve Temizleme
#--------------------------
text <- paste(pdf_text, collapse = " ")

corpus <- VCorpus(VectorSource(text))
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeWords, stopwords("en"))

clean_text <- sapply(corpus, as.character)
clean_text <- paste(clean_text, collapse = " ")

#--------------------------
# 4. Kelime Frekansı ve Bulut Analizi
#--------------------------
words <- unlist(strsplit(clean_text, " "))
words <- words[words != ""]
word_freq <- table(words)
word_freq_df <- data.frame(word = names(word_freq), freq = as.numeric(word_freq))
word_freq_df <- word_freq_df[!(word_freq_df$word == "" | is.na(word_freq_df$word)), ]

# En sık kullanılan 10 kelime
print(head(word_freq_df[order(-word_freq_df$freq), ], 10))

# Kelime bulutu
wordcloud(names(word_freq), freq = word_freq, min.freq = 5, colors = brewer.pal(8, "Dark2"))
wordcloud2(word_freq_df, size = 1, color = rep_len(c("red", "blue", "green"), nrow(word_freq_df)))
wordcloud2(word_freq_df, size = 1, shape = 'heart', color = "random-light", backgroundColor = "white")

# Bar grafiğiyle ilk 20 kelime
top_words <- head(word_freq_df[order(-word_freq_df$freq), ], 20)
ggplot(top_words, aes(x = reorder(word, freq), y = freq)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + theme_minimal() +
  labs(title = "En Sık Geçen Kelimeler", x = "Kelimeler", y = "Frekans")

#--------------------------
# 5. Duygu Analizi
#--------------------------
sentiments <- get_nrc_sentiment(clean_text)
barplot(colSums(sentiments), las = 2, col = rainbow(10), main = "Duygu Dağılımı")

positive <- sum(sentiments$positive)
negative <- sum(sentiments$negative)
score_ratio <- ifelse(negative > 0, positive / negative, NA)
print(paste("Pozitif/Negatif Oranı:", score_ratio))

# Pozitif/Negatif barplot
sentiment_data <- data.frame(Duygu = c("Pozitif", "Negatif"), Frekans = c(positive, negative))
barplot(
  sentiment_data$Frekans,
  names.arg = sentiment_data$Duygu,
  col = c("green", "red"),
  main = "Pozitif/Negatif Duygu Dağılımı",
  ylim = c(0, max(sentiment_data$Frekans) + 10),
  ylab = "Frekans",
  xlab = "Duygular"
)
text(
  x = 1:2,
  y = sentiment_data$Frekans,
  label = sentiment_data$Frekans,
  pos = 3,
  cex = 0.8
)

#--------------------------
# 6. N-gram (Bigram/Trigram) Analizi
#--------------------------
# Bigram
bigrams <- unnest_tokens(tbl = data.frame(text = clean_text), output = "bigram", input = "text", token = "ngrams", n = 2)
bigram_freq <- bigrams %>% count(bigram, sort = TRUE)
print(head(bigram_freq, 10))
ggplot(head(bigram_freq, 20), aes(x = reorder(bigram, n), y = n)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() + theme_minimal() +
  labs(title = "En Sık Geçen Bigram'lar", x = "Bigramlar", y = "Frekans")

# Trigram
trigrams <- unnest_tokens(tbl = data.frame(text = clean_text), output = "trigram", input = "text", token = "ngrams", n = 3)
trigram_freq <- trigrams %>% count(trigram, sort = TRUE)
print(head(trigram_freq, 10))
ggplot(head(trigram_freq, 20), aes(x = reorder(trigram, n), y = n)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  coord_flip() + theme_minimal() +
  labs(title = "En Sık Geçen Trigram'lar", x = "Trigramlar", y = "Frekans")