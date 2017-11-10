# Function takes inn as flattended datatable with
# both terms/colums corresponding exactly to the
# database columns and datatypes and returns
# a list of dataframes for each database table ready to use with
# the send_to_db.R script

# Currently works only against the event and the occurrence table

# inputt:
# 1. standarized and checked data.frame (may be flattended)
# 2. db connection with read permission
#
# output:
# list with event and occurrence tables as dataframes
#
# TODO! in order to support flat-structure output
# Select distinct on everything else than occurrences

f_structure_and_map <- function(flatt_data,conn) {
  require(tidyverse)

  #..................................................
  # Get db table info
  #..................................................
  tableinfo <- dbGetQuery(conn,
                          "select table_name,column_name,data_type
                          from information_schema.columns
                          where table_name = 'event' OR
                          table_name = 'occurrence' OR
                          table_name = 'm_dataset'
                          ;"
  )

  fk_info <- dbGetQuery(conn,
                        "SELECT
                        tc.constraint_name, tc.table_name, kcu.column_name,
                        ccu.table_name AS foreign_table_name,
                        ccu.column_name AS foreign_column_name
                        FROM
                        information_schema.table_constraints AS tc
                        JOIN information_schema.key_column_usage AS kcu
                        ON tc.constraint_name = kcu.constraint_name
                        JOIN information_schema.constraint_column_usage AS ccu
                        ON ccu.constraint_name = tc.constraint_name
                        WHERE constraint_type = 'FOREIGN KEY' AND
                        tc.table_name='occurrence' OR
                        tc.table_name='event' OR
                        tc.table_name='m_dataset'
                        ;")

  ###################################################
  # structure and map m_dataset table ---------------
  ###################################################

  # select terms for event table (NB! no need to select distinct in this case)
  m_dataset_db_terms <- tableinfo$column_name[tableinfo$table_name=="m_dataset"]
  m_dataset_terms <- names(flatt_data)[names(flatt_data) %in% m_dataset_db_terms]
  m_dataset_data_temp <- flatt_data[m_dataset_terms]

  # create empty dataframe with all event table terms
  m_dataset_data <- data.frame(matrix(ncol = length(m_dataset_db_terms), nrow = 0),stringsAsFactors=FALSE)
  colnames(m_dataset_data) <- m_dataset_db_terms

  # rowbind event data from import to the empty data.frame
  # in order to create generic event table for import
  m_dataset_data <- bind_rows(m_dataset_data,m_dataset_data_temp)

  # NOTE! Empty columns turns out as bolean (logical data type).
  # Need to convert these to character before db import
  is_character <- as.character(lapply(m_dataset_data,mode))=="logical"
  m_dataset_data[is_character] <- lapply(m_dataset_data[,is_character], as.character)


  ####################################################
  # structure and map event table -------------------
  ####################################################

  # select terms for event table
  event_db_terms <- tableinfo$column_name[tableinfo$table_name=="event"]
  event_terms <- names(flatt_data)[names(flatt_data) %in% event_db_terms]
  event_data_temp <- flatt_data[event_terms]


  # create empty dataframe with all event table terms
  event_data <- data.frame(matrix(ncol = length(event_db_terms), nrow = 0),stringsAsFactors=FALSE)
  colnames(event_data) <- event_db_terms

  # rowbind event data from import to the empty data.frame
  # in order to create generic event table for import
  event_data <- bind_rows(event_data,event_data_temp)

  # NOTE! Empty columns turns out as bolean (logical data type).
  # Need to convert these to character before db import
  is_character <- as.character(lapply(event_data,mode))=="logical"
  event_data[is_character] <- lapply(event_data[,is_character], as.character)


  # set modified data if not given
  event_data$modified <- as.character(event_data$modified)
  event_data$modified <- ifelse(is.na(event_data$modified),
                                as.character(Sys.Date()),
                                event_data$modified)

  ###################################################
  # structure and map occurrence table --------------
  ###################################################

  # select terms for occurrence table
  occurrence_db_terms <- tableinfo$column_name[tableinfo$table_name=="occurrence"]
  occurrence_terms <- names(flatt_data)[names(flatt_data) %in% occurrence_db_terms]
  occurrence_data_temp <- flatt_data[occurrence_terms]
  occurrence_data_temp$modified <- Sys.Date()

  # create empty dataframe with all event table terms
  occurrence_data <- data.frame(matrix(ncol = length(occurrence_db_terms), nrow = 0))
  colnames(occurrence_data) <- occurrence_db_terms

  # rowbind event data from import to the empty data.frame
  occurrence_data <- bind_rows(occurrence_data,occurrence_data_temp)

  # NOTE! Empty columns turns out as bolean (logical data type).
  # Need to convert these to character before db import
  is_character <- as.character(lapply(occurrence_data,mode))=="logical"
  occurrence_data[is_character] <- lapply(occurrence_data[,is_character], as.character)

  # set modified date to data if not given
  occurrence_data$modified <- as.character(occurrence_data$modified)
  occurrence_data$modified <- ifelse(is.na(occurrence_data$modified),
                                     as.character(Sys.Date()),
                                     occurrence_data$modified)

  # set modified date to data if not given
  mapped_data <- list(occurrence_data=occurrence_data,
                      event_data=event_data,
                      m_dataset_data=m_dataset_data)

}
