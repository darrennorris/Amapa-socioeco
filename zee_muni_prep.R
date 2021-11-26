
#Packages
library(tidyverse)
library(readxl)
library(sf)
library(units)

Sys.setlocale("LC_TIME", "C") 

# Camadas
# GPKG com uma copia de arquivos (shapefiles) de IBGE Amazonia Legal 2020
#https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/15819-amazonia-legal.html?=&t=acesso-ao-produto

st_layers("IBGE_Amazonia_Legal.GPKG")

#Poligonos municipios Amapa
sf::st_read("IBGE_Amazonia_Legal.GPKG", layer = "Mun_Amazonia_Legal_2020") %>% 
  filter(NM_UF == "Amapá") -> sf_ap_muni
#Projection para calculos de area (consistentes com os dados do IBGE 2020)
## South_America_Albers_Equal_Area_Conic
st_transform(sf_ap_muni, 
             "+proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs") %>%
  st_area() -> sf_ap_muni$area_m2 

#Poligon e contorno do estod do Amapa
sf_ap <- st_union(sf_ap_muni)
sf_ap <- st_sf(data.frame(CD_UF="16", geom=sf_ap))
#Lines
sf_ap_muni_line <- st_cast(sf_ap_muni, "MULTILINESTRING")
 

# BC250 - Base Cartográfica Contínua do Brasil - 1:250 000 - 2019
# https://portaldemapas.ibge.gov.br/portal.php#mapa222602

# Mineraçao AP
#https://dados.gov.br/dataset/sistema-de-informacoes-geograficas-da-mineracao-sigmine#
#sf_ap_min <- st_make_valid(st_read(s04)) #1084
sf_br_min <- st_make_valid(st_read(s05))
sf_br_min <- st_transform(sf_br_min, st_crs(sf_ap_muni))
sf_ap_min <- sf_br_min %>% filter(UF=="AP") #1068 e sem processo 858152/2008 (Sul do Rio Amazonas em Para = 1067
#sf_ap_min <- st_intersection(sf_br_min, sf_ap_muni) # need to correct 12 with invalid geometries

mapview(sf_ap_min)
#Add municipio
sf_ap_min_points <- st_intersection(st_centroid(sf_ap_min), sf_ap_muni)
# processes dropped with intersection of centroids....
data.frame(sf_ap_min) %>% 
left_join(
data.frame(sf_ap_min_points) %>% 
  mutate(intersect_PROCESSO = PROCESSO) %>% 
  select(PROCESSO, intersect_PROCESSO) 
) %>%
  filter(is.na(intersect_PROCESSO)) # 858152/2008
# OK . Not in Amapa
sf_ap_min_missing <- sf_ap_min %>% filter(PROCESSO == "858152/2008")
mapview(sf_ap_min_missing)

# Segue com base em poligonos cadastrados (por exemplo sem processo 858152/2008 = 1067 Processos)
sf_ap_min <- st_intersection(sf_ap_min, sf_ap_muni) 

# Com base de poligonos.
data.frame(sf_ap_min) %>% 
  group_by(SUBS, FASE) %>% 
  summarise(tot_area_ha = sum(AREA_HA, na.rm = TRUE)) %>% 
  arrange(SUBS, desc(tot_area_ha)) %>% 
  ggplot(aes(x = FASE, y = tot_area_ha)) + 
  geom_col() + facet_wrap(~SUBS)

