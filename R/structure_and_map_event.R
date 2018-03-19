
# ----------------------------------------------#
# Structure and map                          ####
# ----------------------------------------------#

#' Function takes inn a flattended datatable with both terms/colums corresponding exactly to the database columns and datatypes and returns an event dataframe ready to be upserted.
#' @param flatt_data Flatenned data to be structured
#' @param conn DB connection with access permission, can easily be produced using natron_connect script
#' @param location_table location table for flattened data (needs to be run through location_check and get_new_loc).
#' @return Event data that is ready to be upserted to Natron.

#' @export


# Packages required (will be in dependencies later)
# library(dbplyr)
# library(dplyr)
# library(dplR)   # uuid.gen()
# library(postGIStools)
# library(lubridate)
# library(sp)
# library(RPostgreSQL)
# library(tidyverse)


# dummy data:
# library(readr)
# newLocalitySub <- c(1:5, 8:20)
# flatt_data <- read_csv("flat_data_dummy_std_long.csv")
# conn <- natron_connect("samp")
# location_check_flatt_data <- location_check(flatt_data,conn,8000)
# location_check_flatt_data <- get_new_loc(location_check_flatt_data$possible_matches, location_check_flatt_data$no_matches, location_check_flatt_data$possible_matches[newLocalitySub,1])
# location_table <- location_check_flatt_data$location_table


f_structure_and_map_event <- function(flatt_data,conn, location_table) {

  # Get all terms in one table
  tableinfo <- dbGetQuery(conn,
                          "select table_name,column_name,data_type
                        from information_schema.columns
                        where table_name = 'Events' OR
                        table_name = 'Occurrences' OR
                        table_name = 'Locations'
                        ;")

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


