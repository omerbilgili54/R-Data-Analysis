# PDF Metin Analizi ve Duygu Çıkarımı (R ile Veri Madenciliği Projesi)

Bu projede, **PDF metin analizi** ve **duygu analizi** yöntemleri kullanılarak, bir akademik makale örneği üzerinden veri madenciliği çalışması gerçekleştirilmiştir. Amaç, verilen bir metinden anlamlı bilgiler çıkararak, metnin duygu yönelimi ve öne çıkan kelime yapılarını analiz etmektir.

## Proje Hakkında

Bu proje, metin madenciliği, kelime bulutu ve duygu analizi tekniklerini bir arada kullanarak akademik metinler üzerinde bilgi çıkarımı yapmayı hedefler. Metin işleme ve görselleştirme adımlarına odaklanılmıştır.

## Veri Kaynağı

- **Makale Başlığı:** Suriyeli mültecilere yönelik olumsuz tutumların etnik ve politik kimlik ile algılanan tehdit üzerinden incelenmesi
- **Kaynak:** Turkish Journal of Psychology
- **DOI:** [10.31828/turkpsikoloji.1399928](https://doi.org/10.31828/turkpsikoloji.1399928)
- **Veri Tipi:** PDF (akademik makale)

## Kullanılan Araçlar ve Kütüphaneler

- **R Programlama Dili**
- **pdftools**: PDF’den metin okuma
- **tm**: Metin madenciliği ve temizleme
- **stringr**: Karakter işlemleri
- **wordcloud**: Kelime bulutu oluşturma
- **syuzhet**: Duygu analizi
- **ggplot2**: Görselleştirme

## Çalışma Aşamaları

### 1. Veri Yükleme ve Hazırlık

Proje, PDF dosyasının okunması ve işlenmesiyle başlamıştır. Metin içerikleri temizlenmiş, anlamsız kelimeler (stopwords) çıkarılmış ve analiz edilebilir bir formata dönüştürülmüştür.

Bu aşamada ilk gerçekleştirilen adım verileri elde edeceğimiz PDF dosyasının okunması ve işlenmesidir. R kütüphanesi içerisinde bulunan “pdftools” paketini kullanarak dosya içeriği yüklenmiştir.

- PDF dosyası `pdftools` ile okunur.
- Metin temizlenir, gereksiz karakterler ve stopwords çıkarılır.
- Temiz metin analiz edilebilir hale getirilir.

```r
install.packages("pdftools")
library(pdftools)

# PDF dosyasını okuyun
pdf_text <- pdf_text("/Users/omerbilgili/Downloads/turkpsikoloji.1399928-2.pdf")
```
Daha sonra aşağıdaki kod ile dosya içeriği metin formatına dönüştürülmüştür:

```r
# Metni birleştir
text <- paste(pdf_text, collapse = " ") 
```
Sonrasında metin madenciliğinin en önemli adımlarından biri olan metin temizleme işlemine geçiyoruz. İlk olarak metindeki gereksiz karakterler ve anlamsız kelimeler temizlenmiştir.

```r
# Temizlik işlemleri için gerekli paketler
install.packages("tm")
install.packages("stringr")
library(tm)
library(stringr)

# Corpus oluşturma
corpus <- VCorpus(VectorSource(text))

# Metni temizleme
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, stripWhitespace)
corpus <- tm_map(corpus, removeWords, stopwords("en"))

# Temizlenmiş metni kontrol etme
inspect(corpus)

# Corpus'tan temiz metin oluşturma
clean_text <- sapply(corpus, as.character)
clean_text <- paste(clean_text, collapse = " ")
```

### 2. Kelime Frekansı ve Bulut Analizi
Metindeki her bir kelimenin tekrar sıklığı hesaplanmıştır. Görselleştirme aşamasında:

* **Kelime Frekansı Analizi:** En sık kullanılan kelimeler tespit edilmiştir. Örneğin, “negative” kelimesi dikkat çekici bir şekilde ikinci sırada yer almıştır.

<img width="548" height="489" alt="Kelime Frekans" src="https://github.com/user-attachments/assets/9ee14f84-1718-4250-8303-e567fe1c7b93" />

```r
# Kelime frekansı analizi
word_freq <- table(unlist(strsplit(clean_text, " ")))
head(sort(word_freq, decreasing = TRUE), 10)  # En sık kullanılan 10 kelime
```

* **Kelime Bulutu:** Metinde öne çıkan kavramlar renkli bir bulut grafiğiyle görselleştirilmiştir.

<img width="1190" height="974" alt="Rplot07" src="https://github.com/user-attachments/assets/4b0273c1-5c54-4c64-a3c3-8311d61d6908" />


```r
# Kelime bulutu oluşturma
library(RColorBrewer)
wordcloud(names(word_freq), freq = word_freq, min.freq = 5, colors=brewer.pal(8, "Dark2"))
```

### 3. Duygu Analizi
Duygu analizi, metindeki pozitif, negatif ve diğer duygu tonlarını belirlemek amacıyla yapılmıştır. Syuzhet kütüphanesi kullanılarak şu sonuçlar elde edilmiştir:

* **Duygu Dağılımı:** Metnin genel olarak negatif odaklı olduğu görülmüştür.

<img width="1376" height="924" alt="d9b0fb4b-4882-4df6-ba8f-8c55059afaa1" src="https://github.com/user-attachments/assets/2cade286-ad4c-4a49-9ade-a8bf456d18cd" />

```r
# Duygu analizi aşaması
install.packages("syuzhet")
library(syuzhet)

sentiments <- get_nrc_sentiment(clean_text)
barplot(colSums(sentiments), las = 2, col = rainbow(10), main = "Duygu Dağılımı")

positive <- sum(sentiments$positive)
negative <- sum(sentiments$negative)
```

* **Pozitif/Negatif Oran:** Pozitif duyguların negatiflere kıyasla daha az baskın olduğu tespit edilmiştir.

<img width="1066" height="795" alt="4f9806ed-40b2-465c-a037-a993a24ae7a7" src="https://github.com/user-attachments/assets/0848b54b-5f9a-4372-9e21-a179ced79371" />

```r
# Pozitif/Negatif oran
score_ratio <- positive / negative
print(paste("Pozitif/Negatif Oranı:", score_ratio))
```



### 4. N-gram Analizleri
Metindeki kelime gruplarını (bigram ve trigram) analiz ederek, hangi kelimelerin daha sık birlikte kullanıldığı belirlenmiştir. Bu analiz, metin içindeki bağlamları anlamaya yardımcı olmuştur.

<img width="548" height="489" alt="Bigram Frekans" src="https://github.com/user-attachments/assets/8311978b-75ce-4381-9121-e20897a5bb6e" />


<img width="548" height="489" alt="Trigram Frekans" src="https://github.com/user-attachments/assets/995f6e26-29d3-4a4a-a372-3227838056b8" />



## Sonuçlar

Bu proje, akademik metinler üzerinde veri madenciliği uygulamalarının nasıl kullanılabileceğini göstermiştir. Özellikle:

1.Kelime ve duygu analizi, metnin yapısını anlamada güçlü bir araçtır.

2.Görselleştirme teknikleri, metindeki önemli detayları kullanıcı dostu bir şekilde sunar.

3.Çıkarılan sonuçlar, metin analizi çalışmalarında kullanılabilir önemli içgörüler sağlamıştır.


**Medium yazım:** [Veri Madenciliği Projesi - PDF Metin Analizi ve Duygu Çıkarımı](https://medium.com/@omerbilgili/veri-madencili%C4%9Fi-projesi-pdf-metin-analizi-ve-duygu-%C3%A7%C4%B1kar%C4%B1m%C4%B1-f1276ec55029)