#
data.frame(sf_br_min) %>% 
  filter(UF == "AP", PROCESSO !="858152/2008") %>%
  mutate(SUBS_simples = 
           case_when(SUBS %in% c("MINÉRIO DE OURO", "OURO", "OURO NATIVO") ~"OURO", 
                     SUBS %in% c("COBRE", "MINÉRIO DE COBRE") ~"COBRE", 
                     SUBS %in% c("MINÉRIO DE ESTANHO", "ESTANHO") ~"ESTANHO", 
                     SUBS %in% c("MINÉRIO DE FERRO", "FERRO") ~"FERRO", 
                     SUBS %in% c("MINÉRIO DE MANGANÊS", "MANGANÊS") ~"MANGANÊS", 
                     SUBS %in% c("MINÉRIO DE NIÓBIO", "NIÓBIO") ~"NIÓBIO", 
                     SUBS %in% c("MINÉRIO DE NÍQUEL", "NÍQUEL") ~"NÍQUEL", 
                     SUBS %in% c("MINÉRIO DE TÂNTALO", "TÂNTALO") ~"TÂNTALO", 
                     SUBS %in% c("ÁGUA MINERAL", "ÁGUA POTÁVEL DE MESA") ~"ÁGUA", 
                     SUBS %in% c("ARGILA", "ARGILA P/CER. VERMELH") ~"ARGILA", 
                     SUBS %in% c("ALUMÍNIO", "BAUXITA") ~"ALUMÍNIO/BAUXITA", 
                     SUBS %in% c("CASCALHO", "SEIXOS") ~"CASCALHO/SEIXOS", 
                     SUBS %in% c("AREIA", "SAIBRO") ~"AREIA/SAIBRO",
                     TRUE~ as.character(SUBS))) %>%
  filter(!SUBS == "DADO NÃO CADASTRADO") %>%
  group_by(SUBS_simples, FASE) %>% 
  summarise(tot_area_ha = sum(AREA_HA, na.rm = TRUE), 
            tot_area_km = sum(AREA_HA, na.rm = TRUE) / 100) %>% 
  arrange(SUBS_simples, desc(tot_area_km)) %>% 
  ggplot(aes(x = reorder(SUBS_simples, -tot_area_km, function(x){ sum(x) }), 
             y = tot_area_km)) + 
  geom_col() + 
  theme_bw() + 
  labs(title = "Área total dos processos minerários ativos no estado do Amapá", 
       caption = "Fonte: Agência Nacional de Mineração (Sistema de Informações Geográficas da Mineração
 acessado 8 de Outubro 2021)",
       x = "Substâncias associadas ao processo minerário", 
       y = "Area total (km^2)") +
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0),
        axis.text.x = element_text(angle = 45,  hjust=0.9))


### Agora por municipio

## South_America_Albers_Equal_Area_Conic
st_transform(sf_ap_min, 
             "+proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +y_0=0 +ellps=aust_SA +units=m +no_defs") %>%
  st_area() -> sf_ap_min$area_m2 
sf_ap_min %>%
  mutate(area_km2 = set_units(area_m2, km^2)) -> sf_ap_min

fase_exploracao <- c("CONCESSÃO DE LAVRA",   "LAVRA GARIMPEIRA", 
                     "REQUERIMENTO DE LAVRA GARIMPEIRA", "REQUERIMENTO DE REGISTRO DE EXTRAÇÃO", 
                     "REGISTRO DE EXTRAÇÃO", "REQUERIMENTO DE LAVRA", 
                     "REQUERIMENTO DE LICENCIAMENTO", "LICENCIAMENTO")

fase_exploracao_lower <- tolower(fase_exploracao)

