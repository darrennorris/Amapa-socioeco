# Amapa-socioeco
[![DOI](https://zenodo.org/badge/432228178.svg)](https://zenodo.org/badge/latestdoi/432228178)

Código de [R](https://cran.r-project.org/) e dados para o mapeamento de variáveis socioeconômicas no estado do Amapá.


[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]  [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa] This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

## Conteúdo
Os dados aqui apresentados (gráficos, mapas) representam conteúdo do domínio público, disponibilizados pelos institutos, órgãos e entidades federais, estaduais e privados ([IBGE](https://www.ibge.gov.br/),  [Atlas do Desenvolvimento Humano](http://www.atlasbrasil.org.br), [Atlas da Vulnerabilidade Social](http://ivs.ipea.gov.br/index.php/pt/planilha), [PNUD](https://www.br.undp.org/content/brazil/pt/home/our-focus.html), [EMBRAPA](http://geoinfo.cnps.embrapa.br/), [Agência Nacional de Mineração](https://dados.gov.br/dataset/sistema-de-informacoes-geograficas-da-mineracao-sigmine) ). O conteúdo está aqui apresentado para divulgação ampla, respetiando as obrigações de transparência, assim para agilizar e facilitar o desenvolvimento técnico científco. O conteúdo não representar versões ou produtos  finais e não devem ser apresentados/relatados/compartilhados/interpretados como conclusivos. 

Os mapas e cartogramas ficam na pasta [figures](https://github.com/darrennorris/ZEEAmapa/tree/main/figures) (formato .png e .tif), dados geoespaciais na pasta [vector](https://github.com/darrennorris/ZEEAmapa/tree/main/vector) (formato shapefile e GPKG) e dados tabulados na pasta [dados](https://github.com/darrennorris/ZEEAmapa/tree/main/dados) (copia de dados disponibilisados pela [abjData](https://github.com/abjur/abjData), definicão de siglas etc) .

- [Mapas](#mapas)
  * [Desenvolvimento e Vulnerabilidade](#desenvolvimento-e-vulnerabilidade)
- [Mineração](#mineracao)

## Mapas
### Desenvolvimento e Vulnerabilidade
Índice de Desenvolvimento Humano Municipal no Estado do Amapá
(imagem de alta qualidade aqui: [IDHM/AP](https://github.com/darrennorris/ZEEAmapa/blob/main/figures/AP_mapa_IDHM.tif) )

<img src="figures/AP_mapa_IDHM.png" alt="IDHM" width="300" height="400">

Para entender melhor os valores do IDHM apresentados e também para facilitar o diálogo entre pessoas, poderes e institutos é possível verificar quais são as variáveis socioeconômicas mais importantes para as mudanças durante os últimos 30 anos.

Um diagnóstico com base em modelos lineares mostra que ações para reduzir pobreza, reduzir desigualdade e melhorar educação são os mais relevantes para melhorar o desenvolvimento humano no estado do Amapá. 

Especificamente, para acelerar o desenvolvimento humano no estado do Amapá, ações devem melhorar o percentual de 11-13 anos com ensino fundamental completo e a renda dos 60% mais pobres.  
(imagem de alta qualidade aqui: [variáveis importantes ](https://github.com/darrennorris/ZEEAmapa/blob/main/figures/AP_fig_impvars.tif) )

<img src="figures/AP_fig_impvars.png" alt="IDHM" width="450" height="500">

|  correlação  |  nome                                                  |
|--------------|--------------------------------------------------------|
|  1.00        |  Percentual da renda apropriada pelos 60% mais pobres  |
|  0.96        |  Percentual da renda apropriada pelos 80% mais pobres  |
|  0.95        |  Percentual da renda apropriada pelos 40% mais pobres  |
|  0.82        |  Percentual da renda apropriada pelos 20% mais pobres  |


Table 2
|  correlação  |  nome                                                                                         |
|--------------|-----------------------------------------------------------------------------------------------|
|  1.00        |  % de 11 a 13 anos nos anos finais do fundamental ou com fundamental completo                 |
|  0.99        |  % de 12 a 14 anos nos anos finais do fundamental ou com fundamental completo                 |
|  0.94        |  % de 15 a 17 anos com fundamental completo                                                   |
|  0.94        |  % de 18 a 24 anos com fundamental completo                                                   |
|  0.93        |  % de 18 anos ou mais com fundamental completo                                                |
|  0.92        |  Taxa de frequência líquida ao médio                                                          |
|  0.92        |  % de 16 a 18 anos com fundamental completo                                                   |
|  0.92        |  % da população em domicílios com água encanada                                               |
|  0.91        |  % de 6 a 17 anos no básico sem atraso                                                        |
|  0.91        |  % de 6 a 14 anos no fundamental sem atraso                                                   |
|  0.91        |  % de 25 anos ou mais com fundamental completo                                                |
|  0.89        |  Probabilidade de sobrevivência até 40 anos                                                   |
|  0.89        |  % de 18 anos ou mais com médio completo                                                      |
|  0.88        |  Probabilidade de sobrevivência até 60 anos                                                   |
|  0.88        |  % de 18 a 20 anos com médio completo                                                         |
|  0.88        |  % de 25 anos ou mais com médio completo                                                      |
|  0.87        |  Esperança de vida ao nascer                                                                  |
|  0.87        |  % de 18 a 24 anos com médio completo                                                         |
|  0.85        |  % de 19 a 21 anos com médio completo                                                         |
|  0.84        |  Taxa de frequência bruta ao médio                                                            |
|  0.83        |  Taxa de frequência bruta ao superior                                                         |
|  0.82        |  Taxa de frequência líquida ao básico                                                         |
|  0.82        |  % de 5 a 6 anos na escola                                                                    |
|  0.81        |  Taxa de frequência bruta ao básico                                                           |
|  0.81        |  % da população em domicílios com banheiro e água encanada                                    |
|  0.80        |  % de 6 a 14 anos na escola                                                                   |
|  0.79        |  Expectativa de anos de estudo                                                                |
|  0.79        |  Taxa de frequência líquida ao fundamental                                                    |
|  0.79        |  % de 6 anos na escola                                                                        |
|  0.79        |  % de 6 a 17 anos na escola                                                                   |
|  0.77        |  % de 6 a 14 anos no médio                                                                    |
|  0.77        |  % da população em domicílios com coleta de lixo                                              |
|  0.77        |  % da população em domicílios com energia elétrica                                            |
|  0.76        |  % de 11 a 14 anos na escola                                                                  |
|  0.74        |  % de 15 a 17 anos na escola                                                                  |
|  0.74        |  % de 25 anos ou mais com superior completo                                                   |
|  0.72        |  Taxa de frequência bruta ao fundamental                                                      |
|  0.70        |  Taxa de frequência bruta à pré-escola                                                        |
|  0.66        |  Taxa de frequência líquida à pré-escola                                                      |
|  0.66        |  % de 18 a 24 anos no médio                                                                   |
|  0.66        |  Renda per capita média do quinto mais rico                                                   |
|  0.65        |  Taxa de frequência líquida ao superior                                                       |
|  0.65        |  Renda per capita mínima do décimo mais rico                                                  |
|  0.65        |  Renda per capita                                                                             |
|  0.65        |  Renda per capita média do 4º quinto mais pobre                                               |
|  0.65        |  Renda per capita , exceto renda nula                                                         |
|  0.64        |  Renda per capita máxima do 3° quinto mais pobre                                              |
|  0.64        |  Renda per capita máxima do 4°quinto mais pobre                                               |
|  0.64        |  Renda per capita média do 3º quinto mais pobre                                               |
|  0.63        |  Renda per capita média do décimo mais rico                                                   |
|  0.62        |  % de 15 a 17 anos no médio sem atraso                                                        |
|  0.60        |  Renda per capita máxima do 2° quinto mais pobre                                              |
|  0.60        |  % de mães chefes de família sem fundamental completo e com filhos menores de 15 anos         |
|  0.59        |  % de 25 a 29 anos na escola                                                                  |
|  0.57        |  % de 15 a 17 anos no superior                                                                |
|  0.57        |  Índice de Theil - L                                                                          |
|  0.56        |  % de 18 a 24 anos na escola                                                                  |
|  0.52        |  Renda per capita média do 2º quinto mais pobre                                               |
|  0.48        |  Renda per capita média dos vulneráveis à pobreza                                             |
|  0.46        |  Taxa de envelhecimento                                                                       |
|  0.46        |  Renda per capita máxima do 1º quinto mais pobre                                              |
|  0.35        |  % de 15 a 17 no médio com 1 ano de atraso                                                    |
|  0.34        |  Percentual da renda apropriada pelos 20% mais ricos                                          |
|  0.32        |  População masculina de 70 a 74 anos                                                          |
|  0.31        |  População masculina de 50 a 54 anos                                                          |
|  0.31        |  População masculina de 55 a 59 anos                                                          |
|  0.31        |  População masculina de 60 a 64 anos                                                          |
|  0.31        |  População masculina de 65 a 69 anos                                                          |
|  0.31        |  População masculina de 75 a 79 anos                                                          |
|  0.30        |  População masculina de 40 a 44 anos                                                          |
|  0.30        |  População masculina de 45 a 49 anos                                                          |
|  0.30        |  População feminina de 65 a 69 anos                                                           |
|  0.30        |  População de 65 anos ou mais                                                                 |
|  0.29        |  População masculina de 25 a 29 anos                                                          |
|  0.29        |  População masculina de 30 a 34 anos                                                          |
|  0.29        |  População masculina de 35 a 39 anos                                                          |
|  0.29        |  População masculina com 80 anos e mais                                                       |
|  0.29        |  População feminina de 30 a 34 anos                                                           |
|  0.29        |  População feminina de 35 a 39 anos                                                           |
|  0.29        |  População feminina de 40 a 44 anos                                                           |
|  0.29        |  População feminina de 45 a 49 anos                                                           |
|  0.29        |  População feminina de 50 a 54 anos                                                           |
|  0.29        |  População feminina de 55 a 59 anos                                                           |
|  0.29        |  População feminina de 60 a 64 anos                                                           |
|  0.29        |  População feminina de 70 a 74 anos                                                           |
|  0.29        |  População feminina de 75 a 79 anos                                                           |
|  0.29        |  População de 15 anos ou mais                                                                 |
|  0.29        |  População de 18 anos ou mais                                                                 |
|  0.29        |  População de 25 anos ou mais                                                                 |
|  0.29        |  Mulheres de 25 anos ou mais                                                                  |
|  0.28        |  População masculina de 15 a 19 anos                                                          |
|  0.28        |  População masculina de 20 a 24 anos                                                          |
|  0.28        |  População residente masculina                                                                |
|  0.28        |  População feminina de 20 a 24 anos                                                           |
|  0.28        |  População feminina de 25 a 29 anos                                                           |
|  0.28        |  População feminina com 80 anos e mais                                                        |
|  0.28        |  População residente feminina                                                                 |
|  0.28        |  População de 15 a 17 anos                                                                    |
|  0.28        |  População de 15 a 24 anos                                                                    |
|  0.28        |  População de 18 a 24 anos                                                                    |
|  0.28        |  Mulheres de 15 a 17 anos                                                                     |
|  0.28        |  Mulheres de 15 anos ou mais                                                                  |
|  0.28        |  População total                                                                              |
|  0.28        |  População urbana                                                                             |
|  0.28        |  População total em domicílios particulares permanentes                                       |
|  0.28        |  População total em domicílios particulares permanentes, exceto com renda nula                |
|  0.27        |  Renda per capita média do 1º quinto mais pobre                                               |
|  0.27        |  População masculina de 10 a 14 anos                                                          |
|  0.27        |  População feminina de 10 a 14 anos                                                           |
|  0.27        |  População feminina de 15 a 19 anos                                                           |
|  0.27        |  População de 11 a 14 anos                                                                    |
|  0.27        |  População de 11 a 13 anos                                                                    |
|  0.27        |  População de 12 a 14 anos                                                                    |
|  0.27        |  População de 16 a 18 anos                                                                    |
|  0.27        |  População de 18 a 20 anos                                                                    |
|  0.27        |  População de 19 a 21 anos                                                                    |
|  0.27        |  Mulheres de 10 a 14 anos                                                                     |
|  0.26        |  População masculina de 5 a 9 anos                                                            |
|  0.26        |  População feminina de 5 a 9 anos                                                             |
|  0.26        |  População de 6 a 10 anos                                                                     |
|  0.26        |  População de 6 a 17 anos                                                                     |
|  0.25        |  População de 4 anos                                                                          |
|  0.25        |  População de 5 anos                                                                          |
|  0.25        |  População de 6 anos                                                                          |
|  0.24        |  % de 6 a 17 no básico com 1 ano de atraso                                                    |
|  0.24        |  Percentual da renda apropriada pelos 10% mais ricos                                          |
|  0.24        |  População masculina de 0 a 4 anos                                                            |
|  0.24        |  População feminina de 0 a 4 anos                                                             |
|  0.24        |  População de até 1 ano                                                                       |
|  0.24        |  População de 1 a 3 anos                                                                      |
|  0.23        |  Razão 10% mais ricos / 40% mais pobres                                                       |
|  0.23        |  Razão 20% mais ricos / 40% mais pobres                                                       |
|  0.23        |  População rural                                                                              |
|  -0.01       |  Renda per capita média dos pobres                                                            |
|  -0.02       |  % de pessoas em domicílios vulneráveis à pobreza e dependentes de idosos                     |
|  -0.03       |  % de 6 a 14 anos no fundamental com 1 ano de atraso                                          |
|  -0.04       |  % de 15 a 17 anos no médio com 2 anos de atraso                                              |
|  -0.04       |  % de 15 a 17 anos no fundamental                                                             |
|  -0.06       |  % de 18 a 24 anos no fundamental                                                             |
|  -0.06       |  % de pessoas em domicílios com abastecimento de água e esgotamento sanitário inadequados     |
|  -0.08       |  % de pessoas em domicílios em que ninguém tem fundamental completo                           |
|  -0.09       |  % de pessoas em domicílios vulneráveis à pobreza e em que ninguém tem fundamental completo.  |
|  -0.09       |  % de mulheres de 10 a 14 anos que tiveram filhos                                             |
|  -0.20       |  % da renda proveniente de rendimentos do trabalho                                            |
|  -0.28       |  % de mulheres de 15 a 17 anos que tiveram filhos                                             |
|  -0.30       |  Percentual da renda apropriada pelos 20% mais pobres                                         |
|  -0.34       |  Percentual da renda apropriada pelos 80% mais pobres                                         |
|  -0.35       |  Percentual da renda apropriada pelos 40% mais pobres                                         |
|  -0.35       |  Renda per capita média dos extremamente pobres                                               |
|  -0.37       |  Percentual da renda apropriada pelos 60% mais pobres                                         |
|  -0.42       |  % de crianças extremamente pobres                                                            |
|  -0.45       |  % de extremamente pobres                                                                     |
|  -0.58       |  % de crianças vulneráveis à pobreza                                                          |
|  -0.62       |  % de crianças pobres                                                                         |
|  -0.66       |  % de pobres                                                                                  |
|  -0.67       |  % de vulneráveis à pobreza                                                                   |
|  -0.74       |  Taxa de analfabetismo - 15 a 17 anos                                                         |
|  -0.76       |  Taxa de analfabetismo - 11 a 14 anos                                                         |
|  -0.77       |  Taxa de analfabetismo - 15 anos ou mais                                                      |
|  -0.77       |  Taxa de analfabetismo - 25 anos ou mais                                                      |
|  -0.77       |  % de pessoas em domicílios sem energia elétrica                                              |
|  -0.78       |  Taxa de analfabetismo - 18 anos ou mais                                                      |
|  -0.79       |  Taxa de fecundidade total                                                                    |
|  -0.79       |  Taxa de analfabetismo - 18 a 24 anos                                                         |
|  -0.80       |  Taxa de analfabetismo - 25 a 29 anos                                                         |
|  -0.80       |  % de crianças de 6 a 14 fora da escola                                                       |
|  -0.85       |  Mortalidade infantil                                                                         |
|  -0.85       |  Mortalidade até 5 anos de idade                                                              |
|  -0.86       |  % da população em domicílios com densidade > 2                                               |
|  -0.87       |  Razão de dependência                                                                         |
|  -0.92       |  % de 6 a 14 anos no fundamental com 2 anos ou mais de atraso                                 |
|  -0.94       |  % de 6 a 17 anos no básico com 2 anos ou mais de atraso                                      |


Primeiro passo para melhorar (aumentar) o percentual de 11-13 anos com ensino fundamental completo (e portanto educação no estado) seria aumentar a porcentagem de mulheres concluindo ensino fundamental.

Variáveis socioeconômicas não existem em isolação, e com base nos dados globais mostrando a importância de educação ([Hans Rosling Religion and babies](https://www.ted.com/talks/hans_rosling_religions_and_babies/transcript?language=en)), podemos olhar as mudanças entre 1991 e 2010 de educação e maternidade em mulheres mais jovens ([WHO](https://www.who.int/news-room/fact-sheets/detail/adolescent-pregnancy), [febrasgo Gravidez na adolescencia](https://www.febrasgo.org.br/pt/noticias/item/1210-reflexoes-sobre-a-semana-nacional-de-prevencao-da-gravidez-na-adolescencia-2021)). Conforme a educação avançava, houve uma redução na % de maternidade em mulheres mais jovens (redução no % mediano e na variação nos valores entre municípios), e portanto, com avanços na educação, esperamos uma redução expressiva na desigualdade entre os sexos .......

(imagem de alta qualidade aqui: [maternidade/AP](https://github.com/darrennorris/ZEEAmapa/blob/main/figures/AP_fig_muledu.tif) )

<img src="figures/AP_fig_muledu.png" alt="maternidade" width="450" height="350">

<a id="mineracao"></a>
## Mineração
Espera-se que as tensões entre mineração e desenvolvimento sustentável se intensificam à medida que as populações humanas crescem e as tecnologias avançam. No entanto, a mineração também pode ser um meio de financiar caminhos alternativos de desenvolvimento que, a longo prazo, podem trazer verios beneficios ([DDSM](https://www.gov.br/mme/pt-br/assuntos/secretarias/geologia-mineracao-e-transformacao-mineral/desenvolvimento-sustentavel-na-mineracao-1), [IISD](https://www.iisd.org/articles/how-advance-sustainable-mining)).

Mineração a escala industrial iniciou na década de 1950 no Estado do Amapá. Depois de mais de 70 anos, um relatorio recente ([Costa 2019](http://ageamapa.ap.gov.br/docs/investinamapa/Plano-de-Mineracao.pdf)) demonstra que a exportação de bens minerais ainda é o principal gerador de receitas na balança comercial amapaense, representando aproximadamente 65% de tudo que foi exportado pelo estado em 2018 (cerca de 150 milhões de dólares (US$)).

A arrecadação atraves Compensação Financeira pela Exploração de Recursos Minerais ([CFEM](https://sistemas.anm.gov.br/arrecadacao/extra/relatorios/arrecadacao_cfem.aspx)) gerar recursos finaceiros (para os estados e municipios) destinadas a reparar os danos causados nas áreas de exploração mineral.

(imagem de alta qualidade aqui: [CFEM/AP](https://github.com/darrennorris/Amapa-socioeco/blob/main/figures/AP_fig_cfem.tif) )
<img src="figures/AP_fig_cfem.png" alt="IDHM" width="400" height="200">

Dois municípios no estado (Vitória do Jari e Pedra Branca do Amapari) representam os municípios com as maiores receitas de CFEM entre 2004 e 2021.

(imagem de alta qualidade aqui: [CFEM/MAPA/AP](https://github.com/darrennorris/Amapa-socioeco/blob/main/figures/AP_mapa_cfem.tif) )
<img src="figures/AP_mapa_cfem.png" alt="IDHM" width="380" height="250">

