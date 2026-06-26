#INSTALL PACKAGES
#install.packages("here")

#IMPORT LIBRARIES
library(tidyverse)
library(here)
library(dplyr)
library(janitor)
library(ggplot2)

#OPEN AND CLEAN CENSUS DATA
df_hogares <- read_csv(here("data", "raw", "Indicadores_de_hogares_radial_censo2022_caba.csv"))
df_hogares <- df_hogares %>% clean_names() #clean column names
names(df_hogares) #check column names

df_personas <- read_csv(here("data", "raw", "Indicadores_de_personas_radial_censo2022_caba.csv"))
df_personas <- df_personas %>% clean_names() #clean column names
names(df_personas) #check column names

glimpse(df_hogares) #check data structure
glimpse(df_personas) 

##############################################################################################

#TRANSFORM VARIABLES TO PERCENTAGES
#######ARREGLAR ESTE TIENE TOTAL HOGARES 2

df_hogares_pct <- df_hogares |>
  mutate(
    across(
      c(where(is.double), -all_of("total_de_hogares_2")),
      ~ .x / total_de_hogares_2 * 100
    )
  )

view(df_hogares_pct) #check data structure

df_personas_pct <- df_personas |>
  mutate(
    across(
      c(where(is.double), -all_of("poblacion_total_en_hogares_familiares")),
      ~ .x / poblacion_total_en_hogares_familiares * 100
    )
  )

view(df_personas_pct) #check data structure


#########################################################################################
#EXPLORE CENSUS DATA

# Histograms of variables "hogares"
numeric_long <- df_hogares |>
  select(where(is.double)) |>
  pivot_longer(everything(), names_to = "variable", values_to = "value")
ggplot(numeric_long, aes(x = value)) +
  geom_histogram(fill = "steelblue", color = "white", bins = 30) +
  facet_wrap(vars(variable), scales = "free", ncol = 4) +
  theme_minimal() +
  labs(
    x = NULL,
    y = "Frecuencia",
    title = "Histogramas de variables de hogares"
  )

# Histograms of variables "personas"
numeric_long <- df_personas |>
  select(where(is.double)) |>
  pivot_longer(everything(), names_to = "variable", values_to = "value")
ggplot(numeric_long, aes(x = value)) +
  geom_histogram(fill = "steelblue", color = "white", bins = 30) +
  facet_wrap(vars(variable), scales = "free", ncol = 4) +
  theme_minimal() +
  labs(
    x = NULL,
    y = "Frecuencia",
    title = "Histogramas de variables de personas"
  )
