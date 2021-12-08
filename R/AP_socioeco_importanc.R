#Find most imortant variables to explain variation between municipios.
#I.e. variable reduciton exercise
#
#Packages
library(tidyverse)
library(tidymodels)
library(readxl)
library(MuMIn) # AICc function
library(knitr)
library(kableExtra)

sigbase <- "dados\\ZEE_AP_basedados_sig.xlsx"
df_se <- read_excel(sigbase, sheet = "IDHM_e_mais", 
                    .name_repair = "universal", na = c("", "NA")) %>% 
  filter(ano %in% c(1991, 2000, 2010))

siglas <- "dados\\siglas_pnud_municipios.xlsx"
df_siglas <- read_excel(siglas, sheet = "siglas_pnud_municipios", 
                        .name_repair = "universal", na = c("", "NA"))

# Check and drop columns with missing data
colnames(df_se)[!complete.cases(t(df_se))]
names(df_se)[sapply(df_se, anyNA)]

social_indexes <- c("i_escolaridade", "i_freq_prop","idhm", "idhm_e", 
                    "idhm_l", "idhm_r", "gini")
social_indexes_use <- c("idhm", "idhm_e", "idhm_l", "idhm_r", "gini")
place_names <- c("Region", "desc_rg", "nome", "State", "state" , 
                 "uf", "ufn", "ano", "codmun6" , "codmun7", "municipio")
not_now <- colnames(df_se)[!complete.cases(t(df_se))]
# 172 variables
df_se %>% 
  select(-c(all_of(social_indexes), all_of(place_names), all_of(not_now))) -> df_se_vars

# Run all models and get summary as tidy object
id_col <-"municipio"
response_col = "i_escolaridade"
explanatory_col = names(df_se_vars)

df_se %>% 
  select(c(id_col, "ano", social_indexes_use, explanatory_col)) %>% 
  pivot_longer(cols = c(social_indexes_use), names_to = "response_name", 
               values_to = "response_val") -> dfmodel
#adapt from https://www.tidymodels.org/learn/develop/broom/ to add AICc
myglance.lm <- function(x, ...) {
  with(
    summary(x),
    tibble::tibble(
      r.squared = r.squared,
      adj.r.squared = adj.r.squared,
      sigma = sigma,
      statistic = fstatistic["value"],
      p.value = pf(
        fstatistic["value"],
        fstatistic["numdf"],
        fstatistic["dendf"],
        lower.tail = FALSE
      ),
      df = fstatistic["numdf"],
      logLik = as.numeric(stats::logLik(x)),
      AIC = stats::AIC(x),
      AICc = MuMIn::AICc(x),
      BIC = stats::BIC(x),
      deviance = stats::deviance(x),
      df.residual = df.residual(x),
      nobs = stats::nobs(x)
    )
  )
}

#Run models
dfmodel %>%
  pivot_longer(cols = c(explanatory_col), 
               names_to = "explain_name", values_to = "explain_value") %>% 
  #filter(explain_name =="espvida")  %>%
  nest(data = -c(response_name, explain_name)) %>% 
  mutate(
    fit = map(data, ~ lm(response_val ~ explain_value, data = .x)),
    tidied = map(fit, tidy), 
    glanced = map(fit, myglance.lm)
  ) -> regressions
regressions

#combine both "tidied" and "glanced" (univariate models)
# Variable summary. Hack to pull together summaries for these univariate models
regressions %>%
  unnest(tidied) %>% 
  filter(term != '(Intercept)') %>% 
  left_join(regressions %>% 
              unnest(glanced), 
            by = c("response_name" = "response_name", "explain_name" = "explain_name", 
                   "data" = "data", "fit" = "fit") 
  ) -> df_regression_out

# Compare based on two complementary forms of evidence.
# R2 and 
# difference in AIC (up to five closest when there are multiple R2 > 0.9)
df_regression_out %>% 
  select(response_name, explain_name, estimate, r.squared, AIC) %>%
  group_by(response_name) %>% 
  arrange(response_name, AIC) %>% 
  mutate(aic_diff = AIC-min(AIC, na.rm = TRUE)) %>% 
  ungroup() %>% 
  group_by(response_name) %>% 
  mutate(aic_rank = rank(aic_diff)) %>% ungroup() %>% 
  mutate(aic_flag = factor(ifelse(aic_rank == 1, 1, 0))) %>%
  filter(r.squared > 0.9, aic_rank <= 5) -> df_best_vars

#best for each
df_best_vars %>% filter(aic_flag == 1)

df_best_vars %>% 
  left_join(df_siglas, by = c("explain_name" = "sigla")) -> df_best_vars
