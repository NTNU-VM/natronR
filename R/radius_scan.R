
#radius_scan

#************************************#
# Find NaTRON locations           ####
#************************************#

#' @title Find NaTRON locations
#'
#'
#'
#' @description This function uses the decimalLatitude and -Longitude columns from a location table to look for existing entries in the NaTRON locations datable within a given radius.
#'
#' @param locationTable A dataset containing at least two columns: decimalLongitude and decimalLatitude. Usually you want to put here the loction table returned by \code{location_table()}.
#' @param conn  A connection object with NaTRON (see \code{?natron_connect}).
#' @param radius The radius in meters in which to search for preexisting localitites in NaTron.
#' @examples
#' myScan <- radius_scan(myLocationTable, myConnection, 100)
#'
#' @return If there are any positive matches the function returns these as a dataframe with 15 columns. The last three columns (starting with 'new') are from the dataset you entered and for which there was found a match in NaTRON. The distance from the entered coordinates and the NaTRON location it is compared to is given in 'distance_km'.


#' @import RPostgreSQL
#'
#'
#'





#' @export
radius_scan <- function(locationTable, conn, radius){

  temp_sql <- ""
  #************************************#
  # generate queries                ####
  #************************************#
for(HEY in 1:nrow(locationTable)){
  temp_sql[HEY] <-  paste("SELECT",
                          "\"locationName\",",
                          "round(((((ST_distance(st_geomfromtext('POINT(",
                          locationTable$decimalLongitude[HEY], locationTable$decimalLatitude[HEY],
                          ")', 4326),",
                          "\"localityGeom\") * 6378137) * pi()) / 180)/1000)::numeric, 3) as \"distance_km\",",
                          "\"locationID\", \"decimalLatitude\", \"decimalLongitude\"," ,
                          "\"locality\", \"country\", \"county\", \"siteNumber\", \"stationNumber\",",
                          "\"riverName\", \"catchmentName\"",
                          "FROM",
                          "public.location_view",
                          "WHERE",
                          "ST_dwithin(st_geomfromtext('POINT(",
                          locationTable$decimalLongitude[HEY], locationTable$decimalLatitude[HEY],
                          ")', 4326),",
                          "\"localityGeom\",((", radius, " * 180.0) / pi()) / 6378137.0)",
                          "order by \"distance_km\";",
                          sep = " ")
}




#************************************#
# Query and return                ####
#************************************#
emptyDF <- locationTable[-c(1:nrow(locationTable)),]

for(HEY in 1:nrow(locationTable)){
  temp <- ""
  temp <- RPostgreSQL::dbGetQuery(conn, temp_sql[HEY])

  if(dim(temp)[1] !=0) {
    temp2 <- temp;
    temp2$newLocality <- rep(locationTable[HEY, "locality"], times=nrow(temp2));
    temp2$newLat <- rep(locationTable[HEY, "decimalLatitude"], times=nrow(temp2));
    temp2$newLong <- rep(locationTable[HEY, "decimalLongitude"], times=nrow(temp2));
    emptyDF <- rbind(emptyDF, temp2);
    rm(temp2)}

}



possibleMatches <- emptyDF


cat(paste(
  paste(length(unique(emptyDF$newLocality)), "of your locations have possible matches in NaTron."),
  paste(nrow(locationTable)-length(unique(emptyDF$newLocality)),
        "of your locations had no existing locations within a", radius, "m radius."), "", sep = "\n"))
return(possibleMatches)

}
