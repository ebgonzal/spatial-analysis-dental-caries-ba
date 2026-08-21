library(sf)
library(dplyr)
library(readr)
library(tidyr)

# ------------------------------------------------------------------------------
# 1. Load, filter and project school locations
# ------------------------------------------------------------------------------
escuelas_df <- read_csv("data/raw/loc_escuelas.csv") |> 
  filter(POINT_X > 0 & POINT_Y > 0) # filter out records without valid location

# Projection to oficial CRS (Transverse Mercator / Gauss-Krüger CABA)
caba_crs <- "+proj=tmerc +lat_0=-34.6297166 +lon_0=-58.4627 +k=1 +x_0=100000 +y_0=100000 +ellps=intl +units=m +no_defs"
escuelas_sf <- st_as_sf(escuelas_df, coords = c("POINT_X", "POINT_Y"), crs = caba_crs)

# ------------------------------------------------------------------------------
# 2. Load and convert census layers (WKT to sf)
# ------------------------------------------------------------------------------
hogares_df <- df_hogares_pct
personas_df <- df_personas_pct

# Convert WKT to geometry and transform to CABA metric CRS
radios_hogares_sf <- st_as_sfc(hogares_df$geometria_en_wkt, crs = 4326) |> 
  st_sf(hogares_df, geometry = _) |> 
  st_transform(crs = caba_crs) |> 
  mutate(area_radio_m2 = as.numeric(st_area(geometry))) #Calculate the area of each census tract in square meters 

radios_personas_sf <- st_as_sfc(personas_df$geometria_en_wkt, crs = 4326) |> 
  st_sf(personas_df, geometry = _) |> 
  st_transform(crs = caba_crs) |> 
  mutate(area_radio_m2 = as.numeric(st_area(geometry))) #Calculate the area of each census tract in square meters 


# ------------------------------------------------------------------------------
# 3. Create Buffer of 1 km (1000 meters) around each school
# ------------------------------------------------------------------------------
buffers_1km_sf <- st_buffer(escuelas_sf, dist = 1000)

# ------------------------------------------------------------------------------
# 4. Spatial intersection and weight calculation
# ------------------------------------------------------------------------------
# Intersectar el buffer de 1km alrededor de las escuelas con los radios censales para calcular la proporción de 
# área de cada radio que cae dentro del buffer

interseccion <- st_intersection(buffers_1km_sf, radios_hogares_sf) |> 
  mutate(
    area_interseccion_m2 = as.numeric(st_area(geometry)),
    prop_area_radio = area_interseccion_m2 / area_radio_m2
  )

interseccion_2 <- st_intersection(buffers_1km_sf, radios_personas_sf) |> 
  mutate(
    area_interseccion_m2 = as.numeric(st_area(geometry)),
    prop_area_radio = area_interseccion_m2 / area_radio_m2
  )

# Obtener centroides de los recortes para medir distancia exacta a la escuela
centroides_interseccion <- st_centroid(interseccion$geometry)

centroides_interseccion_2 <- st_centroid(interseccion_2$geometry)

# Matriz/Vector de distancias entre la escuela y centroide del fragmento del radio
distancias_m <- as.numeric(st_distance(centroides_interseccion, escuelas_sf$geometry[match(interseccion$Escuela_DE, escuelas_sf$Escuela_DE)], by_element = TRUE))

distancias_m_2 <- as.numeric(st_distance(centroides_interseccion_2, escuelas_sf$geometry[match(interseccion_2$Escuela_DE, escuelas_sf$Escuela_DE)], by_element = TRUE))

interseccion_2 <- interseccion_2 |> 
  mutate(
    distancia_m = distancias_m_2,
    peso_distancia = 1 / (distancia_m + 100), # Constante de suavizado de 100m
    peso_combinado = area_interseccion_m2 * peso_distancia
  )

# ------------------------------------------------------------------------------
# 5. Agregación ponderada de variables socioambientales por escuela
# ------------------------------------------------------------------------------
df_escuelas_hogares_ponderado <- interseccion |> 
  st_drop_geometry() |> 
  group_by(Escuela_DE) |> 
  summarise(
    # 1. Conteo estimado de hogares dentro del buffer de 1 km
    total_hogares_est = sum(total_de_hogares_2 * prop_area_radio, na.rm = TRUE),
    
    # 2. Promedio ponderado espacial (Área * Distancia) para las variables en % (cols 9 a 45)
    across(
      .cols = 9:45,
      .fns = ~ sum(.x * peso_combinado, na.rm = TRUE) / sum(peso_combinado, na.rm = TRUE),
      .names = "{.col}_pond"
    ),
    
    .groups = "drop"
  )


df_escuelas_personas_ponderado <- interseccion_2 |> 
  st_drop_geometry() |> 
  group_by(Escuela_DE) |> 
  summarise(
    # 1. Conteo estimado de personas dentro del buffer de 1 km
    total_personas_est = sum(poblacion_total_en_hogares_familiares * prop_area_radio, na.rm = TRUE),
    
    # 2. Promedio ponderado espacial (Área * Distancia) para las variables en % (cols 9 a 45)
    across(
      .cols = 9:59,
      .fns = ~ sum(.x * peso_combinado, na.rm = TRUE) / sum(peso_combinado, na.rm = TRUE),
      .names = "{.col}_pond"
    ),
    
    .groups = "drop"
  )


# Guardar como RDS 
#saveRDS(df_escuelas_hogares_ponderado, "data/processed/df_escuelas_hogares_ponderado.rds")

#saveRDS(df_escuelas_personas_ponderado, "data/processed/df_escuelas_personas_ponderado.rds")