unique(df_best_vars$response_name)
df_best_vars %>% 
  mutate(nome_curto = str_wrap(nome_curto, 30), 
         tipo = case_when(
           response_name == "idhm" ~ "IDHM Geral",
           response_name == "idhm_e" ~ "IDHM Educação",
           response_name == "idhm_l" ~ "IDHM Longevidade",
           response_name == "idhm_r" ~ "IDHM Renda", 
           response_name == "gini" ~ "Coeficiente\nde Gini"
         )) %>%
  ggplot(aes(x = nome_curto, y = r.squared)) +
  geom_point(aes(shape = aic_flag), size = 4, colour = "black") +
  geom_point(aes(shape = aic_flag, colour = estimate), size=3.8) + 
  facet_wrap(~tipo, scales = "free_y", ncol = 2) + 
  coord_flip() + 
  scale_y_continuous(breaks = c(0.9, 0.95, 1), labels = c(0.9, 0.95, 1)) +
  scale_colour_gradient2("coeficiente\n(modelo linear)") + 
  scale_shape_discrete("AIC\n", labels = c("outros", "melhor")) + 
  labs(title = "Importância de variáveis socioeconômicas no estado do Amapá", 
       subtitle = "Variáveis mais importantes em relação aos índices nacionais:\nÍndice de Desenvolvimento Humano Municipal e Gini\nComparando direção (coeficiente) e importância (melhor [menor valor de] AIC e R2 > 0,9)",
       caption = "Fonte: Atlas do Desenvolvimento Humano: http://www.atlasbrasil.org.br/",
       x = "", 
       y = "") + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) + 
  theme(legend.position="top") + 
  guides(shape = guide_legend(title.position = "top", reverse=TRUE), 
         colour = guide_colorbar(title.position = "top")) -> AP_fig_impvars
AP_fig_impvars

#Export
tiff("figures//AP_fig_impvars.tif", width = 14, height = 20, units = "cm", res = 600,
     compression = "lzw")
AP_fig_impvars + theme(text = element_text(size = 8))
dev.off()

png(file = "figures//AP_fig_impvars.png", bg = "white", type = c("cairo"), 
    width=4000, height=5000, res = 600)
AP_fig_impvars + theme(text = element_text(size = 8))
dev.off()

# 
# t_fund11a13 11-13 anos com ensino fundamental e 
# pren60 a renda dos 60% mais pobres.
cor.test(df_se_vars$pren60, df_se_vars$t_fund11a13)
plot(df_se_vars$pren60, df_se_vars$t_fund11a13)

cor_pren60 <- round(cor(df_se_vars), 2)[, 'pren60']
cor_t_fund11a13 <- round(cor(df_se_vars), 2)[, 't_fund11a13']
df_pren60 <- data.frame(cor_pren60) 
df_pren60$cor_vars <- row.names(df_pren60)
df_t_fund11a1 <- data.frame(cor_t_fund11a13) # 172
df_t_fund11a1$cor_vars <- row.names(df_t_fund11a1)

#export html -> copy html to https://www.tablesgenerator.com/markdown_tables
df_pren60 %>% 
  filter(cor_pren60 > 0.8, cor_pren60 < 1.0) %>% 
  left_join(df_siglas, by = c("cor_vars" = "sigla")) %>% 
  arrange(desc(cor_pren60)) %>%
  mutate(nome = str_wrap(nome_curto, 30), 
         correlação = cor_pren60) %>%
  select(correlação, nome) %>% 
  kbl() %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed")) -> table_cor_pren60

table_cor_pren60 %>%
  save_kable(file = "dados//tables//table_cor_pren60.html", self_contained = T)

df_t_fund11a1 %>% 
  filter(cor_t_fund11a13 > 0.8, cor_t_fund11a13 < 1.0) %>% 
  left_join(df_siglas, by = c("cor_vars" = "sigla")) %>% 
  arrange(desc(cor_t_fund11a13)) %>%
  mutate(nome = str_wrap(nome_curto, 30), 
         correlação = cor_t_fund11a13) %>%
  select(correlação, nome) %>% 
  kbl() %>%
  kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  scroll_box(width = "500px", height = "200px") %>%
  save_kable(file = "dados//tables//table_cor_t_fund11a13.html", self_contained = T)


#Educação e gravidez
#best for each
df_best_vars %>% filter(aic_flag == 1) %>% pull(nome_curto)
# t_m10a14cf Percentual de mulheres de 10 a 14 anos de idade que tiveram filhos
# t_m15a17cf Percentual de mulheres de 15 a 17 anos de idade que tiveram filhos
# t_fund18m  "% de 18 anos ou mais com fundamental completo" 
# t_fund11a13 "% de 11 a 13 anos nos anos finais do fundamental ou com fundamental completo"
vars_mul_edu <- c("t_m10a14cf", "t_m15a17cf", "t_fund18m", "t_fund11a13")
resp_vars_mul_edu <- c("t_fund18m", "t_fund11a13")
exp_vars_mul_edu <- c("t_m10a14cf", "t_m15a17cf")