data.frame(sf_ap_min) %>% 
  mutate(SUBS_label = 
           case_when(SUBS %in% c("MINÉRIO DE OURO", "OURO", "OURO NATIVO") ~"OURO", 
                     SUBS %in% c("COBRE", "MINÉRIO DE COBRE") ~"COBRE", 
                     SUBS %in% c("MINÉRIO DE ESTANHO", "ESTANHO") ~"ESTANHO", 
                     SUBS %in% c("MINÉRIO DE FERRO", "FERRO") ~"FERRO", 
                     SUBS %in% c("MINÉRIO DE MANGANÊS", "MANGANÊS") ~"MANGANÊS", 
                     SUBS %in% c("MINÉRIO DE NIÓBIO", "NIÓBIO") ~"NIÓBIO", 
                     SUBS %in% c("MINÉRIO DE NÍQUEL", "NÍQUEL") ~"NÍQUEL", 
                     SUBS %in% c("MINÉRIO DE TÂNTALO", "TÂNTALO") ~"TÂNTALO", 
                     SUBS %in% c("ÁGUA MINERAL", "ÁGUA POTÁVEL DE MESA") ~"ÁGUA", 
                     SUBS %in% c("ARGILA", "ARGILA P/CER. VERMELH") ~"ARGILA", 
                     SUBS %in% c("ALUMÍNIO", "BAUXITA") ~"ALUMÍNIO/BAUXITA", 
                     SUBS %in% c("CASCALHO", "SEIXOS") ~"CASCALHO/SEIXOS", 
                     SUBS %in% c("AREIA", "SAIBRO") ~"AREIA/SAIBRO",
                          TRUE~ as.character(SUBS)), 
         FASE_label = if_else(FASE %in% fase_exploracao, "extração", "pesquisa")) %>%
  filter(!SUBS == "DADO NÃO CADASTRADO") %>%
  group_by(CD_MUN, NM_MUN, AREA_TOT, PROCESSO, FASE, FASE_label, AREA_HA, SUBS, SUBS_label) %>% 
  summarise(tot_area_ha = sum(AREA_HA, na.rm = TRUE), 
            tot_area_km = sum(AREA_HA, na.rm = TRUE) / 100, 
            AREA_TOT = max(AREA_TOT)) %>%
  mutate(area_per = (tot_area_km / AREA_TOT) *100, 
         Region_label = 
           case_when(NM_MUN %in% c("Calçoene", "Oiapoque") ~"Norte", 
                     NM_MUN %in% c("Itaubal", "Cutias") ~"Leste", 
                     NM_MUN %in% c("Laranjal do Jari", "Vitória do Jari") ~"Sul", 
                     NM_MUN %in% c("Tartarugalzinho", "Pracuúba", "Amapá") ~"Meio Norte",
                     NM_MUN %in% c("Porto Grande", "Ferreira Gomes", 
                                   "Pedra Branca do Amapari", "Serra do Navio") ~"Centro",
                     NM_MUN %in% c("Macapá", "Mazagão", "Santana") ~"Metropolitana", 
                     TRUE ~ NA_character_
                     )) %>% 
  arrange(NM_MUN, PROCESSO,  SUBS_label, desc(tot_area_km)) %>% 
  select(Region_label, CD_MUN, NM_MUN, AREA_TOT, PROCESSO, FASE, FASE_label, AREA_HA, SUBS, SUBS_label, 
         tot_area_ha, tot_area_km, area_per) -> df_mineraçao_municipio
  table(sf_ap_muni$NM_MUN)
df_mineraçao_municipio %>% filter(FASE_label == "pesquisa") %>% 
  group_by(FASE) %>% summarise(acount = n()) -> df_fasepesquisa
fase_pesquisa_lower <- tolower(df_fasepesquisa$FASE)
table(df_mineraçao_municipio$FASE_label)

df_mineraçao_municipio %>% 
  filter(NM_MUN =="Pracuúba", FASE_label == "exploração")

pracu <- c("858032/2018", "858041/2018", "858042/2018", "858056/2015", "858143/2012")
sf_pracu <- sf_br_min %>% filter(PROCESSO %in% pracu)
sf_pracuba <- sf_al_muni %>% filter(NM_MUN =="Pracuúba")
mapview(sf_pracuba) + mapview(sf_pracu)


df_mineraçao_municipio %>% 
  ungroup() %>%
  group_by(NM_MUN) %>% 
  summarise(numero_processos = length(unique(PROCESSO)), 
            numero_subs = length(unique(SUBS_label))) %>% 
  arrange(desc(numero_processos))

#Histogram
df_mineraçao_municipio %>% 
  ggplot(aes(x = reorder(SUBS_label, SUBS_label,
                                   function(x)-length(x)))) + 
  geom_bar(aes(fill = NM_MUN)) + 
  #facet_wrap(~FASE_label, nrow=2) + 
  facet_grid(Region_label~FASE_label, scales = "free_x") + 
  scale_fill_discrete("Município") +
  theme_bw() + 
  labs(title = "Numero de processos minerários ativos no estado do Amapá", 
       caption = "Fonte: Agência Nacional de Mineração (Sistema de Informações Geográficas da Mineração acessado 8 de Outubro 2021)", 
       subtitle = paste("Fases extração: ", toString(fase_exploracao_lower[c(7,8,1,3)]),",", 
                        "\n", toString(fase_exploracao_lower[c(2,4,5,6)]),".\n", 
                        "Fases pesquisa: ", toString(fase_pesquisa_lower[1:3]),",", 
                        "\n", toString(fase_pesquisa_lower[4:5]),".", sep = ""),
       #x = "Substâncias associadas ao processo minerário", 
       x ="",
       y = "Numero de processos") +
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0),
        axis.text.x = element_text(size = 5, angle = 60,  hjust=0.9), 
        legend.position = "bottom") -> fig_processos_municipios

