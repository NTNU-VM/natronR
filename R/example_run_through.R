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

MyLocationData <- get_new_loc(matched_localities,
                              definately_brand_new_localities,
                              matched_localities_toimport,
                              matched_localities_technical)


location_data <- MyLocationData$new_localities

f_upsert_location(conn,location_data)
# I get stuck here...
