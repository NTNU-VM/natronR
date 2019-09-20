# ----------------------------------------------#
# Upsert location table                      ####
# ----------------------------------------------#

#' @title Location upsert
#' @description Upserts location tables to the NaTron database.
#'
#' @param conn Database connection object with write permissions (see \code{?natron_connect}). It's the connection object that determines if the data is upserted to the sandbox or not.
#' @param location_data Location table to be upserted/uploaded to NaTron (see \code{?location_table})
#' @family upsert functions
#' @return Pushes and upserts data to database. Returns nothing.
#' @examples
#' \dontrun{
#' upsert_location(location_data = myLocationTable, conn = myConnection)
#' }
#'
#' @import RPostgreSQL
#'
#' @export
#'



# function UPSERT m_dataset----
upsert_locations <- function(location_data, conn){



  #RPostgreSQL::dbSendQuery(conn,"DROP TABLE IF EXISTS temp.temp_location_import;")

  # get column names from NaTron
  tableinfo <- RPostgreSQL::dbGetQuery(conn,
                                       "select column_name
                        from information_schema.columns
                        where table_name = 'Locations'
                        ;")

  # check that they are equal
  if(!identical(tableinfo$column_name, colnames(location_data))) stop("The column in your data don't perfectly match those in NaTron")

  RPostgreSQL::dbWriteTable(conn, c("data", "Locations"),
                            value = myLocTab,
                            row.names = FALSE,
                            append = T)


  # end function here?

  RPostgreSQL::dbWriteTable(conn, c("temp", "temp_location_import"),
                            value = myLocTab,
                            row.names = FALSE,
                            append = T)



  RPostgreSQL::dbWriteTable(conn, c("temp", "temp_location_import"),
                            value = myLocTab,
                            row.names = FALSE)




  # The temp file needs (I think) the columns to be of the same class as the real table. One option is to change them in the temp schema:
  RPostgreSQL::dbSendQuery(conn,"ALTER TABLE temp.temp_location_import
                           ALTER COLUMN \"locationID\" SET DATA TYPE uuid
                           ;")
  # and so on...

  # or to change them whilst upserting (more typing...)



  # update or insert m_dataset_data table
  RPostgreSQL::dbSendQuery(conn,"INSERT INTO data.\"Locations\"(
              \"locationID\",
              locality,
              \"verbatimLocality\",
              \"stationNumber\",
              \"verbatimCoordinates\",
              \"geodeticDatum\",
              \"coordinateUncertaintyInMeters\",
              \"decimalLatitude\",
              \"decimalLongitude\",
              \"locationRemarks\",
              \"siteNumber\")

        SELECT

              CAST(\"locationID\" AS uuid),
              locality,
              \"verbatimLocality\",
              \"stationNumber\",
              \"verbatimCoordinates\",
              \"geodeticDatum\",
              CAST(\"coordinateUncertaintyInMeters\" AS numeric),
              CAST(\"decimalLatitude\" AS numeric),
              CAST(\"decimalLongitude\" AS numeric),
              CAST(\"locationRemarks\" AS text),
              \"siteNumber\"

        FROM temp_location_import

        ON CONFLICT

             (\"locationID\") DO UPDATE SET
              \"locality\"            = EXCLUDED.\"locality\",
              \"verbatimLocality\"    = EXCLUDED.\"verbatimLocality\",
              \"stationNumber\"       = EXCLUDED.\"stationNumber\",
              \"verbatimCoordinates\" = EXCLUDED.\"verbatimCoordinates\",
              \"geodeticDatum\"       = EXCLUDED.\"geodeticDatum\",
              \"coordinateUncertaintyInMeters\"
                                      = EXCLUDED.\"coordinateUncertaintyInMeters\",
              \"decimalLatitude\"     = EXCLUDED.\"decimalLatitude\",
              \"decimalLongitude\"    = EXCLUDED.\"decimalLongitude\",
              \"locationRemarks\"     = EXCLUDED.\"locationRemarks\",
              \"siteNumber\"          = EXCLUDED.\"siteNumber\"
              ;")


  # Drop temporary tables
  RPostgreSQL::dbSendQuery(conn,"DROP TABLE IF EXISTS temp_location_import;")
}


