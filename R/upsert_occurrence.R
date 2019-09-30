# ----------------------------------------------#
# Upsert occurence table                         ####
# ----------------------------------------------#

#' @title Occurence data upsert

#' @description Upserts occurence data to NaTron.

#' @param data Structured and mapped occurence table to be upserted (see \code{?str_map_occ()}).
#' @param conn Database connection object with write permissions (see \code{?natron_connect}).

#' @family upsert functions

#' @return Pushes and upserts data to database. Returns nothing.

#' @examples
#' \dontrun{
#' upsert_occ(data = myOccurences, conn = myConnection)
#' }
#'
#' @import RPostgreSQL
#'
#' @export




upsert_occ <- function(data, conn){


  # get column names from NaTron
  tableinfo <- RPostgreSQL::dbGetQuery(conn,
                                       "select column_name
                        from information_schema.columns
                        where table_name = 'Occurrences'
                        ;")


  # check that they are equal
  if(!identical(tableinfo$column_name, colnames(data))) stop("The column in your data don't perfectly match those in NaTron")


  # append to tha NaTron table
  RPostgreSQL::dbWriteTable(conn, c("data", "Locations"),
                            value = data,
                            row.names = FALSE,
                            append = T)



}

