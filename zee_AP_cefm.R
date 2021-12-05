
# Agência Nacional de Mineração	
# https://sistemas.anm.gov.br/arrecadacao/extra/Relatorios/arrecadacao_cfem_substancia.aspx

#Packages
library(tidyverse)
library(readxl)
library(scales)
library(sf)
library(viridis)
library(gridExtra)

dfmin <- read_excel("dados//ANM_CEFM.xlsx", sheet = "CFEM_municipios_mensal", 
                    .name_repair = "universal") 
unique(dfmin$SUBS)
dfmin %>% mutate(SUBS_simples = 
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
                   SUBS %in% c("GRANITO", "GRANITO P/ BRITA") ~"GRANITO",
                   SUBS %in% c("AREIA", "SAIBRO") ~"AREIA/SAIBRO",
                   TRUE~ as.character(SUBS))) -> dfmin
unique(dfmin$SUBS_simples)
# Substancias mais importantes?
# OURO (72.4, 58 Milhoes) e CAULIM (22.5, 18 Milhoes) = 94.9% (76 Milhoes)
dfmin %>% filter(ano_ref %in% c(2021, 2020, 2019, 2018, 2017)) %>% 
  group_by(SUBS_simples) %>% 
  summarise(total_cefm_2017_2021 = sum(Total_ano, na.rm=TRUE)) %>% 
  ungroup() %>% arrange(desc(total_cefm_2017_2021)) %>% 
  mutate(csum_cefm = cumsum(total_cefm_2017_2021)) %>% 
  mutate(per_cefm = (total_cefm_2017_2021 / max(csum_cefm)) *100, 
         cper_cefm = (csum_cefm / max(csum_cefm)) *100)

dfmin %>% mutate(SUBS_main = 
                   case_when(!(SUBS_simples %in% c( "OURO", "CAULIM", "FERRO", "CROMO", "GRANITO")) ~"outros", 
                             TRUE~ as.character(SUBS_simples))) -> dfmin

# Municipios mais importantes? 
# PEDRA BRANCA DO AMAPARI (68.0, 54.5 Milhoes) e 
# VITÓRIA DO JARI (22.2, 18 Milhoes) = 90.2% , 72.3 Milhoes
dfmin %>% filter(ano_ref %in% c(2021, 2020, 2019, 2018, 2017)) %>% 
  group_by(municipio) %>% 
  summarise(total_cefm_2017_2021 = sum(Total_ano, na.rm=TRUE)) %>% 
  ungroup() %>% arrange(desc(total_cefm_2017_2021)) %>% 
  mutate(csum_cefm = cumsum(total_cefm_2017_2021)) %>% 
  mutate(per_cefm = (total_cefm_2017_2021 / max(csum_cefm)) *100, 
         cper_cefm = (csum_cefm / max(csum_cefm)) *100)

#From 2004 - 2021 median of 12 million per year (2.5 to 22.7 million)
dfmin %>% 
  group_by(ano_ref) %>% 
  summarise(tot_ano = sum(Total_ano)) %>% pull(tot_ano) %>% summary()
#    Min.  1st Qu.   Median     Mean  3rd Qu.     Max. 
# 2523881  8185106 12439864 12761625 17318068 22704380

dfmin %>% filter(!is.na(SUBS_simples)) %>%
  group_by(ano_ref, SUBS_main) %>% 
  summarise(tot_ano = sum(Total_ano)) %>% 
  ggplot(aes(x = ano_ref, y = tot_ano)) + 
  geom_col(aes(fill = SUBS_main)) + 
  scale_y_continuous(labels = label_number(suffix = " M", scale = 1e-6)) + 
  scale_fill_viridis("Substância", discrete = TRUE) + 
  labs(title = "Compensação Financeira pela Exploração de Recursos Minerais no Estado do Amapá", 
       subtitle = "Valores arrecadados por ano (Milhões de reais)",
       x="Ano", y="CFEM",
       caption = "Fonte: Agência Nacional de Mineração, acessado 3 de Dezembro 2021") +
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0), 
        text = element_text(size = 8)) -> AP_fig_cfem
AP_fig_cfem
tiff("figures//AP_fig_cfem.tif", width = 15, height = 8, units = "cm", res = 600,
     compression = "lzw")
AP_fig_cfem
dev.off()

dfmin %>% 
  group_by(ano, ano_ref) %>% 
  summarise(tot_ano = sum(Total_ano)) %>% 
  ungroup() %>%
  group_by(ano) %>%
  summarise(count_ano = length(unique(ano_ref)),
            first_ano = min(ano_ref), 
            last_ano = max(ano_ref),
              mean_cefm = mean(tot_ano, na.rm=TRUE)) %>% 
  left_join(
dfmin %>% 
  group_by(ano,ufn, codmun7, municipio) %>% 
  summarise(total_cefm = sum(Total_ano, na.rm=TRUE)) %>% 
  ungroup() %>% 
  group_by(ano) %>% 
  arrange(ano, desc(total_cefm)) %>% 
  mutate(csum_cefm = cumsum(total_cefm)) %>% 
  mutate(per_cefm = (total_cefm / max(csum_cefm)) *100, 
         cper_cefm = (csum_cefm / max(csum_cefm)) *100, 
         codmun7 = as.character(codmun7))
) -> dfcefm

#Poligonos municipios Amapa
sf::st_read("vector//IBGE_Amazonia_Legal.GPKG", layer = "Mun_Amazonia_Legal_2020") %>% 
  filter(NM_UF == "Amapá") -> sf_ap_muni
#Poligon e contorno do estado do Amapá
sf_ap <- st_union(sf_ap_muni)
sf_ap <- st_sf(data.frame(CD_UF="16", geom=sf_ap))
#Lines
sf_ap_muni_line <- st_cast(sf_ap_muni, "MULTILINESTRING")

sf_ap_muni %>% right_join(dfcefm, by = c("CD_MUN" = "codmun7")) -> sf_cefm

sf_cefm %>% 
  mutate(per_cefm = ifelse(per_cefm ==0,NA, per_cefm)) %>%
  mutate(per_cefm_log = log1p(per_cefm)) %>% pull(per_cefm_log)

sf_cefm %>% 
  mutate(per_cefm = ifelse(per_cefm ==0,NA, per_cefm)) %>%
  ggplot() + 
  geom_sf(aes(fill = per_cefm)) + 
  scale_x_continuous(breaks = seq(-55, -49.8, by = 2)) +
  facet_wrap(~ano) + 
  theme_bw() + 
  #scale_fill_viridis_c("CFEM %", trans = "log", labels =comma_format(accuracy = 1)) 
scale_fill_gradient2("CFEM %", low = muted("magenta"),  mid = "white",  
                     high = muted("blue"),  midpoint = 2) + 
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
tiff("figures//AP_mapa_cfem.tif", width = 15, height = 8, units = "cm", res = 600,
     compression = "lzw")
AP_mapa_cfem
dev.off()

## need to do more clecer splitting to fit properly
tiff("figures//AP_cfem.tif", width = 12, height = 20, units = "cm", res = 600,
     compression = "lzw")
gridExtra::grid.arrange(AP_fig_cfem, AP_mapa_cfem, ncol = 1)
dev.off()


