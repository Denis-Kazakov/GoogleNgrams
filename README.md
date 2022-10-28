Phrase frequencies in Google Books

It was a study project on the Data Scientist upskilling course at School 21 (https://edu.21-school.ru/). Project task was to find an API in the Internet and create a web-service using Flask, FastAPI or a Telegram bot.

I had worked as a translator for many years so I did a project in linguistics. One of the tools I often use in my work to analyze word usage is Google Ngrams (https://books.google.com/ngrams). It builds plots that can be used to compare frequencies of different phrases. The comparison is qualitative and it is not always easy to say which is more frequent as in the example on the home page. It is not also possible to say whether the apparent different is statistically significant.

The idea is to provide an interface where a user can enter the same data (language, two phrases, time interval, etc., except smoothing which is not used) and get both the plot and an answer which phrase is more common and whether the difference is statistically significant.

This version supports only some corpora: only the 2019 versions of the English, French, German, Italian, Russian and Spanish corpora.

The web-service gets frequencies for each year in the interval and compares the using paired t-test.


I produced the Jupyter notebook. Sergey Krosheninnikov prepared a py file, and Roman (https://github.com/khimich1) designed an MVP (minimum viable product) interface (only the Russian language and one time interval).

### Files:
- d08_0.ipynb – original Jupyter notebook
- d08_0.R – same algorithm in R
- d08_1.ipynb, d08_1.py – notebook and python script with class definition for the MVP version
- p-value_phrases-main.zip – web-interface

This version is hosted at RomanSmit1.pythonanywhere.com