tiff("fig_processos_municipios.tif", width = 16.5, height = 20, units = "cm", res = 600,
     compression = "lzw")
fig_processos_municipios + theme(text = element_text(size = 8))
dev.off()


df_mineraçao_municipio %>% 
  ggplot(aes(x = reorder(SUBS_label, -tot_area_km, function(x){ sum(x) }), 
             y = area_per)) + 
  geom_col(aes(fill = tot_area_km)) + 
  scale_fill_continuous("Area total\n(km^2)") +
  facet_wrap(~NM_MUN, scales = "free_x", ncol = 3) +
  theme_bw() + 
  labs(title = "Área total dos processos minerários ativos no estado do Amapá", 
       caption = "Fonte: Agência Nacional de Mineração (Sistema de Informações Geográficas da Mineração
 acessado 8 de Outubro 2021)",
       x = "Substâncias associadas ao processo minerário", 
       y = "Proporção do município (%)") +
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0),
        axis.text.x = element_text(angle = 45,  hjust=0.9)) -> AP_fig_min_muni
  #theme(axis.text.x = element_text(angle = 45, vjust = 0.5, hjust=0.5))

png(file = "AP_fig_min_muni.png", bg = "white", type = c("cairo"), 
    width=4000, height=9000, res = 600)
AP_fig_min_muni
dev.off()

df_mineraçao_municipio %>% 
  filter(FASE_label == "exploração") %>%
  ggplot(aes(x = reorder(SUBS_label, -tot_area_km, function(x){ sum(x) }), 
             y = area_per)) + 
  geom_col(aes(fill = tot_area_km)) + 
  scale_fill_continuous("Area total\n(km^2)") +
  facet_wrap(~NM_MUN, scales = "free_x", ncol = 4) +
  theme_bw() + 
  labs(title = "Área total dos processos minerários ativos no estado do Amapá",
       subtitle = paste("Fases:", toString(fase_exploracao[1:3]), 
                        "\n", toString(fase_exploracao[4:6]), 
                        "\n", toString(fase_exploracao[7:8])),
       caption = "Fonte: Agência Nacional de Mineração (Sistema de Informações Geográficas da Mineração
 acessado 8 de Outubro 2021)",
       x = "Substâncias associadas ao processo minerário", 
       y = "Proporção do município (%)") +
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0),
        axis.text.x = element_text(angle = 45,  hjust=0.9)) -> AP_fig_min_muni_exp

png(file = "AP_fig_min_muni_exp.png", bg = "white", type = c("cairo"), 
    width=6000, height=8000, res = 600)
AP_fig_min_muni_exp
dev.off()


# Mapas ferro e ouro
sf_ap_muni %>% left_join( 
df_mineraçao_municipio %>% 
  filter(FASE_label == "exploração", SUBS_label %in% c("OURO", "FERRO")) %>% 
  group_by(CD_MUN, NM_MUN, SUBS_label) %>% 
  summarise(processos = length(unique(PROCESSO))) %>% 
  pivot_wider(names_from = SUBS_label, values_from = processos) 
) %>% 
  mutate(OURO = replace_na(OURO, 0), 
         FERRO = replace_na(FERRO, 0)) -> sf_ap_muni
#Now add pesquisa
sf_ap_muni %>% left_join( 
  df_mineraçao_municipio %>% 
    filter(FASE_label != "exploração", SUBS_label %in% c("OURO", "FERRO")) %>% 
    group_by(CD_MUN, NM_MUN, SUBS_label) %>% 
    summarise(processos = length(unique(PROCESSO))) %>% 
    pivot_wider(names_from = SUBS_label, 
                names_glue = "{SUBS_label}_pesquisa", values_from = processos)) %>% 
  mutate(OURO_pesquisa = replace_na(OURO_pesquisa, 0), 
         FERRO_pesquisa = replace_na(FERRO_pesquisa, 0)) -> sf_ap_muni

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

