#INSTALL PACKAGES
#install.packages("here")

#IMPORT LIBRARIES
library(tidyverse)
library(here)
library(dplyr)
library(janitor)
library(ggplot2)

#OPEN AND CLEAN CENSUS DATA
#clean and check column names
df_hogares <- read_csv(here("data", "raw", "Indicadores_de_hogares_radial_censo2022_caba.csv"))
df_hogares <- df_hogares %>% clean_names() 

df_personas <- read_csv(here("data", "raw", "Indicadores_de_personas_radial_censo2022_caba.csv"))
df_personas <- df_personas %>% clean_names() 

glimpse(df_hogares) 
glimpse(df_personas) 

#Eliminate unnecessary columns
df_hogares <- df_hogares |>
  select(-c(codigo_de_radio_2, nombre_de_radio, total_de_hogares_48))

df_personas <- df_personas |>
  select(-c(poblacion_total,nombre_de_radio, codigo_de_radio_2))


#TRANSFORM VARIABLES TO PERCENTAGES
df_hogares_pct <- df_hogares |>
  mutate(
    across(3:40, ~ .x / total_de_hogares_2 * 100)
  )

df_personas_pct <- df_personas |>
  mutate(
    across(3:59, ~ .x / poblacion_total_en_hogares_familiares * 100)
  )

# SAVE DATAFRAMES 
# Create the "processed" directory 
dir.create(here("data", "processed"), showWarnings = FALSE)

# Save porcentages dataframes as RDS files
write_rds(df_hogares_pct, here("data", "processed", "df_hogares_pct.rds"))
write_rds(df_personas_pct, here("data", "processed", "df_personas_pct.rds"))



