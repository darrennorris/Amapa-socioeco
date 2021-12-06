#Find most imortant variables to explain variation between municipios.
#I.e. variable reduciton exercise
#
#Packages
library(plyr)
library(tidyverse)
library(tidymodels)
library(readxl)
library(MuMIn) # AICc function

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