tiff("AP_mapa_minero_poligonos.tif", width = 16, height = 11, units = "cm", res = 600,
     compression = "lzw")
AP_mapa_minero_poligonos + theme(text = element_text(size = 8))
dev.off()

#Plot
sf_ap_muni %>% 
  pivot_longer(cols = c("OURO", "FERRO")) %>% 
  mutate(value = if_else(value ==0,NA_real_,value)) %>%
  ggplot() + 
  #geom_sf(data = sf_ap, colour = "black", size=2, show.legend = "line") +
  geom_sf(data = sf_ap, colour = "black", size=2) +
  geom_sf(aes(fill=value)) + 
  geom_sf(data = sf_ap_muni_line, aes(colour = NM_UF), size=0.5, show.legend = "line") +
  facet_wrap(~name, nrow = 1) + 
  scale_fill_continuous("Numero de\nprocessos") + 
  scale_colour_manual(name = "Municipíos", values = ("Amapá"="grey80"), labels = NULL) +
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
  labs(title = "Numero total de processos minerários ativos no estado do Amapá",
       subtitle = paste("Fases: ", toString(fase_exploracao_lower[c(7,8,1,3)]),",", 
                        "\n", toString(fase_exploracao_lower[c(2,4,5,6)]),".", sep = ""),
       x="", y="",
       caption = "Fonte: Agência Nacional de Mineração (Sistema de Informações Geográficas da Mineração, acessado 8 de Outubro 2021),
       Instituto Brasileiro de Geografia e Estatística (Municípios da Amazônia Legal 2020, acessado 7 de Outubro 2021)") + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) + 
  theme(text = element_text(size = 18))  + 
  theme(legend.key.width = unit(1,"cm")) -> AP_mapa_minero

#png(file = "AP_mapa_minero.png", bg = "white", type = c("cairo"), 
#    width=8000, height=6500, res = 600)
#AP_mapa_minero
#dev.off()

tiff("AP_mapa_minero.tif", width = 15, height = 10, units = "cm", res = 600,
     compression = "lzw")
AP_mapa_minero + theme(text = element_text(size = 8))
dev.off()

#Plot
sf_ap_muni %>% 
  pivot_longer(cols = c("OURO_pesquisa", "FERRO_pesquisa")) %>% 
  mutate(value = if_else(value ==0,NA_real_,value), 
         name = if_else(name == "OURO_pesquisa", "OURO", "FERRO")) %>%
  ggplot() + 
  #geom_sf(data = sf_ap, colour = "black", size=2, show.legend = "line") +
  geom_sf(data = sf_ap, colour = "black", size=2) +
  geom_sf(aes(fill=value)) + 
  geom_sf(data = sf_ap_muni_line, aes(colour = NM_UF), size=0.5, show.legend = "line") +
  facet_wrap(~name, nrow = 1) + 
  scale_colour_manual(name = "Municipíos     ", values = ("Amapá"="grey80"), labels = NULL) +
  scale_fill_continuous("Numero de\nprocessos") + 
  annotation_scale(location = "br", width_hint = 0.3, text_cex = 0.5) + 
  annotation_north_arrow(which_north = "true",  
                         height = unit(0.9, "cm"), width = unit(0.9, "cm"), 
                         location = "tr",) +
  geom_sf_label(label="PROJEÇÃO: POLICÔNICA\nMeridiano Central : -54° W.Gr.\nSistema de Referência: SIRGAS2000", 
                x=-54,
                y=-1.1,
                #size = 3, #for .png
                size = 1,
                #label.padding = unit(0.55, "lines"), # Rectangle size around label. For .png
                label.padding = unit(0.4, "lines"),
                label.size = 0.25,
                color = "black",
                fill="white"
  ) +
  theme_bw() + 
  labs(title = "Numero total de processos minerários ativos no estado do Amapá",
       subtitle = paste("Fases: ", toString(fase_pesquisa_lower[1:3]),",", 
                        "\n", toString(fase_pesquisa_lower[4:5]),".", sep = ""),
       x="", y="",
       caption = "Fonte: Agência Nacional de Mineração (Sistema de Informações Geográficas da Mineração, acessado 8 de Outubro 2021),
       Instituto Brasileiro de Geografia e Estatística (Municípios da Amazônia Legal 2020, acessado 7 de Outubro 2021)") + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) + 
  theme(text = element_text(size = 18))  + 
  #guides(fill = guide_legend(order = 2),col = guide_legend(order = 1)) # no horrible 
  theme(legend.key.width = unit(1,"cm")) -> AP_mapa_minero_pesquisa

tiff("AP_mapa_minero_pesquisa.tif", width = 15, height = 10, units = "cm", res = 600,
     compression = "lzw")
AP_mapa_minero_pesquisa + theme(text = element_text(size = 8))
dev.off()

# Instituto de Pesquisa Econômica Aplicada (IPEA)
# Os dados e indicadores disponibilizados pelo IPEA podem ser acessados em http://www.ipea.gov.br/ipeageo/arquivos/bases/AP_Mun97_region.xls
excel_sheets("AP_Mun97_region.xlsx")

idh_1991 <- read_excel("AP_Mun97_region.xlsx", sheet="IDH_1991", .name_repair = "universal")
idh_2000 <- read_excel("AP_Mun97_region.xlsx", sheet="IDH_2000", .name_repair = "universal")
idh_2010 <- read_excel("AP_Mun97_region.xlsx", sheet="IDH_2010", .name_repair = "universal")
#Índice de Desenvolvimento Humano Municipal
mycols <- c("ANO","Código.do.Município", "Município", 
            "IDHM", "IDHM.Educação", "IDHM.Longevidade", "IDHM.Renda")
idhm <- rbind(idh_1991[, mycols], idh_2000[, mycols], idh_2010[, mycols]) %>% 
  mutate(CD_MUN = as.character(Código.do.Município))
#Cannot merge as codigos diferentes
unique(idhm[, 'CD_MUN'])
unique(data.frame(sf_ap_muni)[, 'CD_MUN'])   

# https://blog.curso-r.com/posts/2019-02-10-sf-miojo/
install.packages("brazilmaps")
#library(brazilmaps) # not updated
remotes::install_github("rpradosiqueira/brazilmaps")
library(brazilmaps)
uf_map <- get_brmap("State")
glimpse(uf_map)
region_map <- get_brmap("Region")
glimpse(region_map)

# https://github.com/abjur/abjData
#install.packages("remotes")
library(remotes)
remotes::install_github("abjur/abjData")
library(abjData)
glimpse(pnud_muni) #16695 rows
sigs <- pnud_siglas
#
data.frame(region_map) %>% select(Region, desc_rg) %>% 
  left_join(data.frame(uf_map) %>% select(nome, State, Region)) %>% 
  mutate(state = tolower(nome)) %>% 
  right_join(
#
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
head(df_pnud)
names(df_pnud)
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
      
tiff("IDHM_regiao.tif", width = 15, height = 15, units = "cm", res = 600,
     compression = "lzw")
IDHM_regiao + theme(text = element_text(size = 8))
dev.off()

#Municipio em Amapa
#df_pnud %>% filter(nome=="AMAPÁ") %>% group_by(municipio ) %>% summarise(acount = n())
#glimpse(df_pnud)
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

tiff("AP_mapa_IDHM.tif", width = 15, height = 20, units = "cm", res = 600,
     compression = "lzw")
AP_mapa_IDHM + theme(text = element_text(size = 8))
dev.off() 

# Income Bivariate (in) equality 
# https://timogrossenbacher.ch/2019/04/bivariate-maps-with-ggplot2-and-sf/
sigs <- pnud_siglas
data.frame(sigs)[which(sigs$sigla =="gini"), 'definicao']
data.frame(sigs)[which(sigs$sigla =="rdpc"), 'definicao']
df_pnud$gini # Índice de Gini 
df_pnud$rdpc # Renda per capita média
