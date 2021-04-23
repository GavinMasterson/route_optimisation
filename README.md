---
title: "Route Optimisation in KZN, South Africa"
author: "Gavin Masterson"
date: "22/04/2021"
output: 
  html_document:
    keep_md: TRUE
---



<style type="text/css">
body {
  font-size: 12pt;
}
</style>

# The Challenge

A logistics company needs to optimise their delivery routes.
They are based in Durban and deliver to between 4 and 20 locations in KwaZulu-Natal per day.
They have a single vehicle.

## My Task

Write a Python or R script to find the optimal (minimum time) route between these six locations:

1. 115 St Andrew's Drive, Durban North, KwaZulu-Natal, South Africa  
2. 67 Boshoff Street, Pietermaritzburg, KwaZulu-Natal, South Africa  
3. 4 Paul Avenue, Fairview, Empangeni, KwaZulu-Natal, South Africa  
4. 166 Kerk Street, Vryheid, KwaZulu-Natal, South Africa  
5. 9 Margaret Street, Ixopo, KwaZulu-Natal, South Africa 
6. 16 Poort Road, Ladysmith, KwaZulu-Natal, South Africa.

After scoping the task, I had two follow-up questions, which I submitted to the logistics company:  

**1. What is the address of the storage depot where the delivery van will depart from?**

I was told that the storage depot is located at 91 Florence Nzama Street, Durban North Beach, KwaZulu-Natal, South Africa.
    
**2. What is the vehicle type (or make and model) of the delivery vehicle?**

I was told that the logistics company uses a Volkswagen Transporter Panel Van for its deliveries.

