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




  # get column names from NaTron
  tableinfo <- RPostgreSQL::dbGetQuery(conn,
                                       "select column_name
                        from information_schema.columns
                        where table_name = 'Locations'
                        ;")

  # check that they are equal
  if(!identical(tableinfo$column_name, colnames(location_data))) stop("The column in your data don't perfectly match those in NaTron")

  # append to tha NaTron table
  RPostgreSQL::dbWriteTable(conn, c("data", "Locations"),
                            value = myLocTab,
                            row.names = FALSE,
                            append = T)



}


