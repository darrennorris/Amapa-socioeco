
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
# Mineraçao AP. 
#https://dados.gov.br/dataset/sistema-de-informacoes-geograficas-da-mineracao-sigmine#
st_layers("vector//IBGE_Amazonia_Legal.GPKG")
st_layers("vector//ZEEAP_mineracao.GPKG")

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
#Export siglas
write.csv(sigs, "dados//siglas_pnud_municipios.csv", row.names = FALSE)

#
data.frame(region_map) %>% select(Region, desc_rg) %>% 
  left_join(data.frame(uf_map) %>% select(nome, State, Region)) %>% 
  mutate(state = tolower(nome)) %>% 
  right_join(
abjData::pnud_muni %>%
  mutate(state =  tolower(ufn)) 
) %>% distinct() -> df_pnud

# Export
saveRDS(df_pnud, "dados//pnud_municipios.RDS")
write.csv(df_pnud, "dados//pnud_municipios.csv", row.names = FALSE)

df_pnud %>% 
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
  ) %>% distinct() -> df_idhm
out_cols <- c("Region", "desc_rg", "nome", "State", "state", "uf", 
              "ano", "codmun6" ,  "codmun7" , "municipio", "ufn", 
              "name", "value", "tipo", "regiao_nm" )
# Export
saveRDS(df_idhm[, out_cols], "dados//IDHM_municipios.RDS")
write.csv(df_idhm[, out_cols], "dados//IDHM_municipios.csv", row.names = FALSE)


