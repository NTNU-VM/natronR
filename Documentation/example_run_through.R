# Run through example

#require(dplyr)
#require(dbplyr)
#require(dbConnect)
#require(stringr)
#require(tidyr)
#require(RPostgreSQL)
#library(lubridate)
#library(sp)
#library(mapview)
#library(readr)
#library(getPass)
#library( leaflet )
#library( magrittr )

#setwd("M:\\Anders L Kolstad\\R\\R_projects\\natronbatchupload")


devtools::load_all(".")
data("setesdal")
conn <- natron_connect("AndersK")


myLocTab <- location_table(data = setesdal, conn)

scan <- radius_scan(locationTable = myLocTab, conn, radius = 8000)

map_locations(data = myLocTab)
map_locations(data = myLocTab, compare = scan)
map_locations(data = myLocTab, compare = scan, vertical = T)


decimalLatitude <- c(59.02936, 59.03352, 59.04758)
decimalLongitude <- c(7.278987, 7.267469, 7.184718)
myData <- data.frame(decimalLatitude, decimalLongitude)
map_locations(data = myData)
map_locations(data = myData, vertical = T)


decimalLatitude2 <- c(59.03347)
decimalLongitude2 <- c(7.268134)
myData2 <- data.frame(decimalLatitude = decimalLatitude2,decimalLongitude = decimalLongitude2)

map_locations(data = myData)




matched_localities            <- MyLocationCheck$possible_matches
matched_localities_technical  <- MyLocationCheck$possible_matches_technical   # added this as output from location_check. It contains all info for matched cases (Natron formatted)
definately_brand_new_localities                <- MyLocationCheck$no_matches
matched_localities_toimport   <- MyLocationCheck$possible_matches[1:10,1]
 # Comment: with this many dataframes, it could be an idea to have them assigned to the environment automatically in the location_check-function






MyLocationData <- get_new_loc(matched_localities,
                              definately_brand_new_localities,
                              matched_localities_toimport,
                              matched_localities_technical)


location_data <- MyLocationData$new_localities

f_upsert_location(conn,location_data)
# I get stuck here...
