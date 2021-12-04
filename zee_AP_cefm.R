
# Agência Nacional de Mineração	
# https://sistemas.anm.gov.br/arrecadacao/extra/Relatorios/arrecadacao_cfem_substancia.aspx

#Packages
library(tidyverse)
library(readxl)
library(sf)

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
                   SUBS %in% c("AREIA", "SAIBRO") ~"AREIA/SAIBRO",
                   TRUE~ as.character(SUBS))) -> dfmin

# Substancias mais importantes?
# OURO (72.4, 58 Milhoes) e CAULIM (22.5, 18 Milhoes) = 94.9% (76 Milhoes)
dfmin %>% filter(ano_ref %in% c(2021, 2020, 2019, 2018, 2017)) %>% 
  group_by(SUBS_simples) %>% 
  summarise(total_cefm_2017_2021 = sum(Total_ano, na.rm=TRUE)) %>% 
  ungroup() %>% arrange(desc(total_cefm_2017_2021)) %>% 
  mutate(csum_cefm = cumsum(total_cefm_2017_2021)) %>% 
  mutate(per_cefm = (total_cefm_2017_2021 / max(csum_cefm)) *100, 
         cper_cefm = (csum_cefm / max(csum_cefm)) *100)

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

dfmin %>% 
  group_by(ano, municipio) %>% 
  summarise(total_cefm = sum(Total_ano, na.rm=TRUE)) %>% 
  ungroup() %>% 
  group_by(ano) %>% 
  arrange(ano, desc(total_cefm)) %>% 
  mutate(csum_cefm = cumsum(total_cefm)) %>% 
  mutate(per_cefm = (total_cefm / max(csum_cefm)) *100, 
         cper_cefm = (csum_cefm / max(csum_cefm)) *100)
