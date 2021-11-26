
#Packages
library(tidyverse)
library(readxl)
library(sf)
library(units)
#remotes::install_github("rpradosiqueira/brazilmaps")
library(brazilmaps)
# Índice de Desenvolvimento Humano dos municípios, 
# coletados a partir do Atlas do Desenvolvimento Humano pela Associação Brasileira de Jurimetria
# remotes::install_github("abjur/abjData")
library(abjData) # dados do IBGE compilados pela Associação Brasileira de Jurimetria

Sys.setlocale("LC_TIME", "C") 

# Camadas
# GPKG com uma copia de arquivos (shapefiles) de IBGE Amazonia Legal 2020
#https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/15819-amazonia-legal.html?=&t=acesso-ao-produto

st_layers("vector//IBGE_Amazonia_Legal.GPKG")

#Poligonos municipios Amapa
sf::st_read("vector//IBGE_Amazonia_Legal.GPKG", layer = "Mun_Amazonia_Legal_2020") %>% 
  filter(NM_UF == "Amapá") -> sf_ap_muni
#Projection para calculos de area (consistentes com os dados do IBGE 2020)
## South_America_Albers_Equal_Area_Conic
st_transform(sf_ap_muni, 
             "+proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs") %>%
  st_area() -> sf_ap_muni$area_m2 

#Poligon e contorno do estado do Amapá
sf_ap <- st_union(sf_ap_muni)
sf_ap <- st_sf(data.frame(CD_UF="16", geom=sf_ap))
#Lines
sf_ap_muni_line <- st_cast(sf_ap_muni, "MULTILINESTRING")


# IDH por municipio
uf_map <- get_brmap("State")
glimpse(uf_map)
region_map <- get_brmap("Region")
glimpse(region_map)
glimpse(pnud_muni) #16695 rows
sigs <- pnud_siglas
#
data.frame(region_map) %>% select(Region, desc_rg) %>% 
  left_join(data.frame(uf_map) %>% select(nome, State, Region)) %>% 
  mutate(state = tolower(nome)) %>% 
  right_join(
abjData::pnud_muni %>%
  mutate(state =  tolower(ufn)) 
) %>% 
  pivot_longer(starts_with("idhm")) %>% 
  mutate(tipo = case_when(
    name == "idhm" ~ "Geral",
    name == "idhm_e" ~ "Educação",
    name == "idhm_l" ~ "Longevidade",
    name == "idhm_r" ~ "Renda"
  )) %>% 
  mutate(
    regiao_nm = fct_reorder(desc_rg, value, median, .desc = TRUE),
    tipo = lvls_reorder(tipo, c(2, 1, 3, 4))
  ) %>% distinct() -> df_pnud

df_pnud %>%
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
tiff("IDHM_regiao.tif", width = 15, height = 15, units = "cm", res = 600,
     compression = "lzw")
IDHM_regiao + theme(text = element_text(size = 8))
dev.off()

#Municipio em Amapa
df_pnud %>% 
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
tiff("AP_IDHM_regiao.tif", width = 15, height = 12, units = "cm", res = 600,
     compression = "lzw")
AP_IDHM_regiao + theme(text = element_text(size = 8))
dev.off()

# 
df_pnud %>% 
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

tiff("AP_IDHM_municipio.tif", width = 15, height = 12, units = "cm", res = 600,
     compression = "lzw")
AP_IDHM_municipio + theme(text = element_text(size = 8))
dev.off()  

# IDHM mapas
sf_ap_muni %>% left_join(
df_pnud %>% 
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
tiff("AP_mapa_IDHM.tif", width = 15, height = 20, units = "cm", res = 600,
     compression = "lzw")
AP_mapa_IDHM + theme(text = element_text(size = 8))
dev.off() 

png(file = "AP_mapa_IDHM.png", bg = "white", type = c("cairo"), 
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
