# UPSERT functions

# takes as input an R object exactly formated to the database table
# ([tablename]_data, and an RPostgreSQL connetion object with write
# permissions (conn).

#' Upserts location into Natron database
#'
#' @param con Database connection object with write permissions
#' @param locations Location to be upserted.
#' @return Pushes and upserts data to database
#' @examples
#'
#' Still to come
#'
#'
#' @import dplyr
#' @import dbplyr
#' @import RPostgreSQL
#'
#' @export
#'
# takes as input an R object exactly formated to the database table
# ([tablename]_data, and an RPostgreSQL connetion object with write
# permissions (conn).


# function UPSERT m_dataset----
f_upsert_m_dataset <- function(conn,m_dataset_data){
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_m_dataset_data_import;")
  dbWriteTable(conn, "temp_m_dataset_data_import", append = TRUE,
               value = m_dataset_data, row.names = FALSE)
  # update or insert m_dataset_data table
  dbSendQuery(conn,"INSERT INTO nofa.m_dataset(
              \"datasetID\", \"datasetName\", \"institutionCode\",
              \"rightsHolder\", \"accessRights\", \"license\", \"informationWithheld\",
              \"dataGeneralizations\", \"bibliographicCitation\", \"datasetComment\",
              \"ownerInstitutionCode\")
              SELECT
              \"datasetID\", \"datasetName\",
              \"institutionCode\", \"rightsHolder\",
              \"accessRights\",
              \"license\", \"informationWithheld\",
              \"dataGeneralizations\", \"bibliographicCitation\",
              \"datasetComment\", \"ownerInstitutionCode\"
              FROM temporary.temp_m_dataset_data_import
              ON CONFLICT (\"datasetID\") DO UPDATE SET
              \"datasetName\" = EXCLUDED.\"datasetName\",
              \"institutionCode\" = EXCLUDED.\"institutionCode\",
              \"rightsHolder\" = EXCLUDED.\"rightsHolder\",
              \"accessRights\" = EXCLUDED.\"accessRights\",
              \"license\" = EXCLUDED.\"license\",
              \"informationWithheld\" = EXCLUDED.\"informationWithheld\",
              \"dataGeneralizations\" = EXCLUDED.\"dataGeneralizations\",
              \"bibliographicCitation\" = EXCLUDED.\"bibliographicCitation\",
              \"datasetComment\" = EXCLUDED.\"datasetComment\",
              \"ownerInstitutionCode\" = EXCLUDED.\"ownerInstitutionCode\"
              ;")


  # Drop temporary tables
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_m_dataset_data_import;")
}
