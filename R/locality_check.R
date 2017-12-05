

#************************************#
# LOCALITY CHECK                 ####
#************************************#

# This function is made so one can check if the locations in a dataset ment for publishin in NaTron
# don't alredy exist in the database. (Often the publisher know if they are pre-existing or not and
# then he doesn't need this function)


# This function takes as input a standardised flat and long (as opposed to wide formated) dataset
# and makes the locations table for it. It then scans the existing  NaTron locations table and
# returns a list of pre-existing locatlities that lie within 1000 m radius of the give coordinates.
# The uses then is asked to manully check if not some of these localities can be reused. If so, the
# user must copy-paste the locationID from the existing NaTron localition



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



# dummy data:
library(readr)
flatt_data <- read_csv("flat_data_dummy_std_long.csv")


# -----------------------------------------------#
# Get db table info---------------------------####
# -----------------------------------------------#

tableinfo <- dbGetQuery(con,
                        "select table_name,column_name,data_type
                        from information_schema.columns
                        where table_name =  'Locations'
                        ;")

# -----------------------------------------------#
# Get db NaTron locations table---------------####
# -----------------------------------------------#
Natron_location <- dbGetQuery(con,
                              "SELECT
                               \"locationID\", \"verbatimLocality\", \"locality\", \"verbatimLocality\",\"stationNumber\"
                             FROM
                               data.\"Locations\"
                             ;")


#-----------------------------------------------###
# Function starts                   -----------####
#-----------------------------------------------###

location_check <- function(flatt_data,conn) {
  require(tidyverse)


# Creating an empty dataframe to go into the for-loop below
dupl_locations <- dbGetQuery(con,
                               "SELECT
                              \"locationName\", \"locationID\",\"decimalLatitude\", \"decimalLongitude\",
                                \"locality\", \"country\", \"county\", \"siteNumber\", \"stationNumber\",
                                  \"riverName\", \"catchmentName\"
                             FROM
                                public.location_view
                             WHERE
                                ST_dwithin(st_geomfromtext('POINT(10 63)', 4326),
                               \"localityGeom\",((10000 * 180.0) / pi()) / 6378137.0)
                                                            ;")
# I would have verbatimLocality here as well, but it doesn't exist in public.location_view

ord <- colnames(dupl_locations)
dupl_locations$newLocality <- ""
dupl_locations2 <- dupl_locations[,c("newLocality", ord)]
dupl_locations3 <- dupl_locations2[-c(1:nrow(dupl_locations2)),]
rm(dupl_locations, dupl_locations2)

# A for-loop to produce SQL query snetences for each locality
temp_sql <- ""
for(HEY in 1:nrow(loc_data_temp2)){
  temp_sql[HEY] <-  paste("SELECT",
                          "\"locationName\",\"locationID\", \"decimalLatitude\", \"decimalLongitude\"," ,
                          "\"locality\", \"country\", \"county\", \"siteNumber\", \"stationNumber\",",
                          "\"riverName\", \"catchmentName\"",
                          "FROM",
                          "public.location_view",
                          "WHERE",
                          "ST_dwithin(st_geomfromtext('POINT(",
                          loc_data_temp2$decimalLatitude[HEY], loc_data_temp2$decimalLongitude[HEY],
                          ")', 4326),",
                          "\"localityGeom\",((10000 * 180.0) / pi()) / 6378137.0);",
                          sep = " ")
}
temp_sql[1]



# Combining all positive macthes into one dataframe
temp <- ""
locality_check <- ""

for(HEY in 1:nrow(loc_data_temp2)){
  temp2 <- ""
  temp <- dbGetQuery(con, temp_sql[HEY])
  if(nrow(temp>0)) temp2 <- temp
  temp2$newLocality <- rep(loc_data_temp2[HEY, "locality"], times=nrow(temp2))
  temp2 <- temp2[,c("newLocality", ord)]
  locality_check <- rbind(dupl_locations3, temp2)
}











}
