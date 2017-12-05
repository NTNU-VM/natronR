# UPSERT functions

# takes as input an R object exactly formated to the database table
# ([tablename]_data, and an RPostgreSQL connetion object with write
# permissions (conn).

#' Upserts location into Natron database
#'
#' @param con Database connection object with write permissions
#' @param locations Location to be upserted.
#' @return Pushes and upserts data to database
#' @examples
#'
#' Still to come
#'
#'
#' @import dplyr
#' @import dbplyr
#' @import RPostgreSQL
#'
#' @export
#'
# takes as input an R object exactly formated to the database table
# ([tablename]_data, and an RPostgreSQL connetion object with write
# permissions (conn).


# function UPSERT m_dataset----
f_upsert_location <- function(conn,location_data){
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_location_import;")
  dbWriteTable(conn, "temp_location_import", append = TRUE,
               value = location_data, row.names = FALSE)
  # update or insert m_dataset_data table
  dbSendQuery(conn,"INSERT INTO data.\"Locations\"(
              \"locationID\", locality,
              \"verbatimLocality\", \"stationNumber\", \"verbatimCoordinates\",
              \"coordinateUncertaintyInMeters\", \"geodeticDatum\", \"decimalLatitude\",
              \"decimalLongitude\", \"locationRemarks\",
              \"siteNumber\")
              SELECT
              CAST(\"locationID\" AS uuid), locality, \"verbatimLocality\", \"stationNumber\",
              \"verbatimCoordinates\",
              \"geodeticDatum\",
              CAST(\"decimalLatitude\" AS numeric), CAST(\"decimalLongitude\" AS numeric),
              CAST(\"locationRemarks\" AS text),
              \"siteNumber\"
              FROM data.temp_location_import
              ON CONFLICT (\"locationID\") DO UPDATE SET
              \"locality\" = EXCLUDED.\"locality\",
              \"verbatimLocality\" = EXCLUDED.\"verbatimLocality\",
              \"stationNumber\" = EXCLUDED.\"stationNumber\",
              \"verbatimCoordinates\" = EXCLUDED.\"verbatimCoordinates\",
              \"geodeticDatum\" = EXCLUDED.\"geodeticDatum\",
              \"decimalLatitude\" = EXCLUDED.\"decimalLatitude\",
              \"decimalLongitude\" = EXCLUDED.\"decimalLongitude\",
              \"locationRemarks\" = EXCLUDED.\"locationRemarks\",
              \"siteNumber\" = EXCLUDED.\"siteNumber\",
              ;")


  # Drop temporary tables
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_location_import;")
}
