# ----------------------------------------------#
# Upsert location table                      ####
# ----------------------------------------------#

#' @title Location upsert
#' @description Upserts location tables to the Natron database.
#'
#' @param con Database connection object with write permissions (see \code{?natron_connect}). It's the connection object that determines if the data is upserted to the sandbox or not.
#' @param location_data Location table to be upserted/uploaded to NaTRON.
#' @family upsert functions
#' @return Pushes and upserts data to database. Returns nothing.
#' @examples
#'
#' upsert_location(location_data = myLocationTable, conn = myConnection)
#'
#'
#' @import RPostgreSQL
#'
#' @export
#'



# function UPSERT m_dataset----
upsert_locations <- function(location_data, conn){

  RPostgreSQL::dbSendQuery(conn,"DROP TABLE IF EXISTS temp.temp_location_import;")
  RPostgreSQL::dbWriteTable(conn, "temp.temp_location_import", append = TRUE,
               value = location_data, row.names = FALSE)

  # update or insert m_dataset_data table
  RPostgreSQL::dbSendQuery(conn,"INSERT INTO data.\"Locations\"(
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

        FROM temp.temp_location_import

        ON CONFLICT (\"locationID\") DO UPDATE SET
              \"locality\"            = EXCLUDED.\"locality\",
              \"verbatimLocality\"    = EXCLUDED.\"verbatimLocality\",
              \"stationNumber\"       = EXCLUDED.\"stationNumber\",
              \"verbatimCoordinates\" = EXCLUDED.\"verbatimCoordinates\",
              \"geodeticDatum\"       = EXCLUDED.\"geodeticDatum\",
              \"decimalLatitude\"     = EXCLUDED.\"decimalLatitude\",
              \"decimalLongitude\"    = EXCLUDED.\"decimalLongitude\",
              \"locationRemarks\"     = EXCLUDED.\"locationRemarks\",
              \"siteNumber\"          = EXCLUDED.\"siteNumber\"
              ;")


  # Drop temporary tables
  RPostgreSQL::dbSendQuery(conn,"DROP TABLE IF EXISTS temp_location_import;")
}


