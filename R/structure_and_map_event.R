
# ----------------------------------------------#
# Structure and map event table              ####
# ----------------------------------------------#


#' @title Structure and map event table
#' @description This function takes your event-based dataset and returns an event dataframe ready to be upserted.
#' @param data Dataframe to be structured. The column names need to match the NaTron terms (DwC).
#' @param conn NaTron connection object with access permission (see \code{?natron_connect}).
#' @param location_table location table for your data (see \code{?location_table()}).
#' @return Dataframe: event table, mapped to the location table and ready to be upserted to Natron.
#' @import RPostgreSQL
#' @import dplyr
#' @details \code{data} needs to contain a column called dateQualifierstating the resolution of the eventDate. Options are "Only year", "Only month-year", "Complete date", "0-No date", or "Doubtful day/month". Discrepancies returns an error.
#' @examples
#' \dontrun{
#' data("setesdal")
#' myConnection <- natron_connect("YOUR-USERNAME")
#' myLocationTable(data = setesdal, conn = myConnection)
#' #map_location(myLocationTable)
#' myEvents <- str_map_events(data = setesdal,
#'                            conn = myConnection,
#'                            location_table = myLocationTable)
#' }

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






  # DATES #
  # check for correctly entered dataQualifyer
  if(sum(event_data$dateQualifier %in% c("Only year", "Only month-year", "Complete date", "0-No date", "Doubtful day/month")) < nrow(event_data)) stop("ERROR: dateQualifyer contains entries that differ from the standardised format. See ?str_map_events")



  # Standardise date formats to ISO8601
  event_data$eventDate <- format_iso_8601(parse_iso_8601(event_data$eventDate))

    # remove the end
  event_data$eventDate <- gsub(pattern = "+00:00",
                               replacement = "",
                               x = event_data$eventDate,
                               fixed = T)
    # remove the T
  event_data$eventDate <- gsub(pattern = "T",
                               replacement = " ",
                               x = event_data$eventDate,
                               fixed = T)

  cat(
    "
  ************************************************************\n
  The following columns have been transferred to the events table\n

    ")

  print(event_terms)


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



  if(any(duplicated(location_table$locality)))     cat("\n*****\nWarning: the location table has duplicates in the 'locality' column . This NEEDS TO BE UNIQUE. Don't upsert this event table as it is now!\n*****")

  if(anyNA(event_data$locationID))    cat("\n*****\nWarning: Not all rows have assigned locationIDs\n*****")

  if(anyNA(event_data$eventID))    cat("\n*****\nWarning: Not all rows have assigned eventIDs\n*****")


  return(event_data)
}


