library(httr)
library(jsonlite)
library(tidyverse)

# Setup
base_url <- 'https://books.google.com/ngrams/json?'

# Input

# Corpora
lang = 'Russian'

# Available year range: 1500 to 2019
year_start <-  2000
year_end <- 2019

# N-grams. No more than 5 words. No punctuation, only letters!
ngram_1 <-  'как бы то ни было'
ngram_2 <-  'как бы там ни было'

# Case sensitivity
case_insensitive_1 <- FALSE
case_insensitive_2 <- FALSE


ngram_stat <- function(base_url, ngram, year_start, year_end = 2019, lang, case_insensitive=FALSE) {
  corpora <-  c('English' = 26, 
                'French' = 30, 
                'German' = 31,
                'Italian' = 33,
                'Russian' = 36,
                'Spanish' = 32
  )
  query = list(content=ngram,
               year_start=year_start,
               year_end=year_end,
               corpus=corpora[lang],
               smoothing=0)
  
  if (case_insensitive) {
    query = append(query, list(case_insensitive='true'))
  }
  raw_data <- GET(base_url, query=query)
  
  return(fromJSON(rawToChar(raw_data$content)))
}


result_1 <- ngram_stat(base_url = base_url,
                       ngram = ngram_1,
                       year_start = year_start, 
                       lang = lang,
                       case_insensitive = case_insensitive_1)
result_2 <- ngram_stat(base_url = base_url,
                       ngram = ngram_2,
                       year_start = year_start, 
                       lang = lang,
                       case_insensitive = case_insensitive_2)

tst <- t.test(result_1$timeseries[[1]], result_2$timeseries[[1]], paired = TRUE)

if (tst$estimate >= 0) common = 'more' else common = 'less'
title <- paste0('"', ngram_1, '" is ', common, ' common than "', ngram_2, '"')
subtitle <- paste0('p-value = ', tst$p.value)

results <- data.frame(time = year_start:year_end,
                      ngram_1 = result_1$timeseries[[1]],
                      ngram_2 = result_2$timeseries[[1]])

colnames(results) <- c('time', ngram_1, ngram_2)
results <- results %>% 
  pivot_longer(names_to = 'Ngram',
               cols = !time,
               values_to = 'Frequency')



ggplot(data =  results) +
  geom_line(aes(time, Frequency, colour = Ngram), size = 1) +
  labs(
    title = title,
    subtitle = subtitle
  ) +
  ylab('frequency')


# URL for request. NOT USED as I found a way to use a list of parameters
url_paste <- function(base_url, ngram, year_start, year_end = 2019, lang, case_insensitive=FALSE) {
  corpora <-  c('English' = 26, 
                'French' = 30, 
                'German' = 31,
                'Italian' = 33,
                'Russian' = 36,
                'Spanish' = 32
  )
  cont <-  paste0('content=', ngram)
  year_start <- paste0('year_start=', year_start)
  year_end <- paste0('year_end=', year_end)
  corpus <- paste0('corpus=', corpora[lang])
  postfix <- paste(cont, year_start, year_end, corpus, 'smoothing=0', sep = '&')
  full_url <- paste0(base_url, postfix)
  if (case_insensitive) {
    full_url <- paste0(full_url, 'case_insensitive=true')
  }
  return(full_url)
}