
#Packages
library(tidyverse)
library(readxl)
library(scales)
library(sf)
library(viridis)
library(gridExtra)

#IDHM
df_idhm <- readRDS("dados//IDHM_municipios.RDS")

read_excel("dados//ZEE_AP_basedados_sig.xlsx", 
                           sheet = "IDHM_e_mais", 
                    .name_repair = "universal") %>% 
  mutate(codmun7 = as.character(codmun7)) -> df_idhm_mais

#
#Poligonos municipios Amapa
sf::st_read("vector//IBGE_Amazonia_Legal.GPKG", layer = "Mun_Amazonia_Legal_2020") %>% 
  filter(NM_UF == "Amapá") -> sf_ap_muni
#Poligon e contorno do estado do Amapá
sf_ap <- st_union(sf_ap_muni)
sf_ap <- st_sf(data.frame(CD_UF="16", geom=sf_ap))
#Lines
sf_ap_muni_line <- st_cast(sf_ap_muni, "MULTILINESTRING")

#Figures
df_idhm %>%
  ggplot(aes(value, regiao_nm)) +
  geom_boxplot(aes(fill = factor(ano))) + 
  scale_fill_discrete("Ano") +
  facet_wrap(~tipo) +
  theme_bw() +
  labs(title = "Índice de Desenvolvimento Humano Municipal",
       x = "IDHM", 
       y = "Região", 
       caption = "Fonte: Atlas do Desenvolvimento Humano (http://www.atlasbrasil.org.br, acessado 7 de Outubro 2021)"
  )  + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) -> IDHM_regiao
IDHM_regiao 
#Export
tiff("figures//IDHM_regiao.tif", width = 15, height = 15, units = "cm", res = 600,
     compression = "lzw")
IDHM_regiao + theme(text = element_text(size = 8))
dev.off()

#Municipios em Amapa
df_idhm %>% 
  filter(nome=="AMAPÁ") %>% 
  mutate(Region_label = 
           case_when(municipio %in% c("CALÇOENE", "OIAPOQUE") ~"Norte", 
                     municipio %in% c("ITAUBAL", "CUTIAS") ~"Leste", 
                     municipio %in% c("LARANJAL DO JARI", "VITÓRIA DO JARI") ~"Sul", 
                     municipio %in% c("TARTARUGALZINHO", "PRACUÚBA", "AMAPÁ") ~"Meio Norte",
                     municipio %in% c("PORTO GRANDE", "FERREIRA GOMES", 
                                      "PEDRA BRANCA DO AMAPARI", "SERRA DO NAVIO") ~"Centro",
                     municipio %in% c("MACAPÁ", "MAZAGÃO", "SANTANA") ~"Metropolitana", 
                     TRUE ~ NA_character_
           )) %>% 
  mutate(
    Region_label = fct_reorder(Region_label, value, median, .desc = TRUE)
  ) %>%
  ggplot(aes(value, Region_label)) +
  geom_boxplot(aes(fill = factor(ano))) + 
  scale_fill_discrete("Ano") +
  facet_wrap(~tipo) +
  theme_bw() +
  labs(title = "Índice de Desenvolvimento Humano Municipal no Estado do Amapá",
       x = "IDHM", 
       y = "Região do Estado", 
       caption = "Fonte: Atlas do Desenvolvimento Humano (http://www.atlasbrasil.org.br, acessado 7 de Outubro 2021)"
  )  + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) -> AP_IDHM_regiao
AP_IDHM_regiao

#export
tiff("figures//AP_IDHM_regiao.tif", width = 15, height = 12, units = "cm", res = 600,
     compression = "lzw")
AP_IDHM_regiao + theme(text = element_text(size = 8))
dev.off()


