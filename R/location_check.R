

#************************************#
# LOCALITY CHECK                 ####
#************************************#

#' @title Location check
#'
#'
#'
#' @description This function takes as input a standardised flat and long (as opposed to wide formated) dataset and makes the locations table for it. It then scans the existing  NaTron locations table and returns a list of pre-existing localities that lie within a given radius of the coordinates. The user must then manully check if some of these localities can be reused. If so, the user must copy-paste the locationID from the existing NaTron locality
#'
#' @param flatt_data A flattened, long and standardised dataset that you wish to import into NaTron
#' @param conn  A connection object with natron (can be easily generated with the natron_connect script)
#' @param radius The radius in meters in which to search for preexisting localitites in naTron
#'
#' @return A list with 2 data frames. possible_matches shows all those which have a match within the radius set by the function. no_matches holds those without a match.
#' @export

# Tes data
#data <- flat_data_dummy_std_long
#conn <- natron_connect("samp")
#radius <- 8000

#-----------------------------------------------###
# Function starts                   -----------####
#-----------------------------------------------###

location_check <- function(data,conn,radius) {

# -----------------------------------------------#
# Get db table info---------------------------####
# -----------------------------------------------#

natron_tableinfo <- dbGetQuery(conn,
                        "select table_name,column_name,data_type
                        from information_schema.columns
                        where table_name =  'Locations'
                        ;")

# -----------------------------------------------#
# Make locations lable         ---------------##### -----------------------------------------------#

# subset local data to match terms used in Natron:
local_terms <- names(data)[names(data) %in% natron_tableinfo$column_name]
local_data_temp <- data[local_terms]

# subset only unique locations
local_data_temp_unique <- local_data_temp[!duplicated(paste0(local_data_temp$decimalLongitude, local_data_temp$decimalLatitude)),]
# standardising the dataset to look exactly like Natron.
# - create empty dataframe of similar dimensions
local_data_temp_blank <- data.frame(matrix(ncol = length(natron_tableinfo$column_name), nrow = 0),stringsAsFactors=FALSE)

# - paste natron column names in correct order
colnames(local_data_temp_blank) <- natron_tableinfo$column_name

# rowbind local data to the blank data frame
local_data_temp_filled <- bind_rows(local_data_temp_blank, local_data_temp_unique)


# Scan the Natron db for pre-existing localities:

#  - First just get some localities near Trondheim
dupl_locations <- dbGetQuery(conn,
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

# add some more columns were we can put the names and coordinates of our own localities
ord <- colnames(dupl_locations)
dupl_locations$newLocality <- ""
dupl_locations$newLat      <- ""
dupl_locations$newLong     <- ""
dupl_locations$distance_km     <- ""
new <- c("newLocality", "newLat", "newLong","distance_km")



dupl_locations2 <- dupl_locations[,c(new, ord)]                     # put new columns first
dupl_locations3 <- dupl_locations2[-c(1:nrow(dupl_locations2)),]    # DELETE all rows
#rm(dupl_locations, dupl_locations2)                                 # clean up

# This for-loop to produces SQL query sentences for each locality, filtering by a chosen geographic radius
temp_sql <- ""
for(HEY in 1:nrow(local_data_temp_filled)){
temp_sql[HEY] <-  paste("SELECT",
                          "\"locationName\",",
			  "round(((((ST_distance(st_geomfromtext('POINT(",
			  local_data_temp_filled$decimalLongitude[HEY], local_data_temp_filled$decimalLatitude[HEY],
			  ")', 4326),",
			  "\"localityGeom\") * 6378137) * pi()) / 180)/1000)::numeric, 3) as \"distance_km\",",
                	  "\"locationID\", \"decimalLatitude\", \"decimalLongitude\"," ,
                          "\"locality\", \"country\", \"county\", \"siteNumber\", \"stationNumber\",",
                          "\"riverName\", \"catchmentName\"",
                          "FROM",
                          "public.location_view",
                          "WHERE",
                          "ST_dwithin(st_geomfromtext('POINT(",
                          local_data_temp_filled$decimalLongitude[HEY], local_data_temp_filled$decimalLatitude[HEY],
                          ")', 4326),",
                          "\"localityGeom\",((", radius, " * 180.0) / pi()) / 6378137.0)",
			  "order by \"distance_km\";",
                          sep = " ")
}




# Combining all positive macthes into one dataframe
locality_check <- dupl_locations3

for(HEY in 1:nrow(local_data_temp_filled)){
  temp <- ""
  temp <- dbGetQuery(conn, temp_sql[HEY])

  if(dim(temp)[1] !=0) {
    temp2 <- temp;
    temp2$newLocality <- rep(local_data_temp_filled[HEY, "locality"], times=nrow(temp2));
    temp2$newLat <- rep(local_data_temp_filled[HEY, "decimalLatitude"], times=nrow(temp2));
    temp2$newLong <- rep(local_data_temp_filled[HEY, "decimalLongitude"], times=nrow(temp2));
    temp2 <- temp2[,c(new, ord)];
    locality_check <- rbind(locality_check, temp2);
    rm(temp2)}


}

if(dim(locality_check)[1] !=0) locality_check <- locality_check   # only return the data frame if it has rows
no_matches <- local_data_temp_filled[!local_data_temp_filled$locality %in% locality_check$newLocality,]
print(paste(
  length(unique(locality_check$newLocality)), "of your locations have possible matches in NaTron.\n",
  paste(nrow(local_data_temp_filled)-length(unique(locality_check$newLocality)),
        "of your locations had no existing locations within a", radius, "m radius.")))
return(list(possible_matches = locality_check,no_matches = no_matches))

}
# END FUNCTION

