

#************************************#
# LOCALITY CHECK                 ####
#************************************#

# This function is made so one can check if the locations in a dataset ment for publishin in NaTron
# don't alredy exist in the database. (Often the publisher know if they are pre-existing or not and
# then he doesn't need this function)


# This function takes as input a standardised flat and long (as opposed to wide formated) dataset
# and makes the locations table for it. It then scans the existing  NaTron locations table and
# returns a list of pre-existing localities that lie within 1000 m radius of the give coordinates.
# The user then is asked to manully check if not some of these localities can be reused. If so, the
# user must copy-paste the locationID from the existing NaTron locality

# LIBRARY
library(RPostgreSQL)   # dbConnect
library(readr)         # read_csv
library(dplyr)         # bind_rows

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



# -----------------------------------------------#
# Get dummy data   ---------------------------####
# -----------------------------------------------#

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
# this is not used further I don't think...

# -----------------------------------------------#
# Make locations lable         ---------------####
# -----------------------------------------------#
loc_db_terms <- tableinfo$column_name[tableinfo$table_name=="Locations"]
loc_terms <- names(flatt_data)[names(flatt_data) %in% loc_db_terms]
loc_data_temp <- flatt_data[loc_terms]

# remove repeated locations
loc_data_temp2 <- loc_data_temp[!duplicated(paste0(loc_data_temp$decimalLongitude, loc_data_temp$decimalLatitude)),]

# create empty dataframe with all location table terms
loc_data_temp3 <- data.frame(matrix(ncol = length(loc_db_terms), nrow = 0),stringsAsFactors=FALSE)
colnames(loc_data_temp3) <- loc_db_terms
# rowbind location data to the empty data.frame
# in order to create location table identical to the one in NaTron
loc_data_temp4 <- bind_rows(loc_data_temp3, loc_data_temp2)



#-----------------------------------------------###
# Function starts                   -----------####
#-----------------------------------------------###

#location_check <- function(flatt_data,conn) {
#  require(tidyverse)


# Creating an empty dataframe to go into the for-loop below.
# First just get some localities near Trondheim
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
dupl_locations$newLat      <- ""
dupl_locations$newLong     <- ""
new <- c("newLocality", "newLat", "newLong")

dupl_locations2 <- dupl_locations[,c(new, ord)]                     # put new columns first
dupl_locations3 <- dupl_locations2[-c(1:nrow(dupl_locations2)),]    # DELETE all rows
rm(dupl_locations, dupl_locations2)                                 # clean up

# A for-loop to produce SQL query sentences for each locality, filtering by a geographic radius
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
                          "\"localityGeom\",((8000 * 180.0) / pi()) / 6378137.0);",
                          sep = " ")
}
# the radius should be reduced to maybe 100, here it's 8000 which gives 20 hits



# Combining all positive macthes into one dataframe
temp <- ""
locality_check <- dupl_locations3

for(HEY in 1:nrow(loc_data_temp2)){
  temp <- ""
  temp <- dbGetQuery(con, temp_sql[HEY])

  if(dim(temp)[1] !=0) {
    temp2 <- temp;
    temp2$newLocality <- rep(loc_data_temp2[HEY, "locality"], times=nrow(temp2));
    temp2$newLat <- rep(loc_data_temp2[HEY, "decimalLatitude"], times=nrow(temp2));
    temp2$newLong <- rep(loc_data_temp2[HEY, "decimalLongitude"], times=nrow(temp2));
    temp2 <- temp2[,c(new, ord)];
    locality_check <- rbind(locality_check, temp2);
    rm(temp2)}


}

return(cat(
  length(unique(locality_check$newLocality)), "of your locations have possible matches in NaTron.\n",
  paste(nrow(loc_data_temp2)-length(unique(locality_check$newLocality)),
        "of your locations had no existing locations within a XX m radius.")))



# END FUNCTION

# After manualy checking 'locality_check' table for possible reuse of NaTron locations,
# you may choose resue some locations, but not all.
# The next function lets you remove newLocations from the 'locations_check table if you think
# they should be imported into Natron. The newLocations not removed will not be upserted to NaTron,
# insted we will get the locationIDs from the altermnative locations and use them in the event table.


paste(unique(locality_check$newLocality))   # show all the localitites in your dataset that have possible matches in Natron
newLocalitySub <- c(1:5, 8:20)     # example numbers, locations 6 and 7 are preexisting
# the newLocalitySub argument is a vector of the newLocations that you want to import to NaTron
# (i.e. those that do not have any pre-existing locations in NaTron that could've been reused)
# indexed by the numerical order
# (i.e. the order they appear after entering unique(locality_check$newLocality))


get_new_loc <- function(x, y){
                    locality_check2 <- subset(x, !(x$newLocality %in% unique(x$newLocality)[newLocalitySub]));
                    locationTable_forNatron  <<- subset(y, !(y$locality %in% locality_check2$newLocality));
                    preexisting_locations    <<- subset(y, !(y$locality %in% locationTable_forNatron$locality));
                                        }


# x = locality_check or dataframe of localities with possible matchen in Natron
# y = loc_data_temp4 or dataframe of all unique localities in the new dataset



# NEW FUNCTION
get_new_locations(x = locality_check,
                  y = loc_data_temp4)



function(temp_location_table){
locationTable <- subset(loc_data_temp4, !(loc_data_temp4$locality %in% locality_check$newLocality))
# create UUIDS for these

# for a subset of the others, we get the UUIDs from NaTron

}

#}
