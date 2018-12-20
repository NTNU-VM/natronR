# Run through example

require(dplyr)
require(dbplyr)
require(dbConnect)
require(stringr)
require(tidyr)
require(RPostgreSQL)
library(lubridate)
library(sp)
library(mapview)
library(readr)
library(getPass)

setwd("M:\\Anders L Kolstad\\R\\R_projects\\natronbatchupload")
source("R\\location_check.R")
source("R\\natron_connect.R")
source("R\\get_new_loc.R")
source("R\\upsert_locations.R")

data <- read_csv("flat_data_dummy_std_long.csv")
conn <- natron_connect("AndersK")
radius <- 8000




MyLocationCheck <- location_check(data, conn, radius)


matched_localities            <- MyLocationCheck$possible_matches
matched_localities_technical  <- MyLocationCheck$possible_matches_technical   # added this as output from location_check. It contains all info for matched cases (Natron formatted)
definately_brand_new_localities                <- MyLocationCheck$no_matches
matched_localities_toimport   <- MyLocationCheck$possible_matches[1:10,1]
 # Comment: with this many dataframes, it could be an idea to have them assigned to the environment automatically in the location_check-function

# check locations on map
library( leaflet )
library( magrittr )

brand_new <- data.frame(lat=MyLocationCheck$no_matches$decimalLatitude,
                   lon=MyLocationCheck$no_matches$decimalLongitude,
                   group = "brand_new",
                   row_number = row.names(brand_new))
possible_matches <- data.frame(lat=MyLocationCheck$possible_matches$newLat,
                        lon=MyLocationCheck$possible_matches$newLong,
                        group = "possible_matches",
                        row_number = row.names(possible_matches))
preexisting_locations <- data.frame(lat=MyLocationCheck$possible_matches$decimalLatitude,
                               lon=MyLocationCheck$possible_matches$decimalLongitude,
                               group = "preexisting_locations",
                               row_number = row.names(preexisting_locations))

coords <- rbind(brand_new, possible_matches, preexisting_locations)

pal <- colorFactor(c("red","blue","orange"), domain = c("brand_new",
                                                        "possible_matches",
                                                        "preexisting_locations"))

leaflet(data = coords) %>% addTiles(group = "OSM",
  options = providerTileOptions(minZoom = 2, maxZoom = 100)) %>%
  addCircleMarkers( lat = ~lat, lng = ~lon,
              color = ~pal(group),
              stroke = F,
              fillOpacity = 1,
              popup = ~as.character(row.names(coords))) %>%
    addLegend("bottomright",
            colors = c("blue", "red", "orange"),
            title = "Locations (click on points to show row numbers)",
            labels = c("brand new", "possible matches", "preexisting locations"),
            opacity =1)




MyLocationData <- get_new_loc(matched_localities,
                              definately_brand_new_localities,
                              matched_localities_toimport,
                              matched_localities_technical)


location_data <- MyLocationData$new_localities

f_upsert_location(conn,location_data)
# I get stuck here...
