library(osrm)
library(leaflet)
library(tidyverse)
library(tmaptools)
library(here)
library(leaflet.extras2)

location <- tibble(address = c("91 Florence Nzama Street, Durban North Beach, KwaZulu-Natal, South Africa",
                               "115 St Andrew’s Drive, Durban North, KwaZulu-Natal, South Africa",
                               "67 Boshoff Street, Pietermaritzburg, KwaZulu-Natal, South Africa",
                               "4 Paul Avenue, Empangeni, KwaZulu-Natal, South Africa",
                               "166 Kerk Street, Vryheid, KwaZulu-Natal, South Africa",
                               "9 Margaret Street, Ixopo, KwaZulu-Natal, South Africa",
                               "16 Poort Road, Ladysmith, KwaZulu-Natal, South Africa"))

location_data <- tmaptools::geocode_OSM(location$address)

locations <- location_data %>% 
  mutate(id = query) %>% 
  select(id, lon, lat)

# The code beloqw is modified from https://rpubs.com/mbeckett/running-in-circles
trip <- osrmTrip(loc = locations, osrm.profile = "car")

leaflet(data = trip[[1]]$trip) %>% 
  addTiles() %>% 
  addMarkers(lng = locations$lon, 
             lat = locations$lat, 
             popup = locations$id,
             icon = ~ icons(iconUrl = here("home.png"),
                            iconHeight = 25,
                            iconWidth = 25)) %>%
  addAntpath()
