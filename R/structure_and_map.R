
# ----------------------------------------------#
# Structure and map                          ####
# ----------------------------------------------#




# Function takes inn a flattended datatable with
# both terms/colums corresponding exactly to the
# database columns and datatypes and returns
# a list of dataframes for each database table ready to use with
# the ????.R script


# Issues:
# Currently works only against the event and the occurrence table

# TODO! in order to support flat-structure output
# Select distinct on everything else than occurrences





# INPUT:
# 1. standarized and checked data.frame (may be flattended)
# 2. db connection with read permission


# OUTPUT:
# list with event and occurrence tables as dataframes






# ----------------------------------------------#
# Packages ----------------------------------####
# ----------------------------------------------#

#require(RPostgreSQL)
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
#............................................................................
# Create db connection object.
# Remember: Don't ever store your password in scripts etc. The following
# works if working through Rstudio.
#...........................................................................


# creating db connection object

pg_drv <- "PostgreSQL"
pg_db <- "natron_sandbox"
pg_user <- "AndersK"
pg_host <- "vm-srv-zootron.vm.ntnu.no"

con<-dbConnect(pg_drv,
               host=pg_host,
               dbname=pg_db,
               user=pg_user,
               password=rstudioapi::askForPassword("Please enter your psw"))



#con <- src_postgres(host="vm-srv-zootron.vm.ntnu.no",
#                    dbname="natron_sandbox",                                                  # SANDBOX
#                    user=rstudioapi::askForPassword("Please enter your user"),
#                    password=rstudioapi::askForPassword("Please enter your psw"))



# A test:
connectivity <- paste(
  'SELECT * from data."Events" limit 100',
  sep=" ")
Connectionstuff <- get_postgis_query(con,connectivity)




# dummy data:
library(readr)
flatt_data <- read_csv("flat_data_dummy_std_long.csv")

