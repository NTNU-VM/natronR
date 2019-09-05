#************************************#
# Create locations table          ####
#************************************#

#' @title Create locations table
#'
#'
#'
#' @description This function takes as input a standardised flat and long (as opposed to wide formated) dataset and makes the locations table for it, mirroring the structure of the NaTRON locations table.
#'
#' @param data A flattened, long and standardised dataset that you wish to import into NaTron
#' @param conn  A connection object with NaTRON (see \code{?natron_connect})
#' @examples
#' data("setesdal")
#' myConnection <- natron_connect(myUserName)
#' myLocationTable <- location_table(setesdal, myConnection)
#' View(myLocationTable)
#'
#' @return Returns the complete location table as a dataframe consistent with the NaTRON formatting.
#' @import RPostgreSQL
#' @import dplyr
#' @import dplR
#' @export


location_table <- function(data,conn) {

  # -----------------------------------------------#
  # Get db table info---------------------------####
  # -----------------------------------------------#
  # this functions fetches the column names from the NaTRON locations table

  natron_tableinfo <- RPostgreSQL::dbGetQuery(conn,
                                              "select table_name,column_name,data_type
                        from information_schema.columns
                        where table_name =  'Locations'
                        ;")

  # -----------------------------------------------#
  # Make locations lable         ---------------#####
  # -----------------------------------------------#

  # subset local data to match terms used in Natron.
  #OBS, this step deletes without warning(!!) columns that don't match the NaTRON names without saying
  local_terms <- names(data)[names(data) %in% natron_tableinfo$column_name]
  local_data_temp <- data[local_terms]

  # remove duplicate locations to end up with uniqe ones
  local_data_temp_unique <- local_data_temp[!duplicated(paste0(local_data_temp$decimalLongitude,
                                                               local_data_temp$decimalLatitude)),]

# standardising the dataset to look exactly like Natron.
  # - create empty dataframe with the correct number of columns
  local_data_temp_blank <- data.frame(matrix(ncol = length(natron_tableinfo$column_name),
                                             nrow = 0),stringsAsFactors=FALSE)


  # - paste natron column names in correct order
colnames(local_data_temp_blank) <- natron_tableinfo$column_name

  # rowbind local data to the blank data frame
locationTable <- dplyr::bind_rows(
  local_data_temp_blank, local_data_temp_unique
  )

  # create UUID as locationIDs

  ug <- dplR::uuid.gen()
  myLength <- nrow(locationTable)
  uuids <- character(myLength)

for(i in 1:myLength){
  uuids[i] <- ug()
}

  locationTable$locationID <- as.numeric(locationTable$locationID)
  locationTable$locationID <- uuids


cat(
  "
************************************************************\n
The following columns have been cut away\nfrom the original dataset to whan making the location table.


")
print(names(data)[!names(data) %in% local_terms])
cat(
  "\n
***Please check that this is correct.***\n \n
If you think one of these should be in the location table,\n
then edit that column name in 'data' to match the corresponding \n
NaTRON column name. The available NaTRON columns for\n
location tables are:\n
  "
)
print(natron_tableinfo$column_name)

if(anyNA(locationTable$decimalLongitude))       cat("\n*****\nWarning: decimalLongitude contains NAs\n*****")
if(anyNA(locationTable$decimalLatitude))        cat("\n*****\nWarning: decimalLatitude contains NAs\n*****")
if(!is.numeric(locationTable$decimalLongitude)) cat("\n*****\nWarning: decimalLongitude contains non-numeric value(s)\n*****")
if(!is.numeric(locationTable$decimalLatitude))  cat("\n*****\nWarning: decimalLatitude contains non-numeric value(s)\n*****")
if(any(duplicated(locationTable$locality)))     cat("\n*****\nWarning: there are duplicates in the 'locality' column. This NEEDS TO BE UNIQUE\n*****")



return(locationTable)

}
