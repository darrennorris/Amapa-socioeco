# Amapa-socioeco
[![DOI](https://zenodo.org/badge/432228178.svg)](https://zenodo.org/badge/latestdoi/432228178)

Código de [R](https://cran.r-project.org/) e dados para o mapeamento de variáveis socioeconômicas no estado do Amapá.


Shield: [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg

## Conteúdo
Os dados aqui apresentados (gráficos, mapas) representam conteúdo do domínio público, disponibilizados pelos institutos, órgãos e entidades federais, estaduais e privados ([IBGE](https://www.ibge.gov.br/),  [Atlas do Desenvolvimento Humano](http://www.atlasbrasil.org.br), [Atlas da Vulnerabilidade Social](http://ivs.ipea.gov.br/index.php/pt/planilha), [PNUD](https://www.br.undp.org/content/brazil/pt/home/our-focus.html), [EMBRAPA](http://geoinfo.cnps.embrapa.br/), [Agência Nacional de Mineração](https://dados.gov.br/dataset/sistema-de-informacoes-geograficas-da-mineracao-sigmine) ). O conteúdo está aqui apresentado para divulgação ampla, respetiando as obrigações de transparência, assim para agilizar e facilitar o desenvolvimento técnico científco. O conteúdo não representar versões ou produtos  finais e não devem ser apresentados/relatados/compartilhados/interpretados como conclusivos. 

Os mapas e cartogramas ficam na pasta [figures](https://github.com/darrennorris/ZEEAmapa/tree/main/figures) (formato .png e .tif), dados geoespaciais na pasta [vector](https://github.com/darrennorris/ZEEAmapa/tree/main/vector) (formato shapefile e GPKG) e dados tabulados na pasta [dados](https://github.com/darrennorris/ZEEAmapa/tree/main/dados) (copia de dados disponibilisados pela [abjData](https://github.com/abjur/abjData), definicão de siglas etc) .

-   [Mapas](#Mapas)
      -   [Índices](##Índices de Desenvolvimento e Vulnerabilidade)
-   [Mineração](#Mineração no Estado do Amapá)

 ## Mapas
 ### Índices de Desenvolvimento e Vulnerabilidade
Índice de Desenvolvimento Humano Municipal no Estado do Amapá
(imagem de alta qualidade aqui: [IDHM/AP](https://github.com/darrennorris/ZEEAmapa/blob/main/figures/AP_mapa_IDHM.tif) )

<img src="figures/AP_mapa_IDHM.png" alt="IDHM" width="300" height="400">

Para entender melhor os valores do IDHM apresentados e tambem para facilitar o diologo entre pessoas, poderes e institutos é possivel verificar quais sao os variáveis socioeconômicas mais importantes para as mudanças durante os ultimos 30 anos.

Um diagnostico com base em modelos lineares mostrar que açoes para reduzir pobreza, reduzir desigualdade e melhorar educação sao os mais relevantes para melhorar o desenvolvimento humano no estado do Amapá. 

Especificamente, para acelarar o desenvolvimento humano no estado do Amapá, açoes devem melhorar percental de 11-13 anos com ensino fundamental completo e a renda dos 60% mais pobres.  
(imagem de alta qualidade aqui: [IDHM/AP](https://github.com/darrennorris/ZEEAmapa/blob/main/figures/AP_fig_impvars.tif) )

<img src="figures/AP_fig_impvars.png" alt="IDHM" width="450" height="500">

Primeiro passo para melhorar percental de 11-13 anos com ensino fundamental completo (e portanto educação no estado) seria aumenta a percentagem de mulheres concluindo ensino fundamental.

Variáveis socioeconômicas não existem em isolação, e com base nos dados globais mostrando a importância de educação ([Hans Rosling Religion and babies](https://www.ted.com/talks/hans_rosling_religions_and_babies/transcript?language=en)), podemos olhar as mudanças entre 1991 e 2010 de educação e maternidade em mulheres mais jovens ([WHO](https://www.who.int/news-room/fact-sheets/detail/adolescent-pregnancy), [febrasgo Gravidez na adolescencia](https://www.febrasgo.org.br/pt/noticias/item/1210-reflexoes-sobre-a-semana-nacional-de-prevencao-da-gravidez-na-adolescencia-2021)). Conforme avancas na edcação houve ume reduçao na % de maternidade em mulheres mais jovens (reduçao no % mediano e na variação nos valores entre municipios), e portanto, com avanços na educação, esperamos uma reduçao expressiva na desigualdade entre os sexos .......

(imagem de alta qualidade aqui: [maternidade/AP](https://github.com/darrennorris/ZEEAmapa/blob/main/figures/AP_fig_muledu.tif) )

<img src="figures/AP_fig_muledu.png" alt="maternidade" width="450" height="350">

 ## Mineração no Estado do Amapá
Espera-se que as tensões entre mineração e desenvolvimento sustentavel se intensifiquem à medida que as populações humanas crescem e as tecnologias avançam. No entanto, a mineração também pode ser um meio de financiar caminhos alternativos de desenvolvimento que, a longo prazo, podem trazer verios beneficios ([DDSM](https://www.gov.br/mme/pt-br/assuntos/secretarias/geologia-mineracao-e-transformacao-mineral/desenvolvimento-sustentavel-na-mineracao-1), [IISD](https://www.iisd.org/articles/how-advance-sustainable-mining)).

Mineração a escala idustrial inicio na decada de 1950 no Estado do Amapá. Depois de mais de 70 anos, um relatorio recente ([Costa 2019](http://ageamapa.ap.gov.br/docs/investinamapa/Plano-de-Mineracao.pdf)) demonstra que a exportação de bens minerais ainda é o principal gerador de receitas na balança comercial amapaense, representando aproximadamente 65% de tudo que foi exportado pelo estado em 2018 (cerca de 150 milhões de dólares (US$)).

A arrecadação atraves Compensação Financeira pela Exploração de Recursos Minerais ([CFEM](https://sistemas.anm.gov.br/arrecadacao/extra/relatorios/arrecadacao_cfem.aspx)) gerar recursos finaceiros (para os estados e municipios) destinadas a reparar os danos causados nas áreas de exploração mineral.

(imagem de alta qualidade aqui: [CFEM/AP](https://github.com/darrennorris/Amapa-socioeco/blob/main/figures/AP_fig_cfem.tif) )
<img src="figures/AP_fig_cfem.png" alt="IDHM" width="400" height="200">

Dois muncipios no estado (Vitória do Jari e Pedra Branca do Amapari) representem os muncipios com maior receitas de CFEM entre 2004 e 2021.

(imagem de alta qualidade aqui: [CFEM/MAPA/AP](https://github.com/darrennorris/Amapa-socioeco/blob/main/figures/AP_mapa_cfem.tif) )
<img src="figures/AP_mapa_cfem.png" alt="IDHM" width="380" height="250">
