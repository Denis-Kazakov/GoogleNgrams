from flask import Flask, render_template, url_for, request, redirect
import requests
import json
from scipy import stats


class GBN:  # Google_Book_Ngram:
    '''работа с Google Books Ngram'''

    def __init__(self,
                 ngram1,
                 ngram2,
                 lang="Russian",
                 y_beg=1800,
                 y_end=2019,
                 caseins=False,
                 alpha=0.95):  # Инициализация класса

        self.ngram1 = ngram1
        self.ngram2 = ngram2

        corpora = {'English': 26,
                   'French': 30,
                   'German': 31,
                   'Italian': 33,
                   'Russian': 36,
                   'Spanish': 32}  # выбор корпуса
        corpus = corpora[lang]

        params_1 = {
            'content': ngram1,
            'year_start': y_beg,
            'year_end': y_end,
            'corpus': corpus,
            'smoothing': 0
        }  # Параметры запроса для 1-й фразы

        params_2 = {
            'content': ngram2,
            'year_start': y_beg,
            'year_end': y_end,
            'corpus': corpus,
            'smoothing': 0
        }  # Параметры запроса для 2-й фразы

        #        self.caseins = caseins        # регистрозависимость
        self.alpha = alpha  # уровень статистической значимости

        # получение выборок
        url = 'https://books.google.com/ngrams/json?'  # путь запроса к API Google
        self.result_1 = requests.get(url, params_1).json()[0]['timeseries']
        self.result_2 = requests.get(url, params_2).json()[0]['timeseries']

        # расчет сравнения
        self.cmpr = stats.ttest_rel(self.result_1, self.result_2)

    # печать результата
    def print(self):
        if self.cmpr.statistic >= 0:
            more_common = self.ngram1
            less_common = self.ngram2
        else:
            more_common = self.ngram2
            less_common = self.ngram1

        if self.cmpr.pvalue < self.alpha:
            significance = 'и разница статистически значима'
        else:
            significance = 'но разница статистически незначима'

        outcome = 'Фраза "{0}" встречается чаще, чем фраза "{1}", {2} (p-value = {3})'.format(more_common,
                                                                                              less_common,
                                                                                              significance,
                                                                                              self.cmpr.pvalue)
        return outcome


app = Flask(__name__)

@app.route('/', methods=['POST', 'GET'])

def index():
    if request.method == "POST":
        global title_1
        global title_2
        title_1 = request.form['title']
        title_2 = request.form['intro']

        article = Article(phrase_1=title_1, phrase_2=title_2)

    else:
        return render_template("index.html")


@app.route('/about')
def about():
    comparator = GBN(title_1, title_2)
    otvet = comparator.print()
    return render_template("about.html", comparator=comparator,otvet=otvet)

if __name__ == '__main__':
    app.run(debug = False)
