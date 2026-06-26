#IMPORT LIBRARIES
library(tidyverse)
library(readr)

#OPEN AND EXPLORE CENSUS DATA
df_hogares <- read_csv("raw/Indicadores_de_hogares_radial_censo2022_caba.csv")
View(df_hogares)
tibble::glimpse(df_hogares)


