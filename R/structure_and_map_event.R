
# ----------------------------------------------#
# Structure and map                          ####
# ----------------------------------------------#


#' @title Structure and map event table
#' @description Function takes inn a flattended datatable with both terms/colums corresponding exactly to the database columns and datatypes and returns an event dataframe ready to be upserted.
#' @param data Flat data to be structured.
#' @param conn NaTRON connection object with access permission (see \code{?natron_connect}).
#' @param location_table location table for flattened data (needs to contain UUIDs as locationIDs).
#' @return Dataframe: event table, mapped to the location table and ready to be upserted to Natron.
#' @import RPostgreSQL
#' @import dplyr
#' @examples
#' data("setesdal")
#' myConnection <- natron_connect("myUserName")
#' myLocationTable(data = setesdal, conn = myConnection)
#' #map_location(myLocationTable)
#' myEvents <- str_map_events(data = setesdal, conn = myConnection, location_table = myLocationTable)

#' @export



str_map_events <- function(data, conn, location_table) {

  # Get all terms in one table
  tableinfo <- RPostgreSQL::dbGetQuery(conn,
                          "select table_name,column_name,data_type
                        from information_schema.columns
                        where table_name = 'Events' OR
                        table_name = 'Occurrences' OR
                        table_name = 'Locations'
                        ;")

  # select terms for event table

  event_db_terms <- tableinfo$column_name[tableinfo$table_name=="Events"]
  event_terms <- names(data)[names(data) %in% event_db_terms]
  event_terms[length(event_terms)+1] <- "locality"
  event_data_temp <- data[event_terms]







  # create empty dataframe with all event table terms
  event_data <- data.frame(matrix(ncol = length(event_db_terms), nrow = 0),stringsAsFactors=FALSE)
  colnames(event_data) <- event_db_terms



  # rowbind event data from import to the empty data.frame
  # in order to create generic event table for import
  event_data <- bind_rows(event_data,event_data_temp)

  # Empty columns turns out as bolean (logical data type).
  # Need to convert these to character before db import
  is_character <- as.character(lapply(event_data,mode))=="logical"


  event_data[is_character] <- lapply(event_data[,is_character], as.character)

  event_data$locationID <- location_table$locationID[match(event_data$locality,location_table$locality)]



  # set modified data if not given
  event_data$modified <- as.character(event_data$modified)
  event_data$modified <- ifelse(is.na(event_data$modified),
                                as.character(Sys.Date()),
                                event_data$modified)
  # remove locality column
  event_data <- dplyr::select(event_data,-locality)



  cat(
    "
  ************************************************************\n
  The following columns have been cut away\nfrom the original dataset to whan making the event table.\n")

  print(names(data)[!names(data) %in% event_terms])

  cat(
    "\n
  ***Please check that this is correct.***\n \n
  If you think one of these should be in the event table,\n
  then edit that column name in 'data' to match the corresponding \n
  NaTRON column name. The available NaTRON columns for\n
  event tables are:\n" )

  print(event_db_terms)



  if(any(duplicated(location_table$locality)))     cat("\n*****\nWarning: there are duplicates in the 'locality' column. This NEEDS TO BE UNIQUE. Don't upsert this event table as it is now!\n*****")

  if(anyNA(event_data$locationID))    cat("\n*****\nWarning: Not all rows have assigned locationIDs\n*****")


  return(event_data)
}


