library(sf)
library(dplyr)
library(readr)
library(tidyr)

# ------------------------------------------------------------------------------
# 1. Cargar y filtrar localización de escuelas
# ------------------------------------------------------------------------------
escuelas_df <- read_csv("data/raw/loc_escuelas.csv") |> 
  filter(POINT_X > 0 & POINT_Y > 0) # Elimina registros sin localización válida

# Proyección oficial CABA (Transverse Mercator / Gauss-Krüger CABA en metros)
caba_crs <- "+proj=tmerc +lat_0=-34.6297166 +lon_0=-58.4627 +k=1 +x_0=100000 +y_0=100000 +ellps=intl +units=m +no_defs"

escuelas_sf <- st_as_sf(escuelas_df, coords = c("POINT_X", "POINT_Y"), crs = caba_crs)

# ------------------------------------------------------------------------------
# 2. Cargar y convertir capas censales (WKT a sf)
# ------------------------------------------------------------------------------
hogares_df <- df_hogares_pct
personas_df <- df_personas_pct

# Convertir WKT (EPSG:4326) y reproyectar al CRS métrico de CABA
radios_hogares_sf <- st_as_sfc(hogares_df$geometria_en_wkt, crs = 4326) |> 
  st_sf(hogares_df, geometry = _) |> 
  st_transform(crs = caba_crs) |> 
  mutate(area_radio_m2 = as.numeric(st_area(geometry)))

# ------------------------------------------------------------------------------
# 3. Crear Buffer de 1 km (1000 metros) alrededor de cada escuela
# ------------------------------------------------------------------------------
buffers_1km_sf <- st_buffer(escuelas_sf, dist = 1000)

# ------------------------------------------------------------------------------
# 4. Intersección espacial y cálculo de ponderadores
# ------------------------------------------------------------------------------
# Intersectar el buffer de 1km con los radios censales
interseccion <- st_intersection(buffers_1km_sf, radios_hogares_sf) |> 
  mutate(
    area_interseccion_m2 = as.numeric(st_area(geometry)),
    prop_area_radio = area_interseccion_m2 / area_radio_m2
  )

# Obtener centroides de los recortes para medir distancia exacta a la escuela
centroides_interseccion <- st_centroid(interseccion$geometry)

# Matriz/Vector de distancias entre la escuela de origen y el fragmento del radio
distancias_m <- as.numeric(st_distance(centroides_interseccion, escuelas_sf$geometry[match(interseccion$Escuela_DE, escuelas_sf$Escuela_DE)], by_element = TRUE))

interseccion <- interseccion |> 
  mutate(
    distancia_m = distancias_m,
    peso_distancia = 1 / (distancia_m + 100), # Constante de suavizado de 100m
    peso_combinado = area_interseccion_m2 * peso_distancia
  )









