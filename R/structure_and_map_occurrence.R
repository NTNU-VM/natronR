
# ----------------------------------------------#
# Structure and map                          ####
# ----------------------------------------------#

#' Function takes inn a flattended datatable with both terms/colums corresponding exactly to the database columns and datatypes and returns an occurrence dataframe ready to be upserted.
#' @param flatt_data Flatenned data to be structured
#' @param conn DB connection with access permission, can easily be produced using natron_connect script
#' @param location_table location table for flattened data (needs to be run through location_check and get_new_loc).
#' @return Occurrence data that is ready to be upserted to Natron.
#' @import RPostgreSQL

#' @export




#-------------------------------------------------#
# structure and map occurrence table ----------####
#-------------------------------------------------#

str_map_occ <- function(flatt_data,conn, location_table) {

  tableinfo <- RPostgreSQL::dbGetQuery(con,
                          "select table_name,column_name,data_type
                        from information_schema.columns
                        where table_name = 'Events' OR
                        table_name = 'Occurrences' OR
                        table_name = 'Locations'
                        ;")


   # select terms for occurrence table
  occurrence_db_terms <- tableinfo$column_name[tableinfo$table_name=="Occurrences"]
  occurrence_terms <- names(flatt_data)[names(flatt_data) %in% occurrence_db_terms]
  occurrence_terms[length(occurrence_terms)+1] <- "locality"
  occurrence_data_temp <- flatt_data[occurrence_terms]


  # create empty dataframe with all event table terms
  occurrence_data <- data.frame(matrix(ncol = length(occurrence_db_terms), nrow = 0))
  colnames(occurrence_data) <- occurrence_db_terms

  # rowbind event data from import to the empty data.frame
  occurrence_data <- bind_rows(occurrence_data,occurrence_data_temp)
  occurrence_data$locationID <- location_table$locationID[match(occurrence_data$locality,location_table$locality)]

  # NOTE! Empty columns turns out as bolean (logical data type).
  # Need to convert these to character before db import
  is_character <- as.character(lapply(occurrence_data,mode))=="logical"
  occurrence_data[is_character] <- lapply(occurrence_data[,is_character], as.character)

  # set modified date to data if not given
  occurrence_data$modified <- as.character(occurrence_data$modified)
  occurrence_data$modified <- ifelse(is.na(occurrence_data$modified),
                                     as.character(Sys.Date()),
                                     occurrence_data$modified)
  # remove locality column
  occurrence_data <- occurrence_data[,-36]


  return(occurrence_data)

}