f_structure_and_map <- function(flatt_data,conn) {
  require(tidyverse)




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


fk_info <- dbGetQuery(con,                                              # what does this do?
                      "SELECT

                      tc.constraint_name, ccu.constraint_name, kcu.constraint_name, tc.table_name, kcu.column_name,

                      ccu.table_name AS foreign_table_name,

                      ccu.column_name AS foreign_column_name, constraint_type

                      FROM

                      information_schema.table_constraints AS tc

                      JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name

                      left JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name

                      where constraint_type = 'FOREIGN KEY' AND

                      (tc.table_name='Occurrences' OR

                        tc.table_name='Events' OR

                        tc.table_name='Locations')

                      ;")


# Get location table for matching and retrieving locationIDs
Natron_location <- dbGetQuery(con,
                             "SELECT
                               \"locationID\", \"locality\", \"verbatimLocality\",\"stationNumber\"
                             FROM
                               data.\"Locations\"
                             ;")


#-----------------------------------------------###
# structure and map location  table -----------####
#-----------------------------------------------###
# select terms for location table table
loc_db_terms <- tableinfo$column_name[tableinfo$table_name=="Locations"]
loc_terms <- names(flatt_data)[names(flatt_data) %in% loc_db_terms]
loc_data_temp <- flatt_data[loc_terms]

# test: changing the second row so that it has a match in Natron
loc_data_temp[2,c("locality", "verbatimLocality", "stationNumber")]  <-
Natron_location[1,c("locality", "verbatimLocality", "stationNumber") ]


# marking rows with existing locations. Using as unique location a combination of three columns
loc_data_temp$remove <- ifelse(paste(loc_data_temp$locality,
                                         loc_data_temp$verbatimLocality,
                                         loc_data_temp$stationNumber) %in%
                                     paste(Natron_location$locality,
                                           Natron_location$verbatimLocality,
                                           Natron_location$stationNumber), 1,0)

# after checking, I remove the existing locations
loc_data <- loc_data_temp %>%
            filter(remove == 0) %>%
            select(-remove)


# adding UUID to new locations:
ug <- uuid.gen()
myLength <- nrow(loc_data)
uuids <- character(myLength)
for(i in 1:myLength){
  uuids[i] <- ug()
}



#any(duplicated(uuids))   # alway the case that it's FALSE
loc_data$locationID <- uuids



#-----------------------------------------------###
# structure and map m_dataset table -----------####
#-----------------------------------------------###



  # select terms for event table (NB! no need to select distinct in this case)
m_dataset_db_terms <- tableinfo$column_name[tableinfo$table_name=="m_dataset"]
m_dataset_terms <- names(flatt_data)[names(flatt_data) %in% m_dataset_db_terms]
m_dataset_data_temp <- flatt_data[m_dataset_terms]


  # create empty dataframe with all event table terms
m_dataset_data <- data.frame(matrix(ncol = length(m_dataset_db_terms), nrow = 0),stringsAsFactors=FALSE)
colnames(m_dataset_data) <- m_dataset_db_terms

  # rowbind event data from import to the empty data.frame
# in order to create generic event table for import
m_dataset_data <- bind_rows(m_dataset_data,m_dataset_data_temp)
  # NOTE! Empty columns turns out as bolean (logical data type).
# Need to convert these to character before db import
is_character <- as.character(lapply(m_dataset_data,mode))=="logical"
m_dataset_data[is_character] <- lapply(m_dataset_data[,is_character], as.character)





#--------------------------------------------------#
# structure and map event table ----------------####
#--------------------------------------------------#

  # select terms for event table
event_db_terms <- tableinfo$column_name[tableinfo$table_name=="Events"]
event_terms <- names(flatt_data)[names(flatt_data) %in% event_db_terms]
event_terms[3] <- "locality"
event_data_temp <- flatt_data[event_terms]

# create empty dataframe with all event table terms
event_data <- data.frame(matrix(ncol = length(event_db_terms), nrow = 0),stringsAsFactors=FALSE)
colnames(event_data) <- event_db_terms


# rowbind event data from import to the empty data.frame
# in order to create generic event table for import
event_data <- bind_rows(event_data,event_data_temp)

# NOTE! Empty columns turns out as bolean (logical data type).
# Need to convert these to character before db import
is_character <- as.character(lapply(event_data,mode))=="logical"
event_data[is_character] <- lapply(event_data[,is_character], as.character)

# set modified data if not given
event_data$modified <- as.character(event_data$modified)
event_data$modified <- ifelse(is.na(event_data$modified),
                              as.character(Sys.Date()),
                              event_data$modified)



#-------------------------------------------------#
# structure and map occurrence table ----------####
#-------------------------------------------------#
  # select terms for occurrence table
occurrence_db_terms <- tableinfo$column_name[tableinfo$table_name=="occurrence"]
occurrence_terms <- names(flatt_data)[names(flatt_data) %in% occurrence_db_terms]
occurrence_data_temp <- flatt_data[occurrence_terms]
occurrence_data_temp$modified <- Sys.Date()
  # create empty dataframe with all event table terms
occurrence_data <- data.frame(matrix(ncol = length(occurrence_db_terms), nrow = 0))
colnames(occurrence_data) <- occurrence_db_terms
  # rowbind event data from import to the empty data.frame
occurrence_data <- bind_rows(occurrence_data,occurrence_data_temp)
  # NOTE! Empty columns turns out as bolean (logical data type).
# Need to convert these to character before db import
is_character <- as.character(lapply(occurrence_data,mode))=="logical"
occurrence_data[is_character] <- lapply(occurrence_data[,is_character], as.character)
  # set modified date to data if not given
occurrence_data$modified <- as.character(occurrence_data$modified)
occurrence_data$modified <- ifelse(is.na(occurrence_data$modified),
                                   as.character(Sys.Date()),
                                   occurrence_data$modified)
  # set modified date to data if not given
mapped_data <- list(occurrence_data=occurrence_data,
                    event_data=event_data,
                    m_dataset_data=m_dataset_data)
}