df_idhm %>% 
  filter(nome=="AMAPÁ") %>% 
  mutate(Region_label = 
           case_when(municipio %in% c("CALÇOENE", "OIAPOQUE") ~"Norte", 
                     municipio %in% c("ITAUBAL", "CUTIAS") ~"Leste", 
                     municipio %in% c("LARANJAL DO JARI", "VITÓRIA DO JARI") ~"Sul", 
                     municipio %in% c("TARTARUGALZINHO", "PRACUÚBA", "AMAPÁ") ~"Meio Norte",
                     municipio %in% c("PORTO GRANDE", "FERREIRA GOMES", 
                                      "PEDRA BRANCA DO AMAPARI", "SERRA DO NAVIO") ~"Centro",
                     municipio %in% c("MACAPÁ", "MAZAGÃO", "SANTANA") ~"Metropolitana", 
                     TRUE ~ NA_character_
           )) %>% 
  ggplot(aes(x = ano, y = value, colour = tipo)) + 
  geom_point() + stat_smooth(method = "lm", se = FALSE) + 
  facet_wrap(~municipio) + 
  scale_color_discrete("Dimensão") + 
  theme_bw() +
  labs(title = "Índice de Desenvolvimento Humano Municipal no Estado do Amapá",
       x = "Ano", 
       y = "IDHM", 
       caption = "Fonte: Atlas do Desenvolvimento Humano (http://www.atlasbrasil.org.br, acessado 7 de Outubro 2021)"
  )  + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) -> AP_IDHM_municipio
AP_IDHM_municipio

#Export
tiff("figures//AP_IDHM_municipio.tif", width = 15, height = 12, units = "cm", res = 600,
     compression = "lzw")
AP_IDHM_municipio + theme(text = element_text(size = 8))
dev.off()  

# IDHM mapas
sf_ap_muni %>% left_join(
  df_idhm %>% 
    filter(nome=="AMAPÁ") %>% 
    mutate(codmun7 = as.character(codmun7), 
           Region_label = 
             case_when(municipio %in% c("CALÇOENE", "OIAPOQUE") ~"Norte", 
                       municipio %in% c("ITAUBAL", "CUTIAS") ~"Leste", 
                       municipio %in% c("LARANJAL DO JARI", "VITÓRIA DO JARI") ~"Sul", 
                       municipio %in% c("TARTARUGALZINHO", "PRACUÚBA", "AMAPÁ") ~"Meio Norte",
                       municipio %in% c("PORTO GRANDE", "FERREIRA GOMES", 
                                        "PEDRA BRANCA DO AMAPARI", "SERRA DO NAVIO") ~"Centro",
                       municipio %in% c("MACAPÁ", "MAZAGÃO", "SANTANA") ~"Metropolitana", 
                       TRUE ~ NA_character_
             )), 
  by = c("CD_MUN" = "codmun7")
) -> sf_ap_idhm

