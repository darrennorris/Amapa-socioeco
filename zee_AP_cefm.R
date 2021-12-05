
# Agência Nacional de Mineração	
# https://sistemas.anm.gov.br/arrecadacao/extra/Relatorios/arrecadacao_cfem_substancia.aspx

#Packages
library(tidyverse)
library(readxl)
library(scales)
library(sf)
library(viridis)
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
        plot.caption = element_text(hjust = 0))

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
  group_by(ano, municipio) %>% 
  summarise(total_cefm = sum(Total_ano, na.rm=TRUE)) %>% 
  ungroup() %>% 
  group_by(ano) %>% 
  arrange(ano, desc(total_cefm)) %>% 
  mutate(csum_cefm = cumsum(total_cefm)) %>% 
  mutate(per_cefm = (total_cefm / max(csum_cefm)) *100, 
         cper_cefm = (csum_cefm / max(csum_cefm)) *100)
) -> dfcefm