![(Source: <https://www.motortrend.com/cars/ram/promaster/2017/>)](transporter-panel-van-2.png)

With this information, I can now get on to solving the problem. 

## My Solution

The specifications of the Transporter Panel Van can be found in [this brochure](transporter6-1-online-brochure.pdf).
For our optimisation task, the key specification for this vehicle is the Gross Vehicle Mass (GVM; found on page 9).
For both models of the VW Transporter, the GVM is 2800 kilograms.
This places the vehicle *below* the 3500 kilogram GVM threshold, at [which a reduced maximum speed of 100 km/h would apply](https://truckandfreight.co.za/80kmh-speed-limit-apply-trucks/#:~:text=The%2080km%2Fh%20applies%20when,100%20km%2Fh%20limit%20applies.) on South African roads.

### The Code

Now we move into `R` to begin coding our solution. 
in order to create a dataframe of source and delivery addresses, geocode each address for the mapping algorithms of the OSRM server, and then use the geocoded locations to perform an Open Source Routing Machine (OSRM) query which returns the time-optimised route for driving between our starting and delivery locations.


```r
library(osrm)
library(leaflet)
library(tidyverse)
library(tmaptools)
library(here)
library(leaflet.extras2)
```

First, we create a dataframe containing the address of the company depot and the six delivery addresses and geocode them.


```r
location <- tibble(address = c("91 Florence Nzama Street, Durban North Beach, KwaZulu-Natal, South Africa",
                              "115 St Andrew’s Drive, Durban North, KwaZulu-Natal, South Africa",
                              "67 Boshoff Street, Pietermaritzburg, KwaZulu-Natal, South Africa",
                              "4 Paul Avenue, Empangeni, KwaZulu-Natal, South Africa",
                              "166 Kerk Street, Vryheid, KwaZulu-Natal, South Africa",
                              "9 Margaret Street, Ixopo, KwaZulu-Natal, South Africa",
                              "16 Poort Road, Ladysmith, KwaZulu-Natal, South Africa"))

location_data <- tmaptools::geocode_OSM(location$address)
```

Next we visualise the result of our geocoding to ensure that there are no obvious errors in the lat-long locations.


```r
location_data %>% 
  leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = location_data$lon, 
             lat = location_data$lat,
             popup = location$address,
             icon = ~ icons(iconUrl = here("home.png"),
                          iconHeight = 25,
                          iconWidth = 25))
```

```{=html}
<div id="htmlwidget-7183fa6b0227ed374bd5" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-7183fa6b0227ed374bd5">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[[-29.8511632,-29.7891604,-29.6067926,-28.7577896,-27.7690778,-30.1570021,-28.5599144],[31.0313381,31.039216,30.3914967,31.9024575,30.7896788,30.0587332,29.7771321],{"iconUrl":{"data":"data:image/png;base64,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","index":0},"iconWidth":25,"iconHeight":25},null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},["91 Florence Nzama Street, Durban North Beach, KwaZulu-Natal, South Africa","115 St Andrew’s Drive, Durban North, KwaZulu-Natal, South Africa","67 Boshoff Street, Pietermaritzburg, KwaZulu-Natal, South Africa","4 Paul Avenue, Empangeni, KwaZulu-Natal, South Africa","166 Kerk Street, Vryheid, KwaZulu-Natal, South Africa","9 Margaret Street, Ixopo, KwaZulu-Natal, South Africa","16 Poort Road, Ladysmith, KwaZulu-Natal, South Africa"],null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-30.1570021,-27.7690778],"lng":[29.7771321,31.9024575]}},"evals":[],"jsHooks":[]}</script>
```

All of the points are within KwaZulu-Natal, South Africa, and after inspecting them to confirm that they are not spurious locations outside of the towns listed in each address, we can now move forward.
We don't need the bounding box for each point so we can drop all the `lat_*` and `lon_*` variables before sending our query to our local OSRM server.


```r
locations <- location_data %>% 
  mutate(id = query) %>% 
  select(id, lon, lat)
```

As mentioned earlier, the GVM of the delivery van does not exceed 3500 kilograms.
What this means for the optimisation task is that, in the absence of any company-specific policy on driving behaviour, we can use the default `car.lua` profile (one of the default profiles of the OSRM API).


```r
trip <- osrmTrip(loc = locations, osrm.profile = "car")
```

According to our OSRM query, the optimised order for our delivery route route is as follows:  
1. **91 Florence Nzama Street, Durban North Beach, KwaZulu-Natal, South Africa** (The Storage depot)  
2. **9 Margaret Street, Ixopo, KwaZulu-Natal, South Africa**  
3. **67 Boshoff Street, Pietermaritzburg, KwaZulu-Natal, South Africa**  
4. **16 Poort Road, Ladysmith, KwaZulu-Natal, South Africa**  
5. **166 Kerk Street, Vryheid, KwaZulu-Natal, South Africa**  
6. **4 Paul Avenue, Empangeni, KwaZulu-Natal, South Africa**  
7. **115 St Andrew’s Drive, Durban North, KwaZulu-Natal, South Africa**  

The full optimised delivery trip is expected to take **702** minutes (or 11.7 hours).

Finally, we can visualise the resulting optimised route.


```r
# Code modified from https://rpubs.com/mbeckett/running-in-circles
leaflet(data = trip[[1]]$trip) %>% 
  addTiles() %>% 
  addMarkers(lng = locations$lon, 
             lat = locations$lat, 
             popup = locations$id,
             icon = ~ icons(iconUrl = here("home.png"),
                            iconHeight = 25,
                            iconWidth = 25)) %>%
  addAntpath()
```

```{=html}
<div id="htmlwidget-af8cd1cd0c52a39ad8dc" style="width:672px;height:480px;" class="leaflet html-widget"></div>
<script type="application/json" data-for="htmlwidget-af8cd1cd0c52a39ad8dc">{"x":{"options":{"crs":{"crsClass":"L.CRS.EPSG3857","code":null,"proj4def":null,"projectedBounds":null,"options":{}}},"calls":[{"method":"addTiles","args":["//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",null,null,{"minZoom":0,"maxZoom":18,"tileSize":256,"subdomains":"abc","errorTileUrl":"","tms":false,"noWrap":false,"zoomOffset":0,"zoomReverse":false,"opacity":1,"zIndex":1,"detectRetina":false,"attribution":"&copy; <a href=\"http://openstreetmap.org\">OpenStreetMap<\/a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA<\/a>"}]},{"method":"addMarkers","args":[[-29.8511632,-29.7891604,-29.6067926,-28.7577896,-27.7690778,-30.1570021,-28.5599144],[31.0313381,31.039216,30.3914967,31.9024575,30.7896788,30.0587332,29.7771321],{"iconUrl":{"data":"data:image/png;base64,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","index":0},"iconWidth":25,"iconHeight":25},null,null,{"interactive":true,"draggable":false,"keyboard":true,"title":"","alt":"","zIndexOffset":0,"opacity":1,"riseOnHover":false,"riseOffset":250},["91 Florence Nzama Street, Durban North Beach, KwaZulu-Natal, South Africa","115 St Andrew’s Drive, Durban North, KwaZulu-Natal, South Africa","67 Boshoff Street, Pietermaritzburg, KwaZulu-Natal, South Africa","4 Paul Avenue, Empangeni, KwaZulu-Natal, South Africa","166 Kerk Street, Vryheid, KwaZulu-Natal, South Africa","9 Margaret Street, Ixopo, KwaZulu-Natal, South Africa","16 Poort Road, Ladysmith, KwaZulu-Natal, South Africa"],null,null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]},{"method":"addAntpath","args":[[[[{"lng":[31.031337,30.789828,30.648226,30.497256,30.387542,30.35198,30.344987,30.283789,30.298032,30.255263,30.243364,30.1183,30.083721,30.05873],"lat":[-29.85116,-29.825962,-29.73682,-29.719201,-29.743572,-29.778809,-29.822984,-29.873862,-29.910925,-29.955399,-30.011787,-30.113784,-30.118448,-30.157002]}]],[[{"lng":[30.05873,30.083721,30.1183,30.243575,30.255263,30.298032,30.283789,30.34475,30.35198,30.389852,30.374869,30.391496],"lat":[-30.157002,-30.118448,-30.113784,-30.011492,-29.955399,-29.910925,-29.873862,-29.823162,-29.778809,-29.74119,-29.718,-29.606792]}]],[[{"lng":[30.391496,30.216923,30.125351,30.051293,29.940801,29.904298,29.823647,29.775339,29.647541,29.607961,29.734517,29.777129],"lat":[-29.606792,-29.507077,-29.374002,-29.324238,-29.094589,-29.054628,-29.024243,-28.913344,-28.737504,-28.587953,-28.589456,-28.559912]}]],[[{"lng":[29.777129,29.969378,29.986019,29.955779,29.97785,30.178393,30.218829,30.268651,30.406795,30.657346,30.78968],"lat":[-28.559912,-28.343739,-28.291266,-28.167996,-28.119756,-28.140239,-28.163115,-28.156395,-27.981257,-27.865113,-27.76908]}]],[[{"lng":[30.78968,30.85068,31.02983,31.050346,31.048299,31.156575,31.216035,31.247758,31.27868,31.329451,31.327727,31.410593,31.395309,31.421872,31.493572,31.540454,31.594235,31.636389,31.665521,31.713263,31.800263,31.866019,31.90246],"lat":[-27.76908,-27.879314,-27.975955,-28.023931,-28.148325,-28.200515,-28.296491,-28.303776,-28.38196,-28.426619,-28.458051,-28.497024,-28.602433,-28.655851,-28.65094,-28.724702,-28.729382,-28.698217,-28.71131,-28.689386,-28.738671,-28.724997,-28.75779]}]],[[{"lng":[31.90246,31.93175,31.892702,31.752466,31.533365,31.43939,31.381716,31.3138,31.143728,31.039217],"lat":[-28.75779,-28.769052,-28.858061,-28.935344,-29.162123,-29.2078,-29.300067,-29.353838,-29.582813,-29.789162]}]],[[{"lng":[31.039217,31.031337],"lat":[-29.789162,-29.85116]}]]],null,null,{"delay":400,"paused":false,"reverse":false,"hardwareAccelerated":false,"dashArray":[10,20],"pulseColor":"#ffffff","interactive":true,"className":"","stroke":true,"color":"#03F","weight":5,"opacity":0.5,"fill":false,"fillColor":"#03F","fillOpacity":0.2,"smoothFactor":1,"noClip":false},null,null,null,{"interactive":false,"permanent":false,"direction":"auto","opacity":1,"offset":[0,0],"textsize":"10px","textOnly":false,"className":"","sticky":true},null]}],"limits":{"lat":[-30.1570021,-27.7690778],"lng":[29.607961,31.93175]}},"evals":[],"jsHooks":[]}</script>
```

## Things I also did:

The other way I worked on this solution was far more complex, but a better learning experience overall.
While waiting for the information about the delivery vehicle, I investigated the options for using custom travelling profiles, and this resulted in a broader learning experience.
In this second solution, nearly everything ended up the same, except for the fact that I used a local server instance of the Open Source Route Mapping (OSRM) engine.

First, I had to learn how to use the Windows Subsystem for Linux (WSL), which required installation, debugging, and familiarisation.
Once I had accomplished this, I could then use a gist kindly provided by Andrew Collier.

## The Code (v.2)
In my WSL environment:


```bash
# Gist from https://datawookie.dev/blog/2017/09/building-a-local-osrm-instance/
# Running in Debian WSL on my Windows PC

# Install osrm-backend so that I can run an OSRM server locally on my machine
sudo apt update
sudo apt install -y git \
                    cmake \
                    build-essential \
                    jq \
                    liblua5.2-dev \
                    libboost-all-dev \
                    libprotobuf-dev \
                    libtbb-dev \
                    libstxxl-dev \
                    libbz2-dev

git clone https://github.com/Project-OSRM/osrm-backend.git

cd osrm-backend/
mkdir build
cd build/
cmake ..

make

sudo make install

```

After I installed this local osrm-backend engine, I could then extract and process the routing data before running my cUrl requests.


```bash
# Code modified from https://datawookie.dev/blog/2017/09/building-a-local-osrm-instance/

# You will need to work in the directory where you ran the above code.
# Move to the Windows folder I installed the osrm-backend instance to:
cd /mnt/d/osrm-backend

# Download OpenStreetMap extracts from Geofabrik using wget
sudo apt-get install wget
wget https://download.geofabrik.de/africa/south-africa-latest.osm.pbf

# Extract the map data
osrm-extract -p profiles/car.lua south-africa-latest.osm.pbf
# Prepare for routing by first creating a hierarchy
osrm-contract south-africa-latest.osrm
# Then we launch a server instance
osrm-routed south-africa-latest.osrm

# Note: My OSRM server instance tells me that it is listening on 0.0.0.0:5000
# From what I understand this means that it is listening across all IP addresses available in my WSL
# The problem is that I need the IP address of my WSL in order to direct my Windows OS 
# to the right IP when I send requests
# So we check the IP Address of our WSL.
# In Debian the ifconfig command is deprecated so I use
ip address

# For my WSL the ip address query returned: http://172.23.142.206:5000
# I use this for the osrm.server argument below.
```

From this point I ran all the `R` code above, except where I modified the call to the the `osrmTrip` function as follows:


```r
trip <- osrmTrip(loc = locations, osrm.server = "http://172.23.142.206:5000/", osrm.profile = "car")
```


Additional code sources:  
1.<https://askubuntu.com/questions/943006/how-to-navigate-to-c-drive-in-bash-on-wsl-ubuntu>