sf_ap_idhm %>% 
  ggplot() + 
  geom_sf(data = sf_ap, colour = "black", size=1.5) +
  geom_sf(aes(fill = value)) + 
  geom_sf(data = sf_ap_muni_line, aes(colour = NM_UF), size=0.5, show.legend = "line") +
  scale_colour_manual(name = "Municipíos     ", values = ("Amapá"="grey80"), labels = NULL) +
  scale_fill_viridis_c("IDHM") + 
  scale_x_continuous(breaks = seq(-55, -49.8, by = 2)) +
  facet_grid(tipo~ano) + 
  theme_bw() +
  labs(title = "Índice de Desenvolvimento Humano Municipal no Estado do Amapá", 
       subtitle = "Valores por município (indice geral e tres dimensões)",
       x="", y="",
       caption = "Fonte: Instituto Brasileiro de Geografia e Estatística (Municípios da Amazônia Legal 2020, acessado 7 de Outubro 2021), 
       Atlas do Desenvolvimento Humano (http://www.atlasbrasil.org.br, acessado 7 de Outubro 2021), 
       PROJEÇÃO: POLICÔNICA, Meridiano Central : -54° W.Gr., Sistema de Referência: SIRGAS2000") +
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) + 
  theme(text = element_text(size = 18)) -> AP_mapa_IDHM
AP_mapa_IDHM

#Export
tiff("figures//AP_mapa_IDHM.tif", width = 15, height = 20, units = "cm", res = 600,
     compression = "lzw")
AP_mapa_IDHM + theme(text = element_text(size = 8))
dev.off() 

png(file = "figures//AP_mapa_IDHM.png", bg = "white", type = c("cairo"), 
    width=3000, height=4000, res = 600)
AP_mapa_IDHM + theme(text = element_text(size = 8))
dev.off()

save.image("~/ZEE_socioeco/ZEEAmapa/prep_dados.RData")

#Educaçao e maternidade
#Objects from AP_socioeco_importan.R
load("~/ZEE_socioeco/ZEEAmapa/AP_socioeco_importance.RData")
sf_ap_muni %>% right_join(df_Ap_mul_edu %>% 
                            mutate(codmun7 = as.character(codmun7)), 
                          by = c("CD_MUN"="codmun7")) -> sf_mat_edu

sf_mat_edu %>% 
  filter(Idade == "10 a 14 anos") %>% 
  ggplot() + 
  geom_sf(aes(fill = `Percentual de mulheres que tiveram filhos`)) + 
  scale_x_continuous(breaks = seq(-55, -49.8, by = 2)) +
  facet_wrap(~ano) + 
  theme_bw()

sf_mat_edu %>% 
  filter(Idade == "15 a 17 anos") %>% 
  ggplot() + 
  geom_sf(aes(fill = `Percentual de mulheres que tiveram filhos`)) + 
  scale_x_continuous(breaks = seq(-55, -49.8, by = 2)) + 
  scale_fill_viridis_c("Percentual de mulheres\nque tiveram filhos") +
  facet_wrap(~ano) + 
  theme_bw() + 
  labs(title = "Maternidade  no Estado do Amapá", 
       subtitle = "Mulheres de 15 a 17 anos",
       x="", y="",
       caption = "Fonte: Atlas do Desenvolvimento Humano: http://www.atlasbrasil.org.br/ (acessado 3 de Dezembro 2021),
       Instituto Brasileiro de Geografia e Estatística (Municípios da Amazônia Legal 2020, acessado 7 de Outubro 2021), 
       PROJEÇÃO: POLICÔNICA. Meridiano Central: -54° W.Gr.Sistema de Referência: SIRGAS2000") + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0), 
        text = element_text(size = 8))   + 
  theme(legend.key.width = unit(0.5,"cm"), 
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(0,0,0,0)) -> mapa_maternidade_15a17
#
#Export
tiff("figures//AP_mapa_maternidade_15a17.tif", 
     width = 15, height = 8, units = "cm", res = 600, compression = "lzw")
mapa_maternidade_15a17
dev.off()

png(file = "figures//AP_mapa_maternidade_15a17.png", bg = "white", type = c("cairo"), 
    width=3000, height=2000, res = 600)
mapa_maternidade_15a17 + theme(text = element_text(size = 8))
dev.off()

# melhores municipios ??
df_mulsum %>% filter(ano == 2010, Idade_escola == "18 anos ou mais") %>% 
  pull(`Percentual de mulheres que tiveram filhos`) -> mat_med_2010_15a17
subt_label_mat15a17 <- paste("Mulheres de 15 a 17 anos.\nTons de magenta representam valores acima do mediano em 2010 (", 
                    round(mat_med_2010_15a17,1), "%) ", "\ne tons de verde valores abaixo.", 
                    sep = "")
subt_label_mat15a17

sf_mat_edu %>% 
  filter(Idade == "15 a 17 anos") %>% 
  ggplot() + 
  geom_sf(aes(fill = `Percentual de mulheres que tiveram filhos`)) + 
  scale_x_continuous(breaks = seq(-55, -49.8, by = 2)) + 
  scale_fill_gradient2("Percentual de mulheres\nque tiveram filhos", 
                       low = "green", mid = "white",
                       high = muted("magenta"),
                       midpoint = mat_med_2010_15a17) +
  facet_wrap(~ano) + 
  theme_bw() + 
  labs(title = "Maternidade no Estado do Amapá", 
       subtitle = subt_label_mat15a17,
       x="", y="",
       caption = "Fonte: Atlas do Desenvolvimento Humano: http://www.atlasbrasil.org.br/ (acessado 3 de Dezembro 2021),
       Instituto Brasileiro de Geografia e Estatística (Municípios da Amazônia Legal 2020, acessado 7 de Outubro 2021), 
       PROJEÇÃO: POLICÔNICA. Meridiano Central: -54° W.Gr.Sistema de Referência: SIRGAS2000") + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0), 
        text = element_text(size = 8))   + 
  theme(legend.key.width = unit(0.5,"cm"), 
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(0,0,0,0)) -> AP_mapa_maternidade_mediano_15a17

#Export
tiff("figures//AP_mapa_maternidade_mediano_15a17.tif", 
     width = 15, height = 8, units = "cm", res = 600, compression = "lzw")
AP_mapa_maternidade_mediano_15a17
dev.off()

png(file = "figures//AP_mapa_maternidade_mediano_15a17.png", bg = "white", type = c("cairo"), 
    width=3000, height=2000, res = 600)
AP_mapa_maternidade_mediano_15a17 + theme(text = element_text(size = 8))
dev.off()

#Mineracao
#CFEM Compensação Financeira pela Exploração de Recursos Minerais 
#https://sistemas.anm.gov.br/arrecadacao/extra/Relatorios/arrecadacao_cfem_substancia.aspx

sf_ap_muni %>% right_join(
(df_idhm_mais %>% filter(!is.na(per_cfem)) %>% 
  select(ano, codmun7, per_cfem)), by = c("CD_MUN"="codmun7")) -> sf_cfem

sf_cfem %>% 
  mutate(per_cfem = ifelse(per_cfem ==0,NA, per_cfem)) %>%
  ggplot() + 
  geom_sf(aes(fill = per_cfem)) + 
  scale_x_continuous(breaks = seq(-55, -49.8, by = 2)) +
  facet_wrap(~ano) + 
  theme_bw() + 
  #scale_fill_viridis_c("CFEM %", trans = "log", labels =comma_format(accuracy = 1)) 
  scale_fill_gradient2("CFEM %", low = muted("magenta"),  mid = "white",  
                       high = muted("blue"),  midpoint = 2, na.value = "grey80") + 
  labs(title = "Distribuição de Compensação Financeira pela Exploração de\nRecursos Minerais no Estado do Amapá", 
       subtitle = "Percentagem arrecadado por decada",
       x="", y="",
       caption = "Fonte: Agência Nacional de Mineração (acessado 3 de Dezembro 2021),
       Instituto Brasileiro de Geografia e Estatística (Municípios da Amazônia Legal 2020, acessado 7 de Outubro 2021), 
       PROJEÇÃO: POLICÔNICA. Meridiano Central: -54° W.Gr.Sistema de Referência: SIRGAS2000") + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0), 
        text = element_text(size = 8))   + 
  theme(legend.key.width = unit(0.5,"cm"), 
        legend.margin=margin(0,0,0,0),
        legend.box.margin=margin(0,0,0,0)) -> AP_mapa_cfem
AP_mapa_cfem

#Export
tiff("figures//AP_mapa_cfem.tif", width = 15, height = 8, units = "cm", res = 600,
     compression = "lzw")
AP_mapa_cfem
dev.off()

png(file = "figures//AP_mapa_cfem.png", bg = "white", type = c("cairo"), 
    width=3000, height=2000, res = 600)
AP_mapa_cfem + theme(text = element_text(size = 8))
dev.off()

# Processos
st_layers("vector//ZEEAP_mineracao.GPKG")

#Poligonos municipios Amapa
sf::st_read("vector//ZEEAP_mineracao.GPKG", layer = "sigmine_AP_2021_poligonos") -> sf_ap_mine

sf::st_read("vector//ZEEAP_mineracao.GPKG", layer = "sigmine_AP_2021_municipio_poligonos") -> sf_ap_mine_muni
table(sf_ap_mine_muni$NM_MUN)
# Fases com arrecadação de 
# contribuição financeira pelo aproveitamento econômico de bens minerais -CFEM
fases <- unique(sf_ap_mine$FASE)
fase_cfem <- c("CONCESSÃO DE LAVRA", 
               "LAVRA GARIMPEIRA", 
               "LICENCIAMENTO",
               "REGISTRO DE EXTRAÇÃO")
fase_cfem_lower <- tolower(fase_cfem)

# Fases de aprovaçao 1 - 5 anos
fase_aprov <- c("DIREITO DE REQUERER A LAVRA", 
                "REQUERIMENTO DE LAVRA GARIMPEIRA", 
                "REQUERIMENTO DE REGISTRO DE EXTRAÇÃO", 
                "REQUERIMENTO DE LAVRA", 
                     "REQUERIMENTO DE LICENCIAMENTO")
fase_aprov_lower <- tolower(fase_aprov)

# Fase de planejamento 5 - 10 anos
fase_planej <- fases[-which(fases %in% c(fase_cfem, fase_aprov))]
fase_planej_lower <- tolower(fase_planej)

df_mineraçao_municipio %>% filter(FASE_label == "pesquisa") %>% 
  group_by(FASE) %>% summarise(acount = n()) -> df_fasepesquisa
fase_pesquisa_lower <- tolower(df_fasepesquisa$FASE)

#Distributions of processes
sf_ap_min %>%  
  mutate(FASE_label = if_else(FASE %in% fase_exploracao, "extração", "pesquisa")) %>%
  #filter(!SUBS == "DADO NÃO CADASTRADO") %>%
  group_by(PROCESSO) %>%
  ggplot() + 
  geom_sf(data = sf_ap, colour = "black", size=2) +
  geom_sf(data = sf_ap_muni, fill="grey70") +
  geom_sf(data = sf_ap_muni_line, aes(colour = NM_UF), size=0.5, show.legend = "line") +
  geom_sf(aes(fill = NM_UF), colour = "orange") +
  facet_wrap(~FASE_label) + 
  scale_colour_manual(name = "Municipíos", values = ("Amapá"="grey80"), labels = NULL) +
  scale_fill_manual(name = "Processo", values = ("Amapá"="yellow"), labels = NULL) +
  annotation_scale(location = "br", width_hint = 0.3, text_cex = 0.5) + 
  annotation_north_arrow(which_north = "true",  
                         height = unit(0.9, "cm"), width = unit(0.9, "cm"), 
                         location = "tr",) +
  geom_sf_label(label="PROJEÇÃO: POLICÔNICA\nMeridiano Central : -54° W.Gr.\nSistema de Referência: SIRGAS2000", 
                x=-54,  y=-1.1,
                #size = 3, #for .png
                size = 1,
                #label.padding = unit(0.55, "lines"), # Rectangle size around label. For .png
                label.padding = unit(0.4, "lines"),
                label.size = 0.25,
                color = "black",
                fill="white"
  ) +
  theme_bw() + 
  labs(title = "Localização de processos minerários ativos no estado do Amapá",
       subtitle = paste("Fases extração: ", toString(fase_exploracao_lower[c(7,8,1,3)]),",", 
                        "\n", toString(fase_exploracao_lower[c(2,4,5,6)]),".\n", 
                        "Fases pesquisa: ", toString(fase_pesquisa_lower[1:3]),",", 
                        "\n", toString(fase_pesquisa_lower[4:5]),".", sep = ""),
       x="", y="",
       caption = "Fonte: Agência Nacional de Mineração (Sistema de Informações Geográficas da Mineração, acessado 8 de Outubro 2021),
       Instituto Brasileiro de Geografia e Estatística (Municípios da Amazônia Legal 2020, acessado 7 de Outubro 2021)") + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) + 
  theme(text = element_text(size = 18))  + 
  theme(legend.key.width = unit(1,"cm")) -> AP_mapa_minero_poligonos

# Income Bivariate (in) equality 
# https://timogrossenbacher.ch/2019/04/bivariate-maps-with-ggplot2-and-sf/
sigs <- pnud_siglas
data.frame(sigs)[which(sigs$sigla =="gini"), 'definicao']
data.frame(sigs)[which(sigs$sigla =="rdpc"), 'definicao']
df_pnud$gini # Índice de Gini 
df_pnud$rdpc # Renda per capita média