df_se %>% select(c(id_col, "ano", "t_fund11a13", "t_m10a14cf")) %>% 
  mutate(Idade = "10 a 14 anos", 
         Idade_escola = "11 a 13 anos",
          "Percentual de mulheres que tiveram filhos" = t_m10a14cf,
         "Percentual com fundamental completo" = t_fund11a13) %>% 
  bind_rows(
df_se %>% select(c(id_col, "ano", "t_fund18m", "t_m15a17cf")) %>% 
  mutate(Idade = "15 a 17 anos", 
         Idade_escola = "18 anos ou mais",
         "Percentual de mulheres que tiveram filhos" = t_m15a17cf,
         "Percentual com fundamental completo" = t_fund18m)) -> df_Ap_mul_edu

#Plot
# to do - make point shapes to show regions?
df_Ap_mul_edu %>% group_by(ano, Idade_escola) %>% 
  summarise("Percentual de mulheres que tiveram filhos" = 
              median(`Percentual de mulheres que tiveram filhos`, na.rm = TRUE), 
            "Percentual com fundamental completo" = 
              median(`Percentual com fundamental completo`), na.rm = TRUE) -> df_mulsum

df_Ap_mul_edu %>% 
  ggplot(aes(y = `Percentual de mulheres que tiveram filhos`, 
             x = `Percentual com fundamental completo`)) + 
  geom_point(colour = "black", size = 1.0) +
  geom_point(aes(y = t_m10a14cf, x = `Percentual com fundamental completo`), 
             colour = "magenta", size = 1.0) +
  geom_point(aes(colour = Idade), size = 0.8) + 
  geom_vline(data = df_mulsum, linetype = "dashed", size = 0.3,
             aes(xintercept = `Percentual com fundamental completo`)) +
  geom_hline(data = df_mulsum, linetype = "dashed", size = 0.3,
             aes(yintercept = `Percentual de mulheres que tiveram filhos`)) +
  stat_smooth(method = "gam", aes(colour = Idade), size = 0.4) + 
  scale_color_viridis_d("Idade maternidade") +
  facet_wrap(Idade_escola~ano) + 
  labs(title = "Maternidade e Educação no Estado do Amapá", 
       subtitle = "Linhas tracejadas representem valores mediano dos municipios",
       caption = "Fonte: Atlas do Desenvolvimento Humano: http://www.atlasbrasil.org.br/",
       y = "Percentual de mulheres que tiveram filhos", 
       x = "Percentual total (homens e mulheres)\nnos anos finais/com ensino fundamental completo") + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) +
  theme(legend.position="top") + 
  guides(colour = guide_legend(title.position = "top")) + 
  theme(legend.margin = margin(0, 0, 0.0, 0), 
        legend.title = element_text(size = 6),
        legend.box.spacing = unit(2, "mm"),
        legend.key.width = unit(4, 'mm'),
        legend.key.height = unit(4, 'mm'),
        legend.spacing.x = unit(1, "mm"), 
        legend.spacing.y = unit(1, "mm")) + 
  theme(strip.text = element_text(margin = margin(0, 0, 0, 0))) -> AP_fig_muledu
AP_fig_muledu

#Export
tiff("figures//AP_fig_muledu.tif", width = 10, height = 8, units = "cm", res = 600,
     compression = "lzw")
AP_fig_muledu + theme(text = element_text(size = 7))
dev.off()

png(file = "figures//AP_fig_muledu.png", bg = "white", type = c("cairo"), 
    width=4000, height=3000, res = 600)
AP_fig_muledu + theme(text = element_text(size = 11))
dev.off()

#save a copy
save.image("~/ZEE_socioeco/ZEEAmapa/AP_socioeco_importance.RData")  

#Check what is going on below!!!
df_se %>% select(c(id_col, "ano", vars_mul_edu)) %>% 

  pivot_longer(cols = c(resp_vars_mul_edu), names_to = "response_name", 
               values_to = "response_val")  %>%
  pivot_longer(cols = c(exp_vars_mul_edu), 
               names_to = "explain_name", values_to = "explain_value") %>% 
  mutate(explain_label = case_when(
    explain_name == "t_m10a14cf" ~ "10 a 14 anos",
    explain_name == "t_m15a17cf" ~ "15 a 17 anos")) %>%
  ggplot(aes(x = explain_value, y = response_val, colour = explain_label)) + 
           geom_point() + 
  stat_smooth(method = "lm") + 
  scale_color_discrete("Idade") +
  facet_wrap(response_name~ano) + 
  labs(title = "Maternidade e Educação no Estado do Amapá", 
       subtitle = "",
       caption = "Fonte: Atlas do Desenvolvimento Humano: http://www.atlasbrasil.org.br/",
       x = "Percentual de mulheres que tiveram filhos", 
       y = "Percentual com fundamental completo") + 
  theme(plot.title.position = "plot", 
        plot.caption.position = "plot", 
        plot.caption = element_text(hjust = 0)) + 
  theme(legend.position="top") + 
  guides(colour = guide_legend(title.position = "top"))
  
