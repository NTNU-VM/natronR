
# ----------------------------------------------#
# Structure and map                          ####
# ----------------------------------------------#

# Function takes inn a flattened datatable with
# both terms/colums corresponding exactly to the
# database columns and datatypes and returns
# an event dataframe ready to be upserted.


# INPUT:
# 1. Flatenned data
# 2. DB connection with access permission
# 3. Updated location table for flattened data (needs to be run through location_check and get_new_loc).

# OUTPUT:
# Event dataframe in formatted to be upserted to Natron.


# Packages required (will be in dependencies later)
library(dbplyr)
library(dplyr)
library(dplR)   # uuid.gen()
library(postGIStools)
library(lubridate)
library(sp)
library(mapview)
library(RPostgreSQL)



# ----------------------------------------------#
# DB conncetions ----------------------------####
# ----------------------------------------------#

# creating db connection object

pg_drv <- "PostgreSQL"
pg_db <- "natron_sandbox"
pg_host <- "vm-srv-zootron.vm.ntnu.no"

con<-dbConnect(pg_drv,
               host=pg_host,
               dbname=pg_db,
               user=getPass::getPass("Please enter your username"),
               password=getPass::getPass("Please enter password"))



#con <- src_postgres(host="vm-srv-zootron.vm.ntnu.no",
#                    dbname="natron_sandbox",                                                  # SANDBOX
#                    user=rstudioapi::askForPassword("Please enter your user"),
#                    password=rstudioapi::askForPassword("Please enter your psw"))






# dummy data:
library(readr)
newLocalitySub <- c(1:5, 8:20)
flatt_data <- read_csv("flat_data_dummy_std_long.csv")
location_check_flatt_data <- location_check(flatt_data,con,8000)
location_check_flatt_data <- get_new_loc(location_check_flatt_data$possible_matches, location_check_flatt_data$no_matches, newLocalitySub)
location_table <- location_check_flatt_data$all_locations

# -----------------------------------------------#
# Get db table info---------------------------####
# -----------------------------------------------#

tableinfo <- dbGetQuery(con,
                        "select table_name,column_name,data_type
                        from information_schema.columns
                        where table_name = 'Events' OR
                        table_name = 'Occurrences' OR
                        table_name = 'Locations'
                        ;")

# Get location table for matching and retrieving locationIDs
Natron_location <- dbGetQuery(con,
                             "SELECT
                               \"locationID\", \"verbatimLocality\", \"locality\",\"stationNumber\"
                             FROM
                               data.\"Locations\"
                             ;")

Natron_location_full <- dbGetQuery(con,
                              "SELECT
                               *
                             FROM
                               public.location_view
                              LIMIT 10
                             ;")




#--------------------------------------------------#
# structure and map event table ----------------####
#--------------------------------------------------#

# flatt data        : Flat data to be mapped as event data
# conn              : Connection to be used to database
# location_updated  : Location table with updated UUIDs (has been run through locality_check functions)

f_structure_and_map_event <- function(flatt_data,conn, location_table) {
  require(tidyverse)

  # select terms for event table

  event_db_terms <- tableinfo$column_name[tableinfo$table_name=="Events"]
  event_terms <- names(flatt_data)[names(flatt_data) %in% event_db_terms]
  event_terms[length(event_terms)+1] <- "locality"
  event_data_temp <- flatt_data[event_terms]


  # create empty dataframe with all event table terms
  event_data <- data.frame(matrix(ncol = length(event_db_terms), nrow = 0),stringsAsFactors=FALSE)
  colnames(event_data) <- event_db_terms


  # rowbind event data from import to the empty data.frame
  # in order to create generic event table for import
  event_data <- bind_rows(event_data,event_data_temp)
  event_data$locationID <- location_table$locationID[match(event_data$locality,location_table$locality)]

  # NOTE! Empty columns turns out as bolean (logical data type).
  # Need to convert these to character before db import
  is_character <- as.character(lapply(event_data,mode))=="logical"
  event_data[is_character] <- lapply(event_data[,is_character], as.character)

  # set modified data if not given
  event_data$modified <- as.character(event_data$modified)
  event_data$modified <- ifelse(is.na(event_data$modified),
                                as.character(Sys.Date()),
                                event_data$modified)
  # remove locality column
  event_data <- event_data[,-27]


  return(event_data)
}



#-------------------------------------------------#
# structure and map occurrence table ----------####
#-------------------------------------------------#

f_structure_and_map_event <- function(flatt_data,conn, location_table) {

   # select terms for occurrence table
  occurrence_db_terms <- tableinfo$column_name[tableinfo$table_name=="Occurrences"]
  occurrence_terms <- names(flatt_data)[names(flatt_data) %in% occurrence_db_terms]
  occurrence_terms[length(occurrence_terms)+1] <- "locality"
  occurrence_data_temp <- flatt_data[occurrence_terms]


  # create empty dataframe with all event table terms
  occurrence_data <- data.frame(matrix(ncol = length(occurrence_db_terms), nrow = 0))
  colnames(occurrence_data) <- occurrence_db_terms

  # rowbind event data from import to the empty data.frame
  occurrence_data <- bind_rows(occurrence_data,occurrence_data_temp)
  occurrence_data$locationID <- location_table$locationID[match(occurrence_data$locality,location_table$locality)]

  # NOTE! Empty columns turns out as bolean (logical data type).
  # Need to convert these to character before db import
  is_character <- as.character(lapply(occurrence_data,mode))=="logical"
  occurrence_data[is_character] <- lapply(occurrence_data[,is_character], as.character)

  # set modified date to data if not given
  occurrence_data$modified <- as.character(occurrence_data$modified)
  occurrence_data$modified <- ifelse(is.na(occurrence_data$modified),
                                     as.character(Sys.Date()),
                                     occurrence_data$modified)
  # remove locality column
  occurrence_data <- occurrence_data[,-36]


  return(occurrence_data)

}





