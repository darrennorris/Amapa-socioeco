
#Packages
library(tidyverse)
library(readxl)
library(sf)

#IDHM
df_idhm <- readRDS("dados//IDHM_municipios.RDS")
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

# Income Bivariate (in) equality 
# https://timogrossenbacher.ch/2019/04/bivariate-maps-with-ggplot2-and-sf/
sigs <- pnud_siglas
data.frame(sigs)[which(sigs$sigla =="gini"), 'definicao']
data.frame(sigs)[which(sigs$sigla =="rdpc"), 'definicao']
df_pnud$gini # Índice de Gini 
df_pnud$rdpc # Renda per capita média