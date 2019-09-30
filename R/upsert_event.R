# ----------------------------------------------#
# Upsert event table                         ####
# ----------------------------------------------#

#' @title Event data upsert

#' @description Upserts event data to Natron.

#' @param data Structured and mapped event table to be upserted (see \code{?str_map_events()}).
#' @param conn Database connection object with write permissions (see \code{?natron_connect}).

#' @family upsert functions

#' @return Pushes and upserts data to database. Returns nothing.

#' @examples
#'\dontrun{
#' upsert_events(data = myEvents, conn = myConnection)
#'}
#'
#' @import RPostgreSQL
#'
#' @export






upsert_events <- function(data, conn){


  # get column names from NaTron
  tableinfo <- RPostgreSQL::dbGetQuery(conn,
                                       "select column_name
                        from information_schema.columns
                        where table_name = 'Events'
                        ;")


  # check that they are equal
  if(!identical(tableinfo$column_name, colnames(data))) stop("The column in your data don't perfectly match those in NaTron")


  # append to tha NaTron table
  RPostgreSQL::dbWriteTable(conn, c("data", "Events"),
                            value = data,
                            row.names = FALSE,
                            append = T)
}

