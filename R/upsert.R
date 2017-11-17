# UPSERT functions

# takes as input an R object exactly formated to the database table
# ([tablename]_data, and an RPostgreSQL connetion object with write
# permissions (conn).

#' Upsert events ... must be revritten
#'
#' @param con database connection object
#' @param event_data connetion object with write permissions (conn)
#' @return push and upsert data to database
#' @examples
#'
#' f_upsert_event(conn,event_data)
#'
#' @import dplyr
#' @import dbplyr
#' @import RPostgreSQL
#'
#' @export
#'

f_upsert_event <- function(conn,event_data){
  # write to tables to 'temporary' schema
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_event_import;")
  dbWriteTable(conn, "temp_event_import",
               value = event_data, row.names = FALSE)

  # UPSERT event table
  # some extra comments.....
  dbSendQuery(conn,"INSERT INTO nofa.event(
              \"eventRemarks\", \"recordedBy\", \"referenceID\", \"projectID\", \"impRef\",
              \"samplingTaxaRange\", \"dateStart\", \"dateEnd\", \"samplingEffort\",
              \"sampleSizeUnit\", \"sampleSizeValue\", \"samplingProtocol\", reliability,
              \"fieldNumber\", \"fieldNotes\", \"datasetID\", \"eventID\", \"locationID\",
              modified, \"parentEventID\", \"eventDateQualifier\",
              \"minimumDepthInMeters\",\"maximumDepthInMeters\"
  )
              SELECT  \"eventRemarks\", \"recordedBy\", CAST(\"referenceID\" AS integer),
              CAST(\"projectID\" AS integer), \"impRef\",
              CAST(\"samplingTaxaRange\" AS integer[]), CAST(\"dateStart\" AS date),
              CAST(\"dateEnd\" AS date), CAST(\"samplingEffort\" AS integer),
              \"sampleSizeUnit\", CAST(\"sampleSizeValue\" AS numeric),
              \"samplingProtocol\", reliability,
              \"fieldNumber\", \"fieldNotes\", \"datasetID\", CAST(\"eventID\" AS uuid),
              CAST(\"locationID\" AS uuid),
              CAST(modified AS date), CAST(\"parentEventID\" AS uuid), \"eventDateQualifier\",
              CAST(\"minimumDepthInMeters\" AS numeric),
              CAST(\"maximumDepthInMeters\" AS numeric)
              FROM temporary.temp_event_import
              ON CONFLICT (\"eventID\") DO UPDATE SET
              \"eventRemarks\" = EXCLUDED.\"eventRemarks\",
              \"recordedBy\" = EXCLUDED.\"recordedBy\",
              \"referenceID\" = EXCLUDED.\"referenceID\",
              \"projectID\" = EXCLUDED.\"projectID\",
              \"impRef\" = EXCLUDED.\"impRef\",
              \"samplingTaxaRange\" = EXCLUDED.\"samplingTaxaRange\",
              \"dateStart\" = EXCLUDED.\"dateStart\",
              \"dateEnd\" = EXCLUDED.\"dateEnd\",
              \"samplingEffort\" = EXCLUDED.\"samplingEffort\",
              \"sampleSizeUnit\" = EXCLUDED.\"sampleSizeUnit\",
              \"sampleSizeValue\" = EXCLUDED.\"sampleSizeValue\",
              \"samplingProtocol\" = EXCLUDED.\"samplingProtocol\",
              \"reliability\" = EXCLUDED.\"reliability\",
              \"fieldNumber\" = EXCLUDED.\"fieldNumber\",
              \"fieldNotes\" = EXCLUDED.\"fieldNotes\",
              \"datasetID\" = EXCLUDED.\"datasetID\",
              \"locationID\" = EXCLUDED.\"locationID\",
              \"modified\" = EXCLUDED.\"modified\",
              \"parentEventID\" = EXCLUDED.\"parentEventID\",
              \"eventDateQualifier\" = EXCLUDED.\"eventDateQualifier\",
              \"minimumDepthInMeters\" = EXCLUDED.\"minimumDepthInMeters\",
              \"maximumDepthInMeters\"= EXCLUDED.\"maximumDepthInMeters\"
              ;")
  # Drop temporary tables
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_event_import;")
}# UPSERT functions

# takes as input an R object exactly formated to the database table
# ([tablename]_data, and an RPostgreSQL connetion object with write
# permissions (conn).


# function UPSERT occurrences----
f_upsert_occurrence <- function(conn,occurrence_data){
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_occurrence_import;")
  dbWriteTable(conn, "temp_occurrence_import", append = TRUE,
               value = occurrence_data, row.names = FALSE)
  # update or insert occurrence table
  dbSendQuery(conn,"INSERT INTO nofa.occurrence(
              \"establishmentRemarks\", \"occurrenceRemarks\", \"verifiedDate\",
              \"verifiedBy\", \"impRef\", \"organismQuantity\", \"organismQuantityType\",
              \"individualCount\", \"occurrenceStatus\", \"establishmentMeans\",
              \"spawningCondition\", \"spawningLocation\", sex, \"lifeStage\", \"reproductiveCondition\",
              \"recordNumber\", \"eventID\", \"occurrenceID\", \"fieldNumber\", modified,
              \"taxonID\", \"ecotypeID\", \"populationTrend\")
              SELECT
              \"establishmentRemarks\", \"occurrenceRemarks\", CAST(\"verifiedDate\" AS date),
              \"verifiedBy\", \"impRef\", CAST(\"organismQuantity\" AS numeric),
              \"organismQuantityType\", CAST(\"individualCount\" AS numeric),
              \"occurrenceStatus\", \"establishmentMeans\",
              \"spawningCondition\", \"spawningLocation\", sex, \"lifeStage\",
              \"reproductiveCondition\", \"recordNumber\",
              CAST(\"eventID\" AS uuid), CAST(\"occurrenceID\" AS uuid),
              \"fieldNumber\", CAST(modified AS DATE),
              \"taxonID\", CAST(\"ecotypeID\" AS integer), \"populationTrend\"
              FROM temporary.temp_occurrence_import
              ON CONFLICT (\"occurrenceID\") DO UPDATE SET
              \"establishmentRemarks\" = EXCLUDED.\"establishmentRemarks\",
              \"occurrenceRemarks\" = EXCLUDED.\"occurrenceRemarks\",
              \"verifiedDate\" = EXCLUDED.\"verifiedDate\",
              \"verifiedBy\" = EXCLUDED.\"verifiedBy\",
              \"impRef\" = EXCLUDED.\"impRef\",
              \"organismQuantity\" = EXCLUDED.\"organismQuantity\",
              \"individualCount\" = EXCLUDED.\"individualCount\",
              \"occurrenceStatus\" = EXCLUDED.\"occurrenceStatus\",
              \"establishmentMeans\" = EXCLUDED.\"establishmentMeans\",
              \"spawningCondition\" = EXCLUDED.\"spawningCondition\",
              \"spawningLocation\" = EXCLUDED.\"spawningLocation\",
              \"sex\" = EXCLUDED.\"sex\",
              \"lifeStage\" = EXCLUDED.\"lifeStage\",
              \"reproductiveCondition\" = EXCLUDED.\"reproductiveCondition\",
              \"recordNumber\" = EXCLUDED.\"recordNumber\",
              \"eventID\" = EXCLUDED.\"eventID\",
              \"fieldNumber\" = EXCLUDED.\"fieldNumber\",
              \"modified\" = EXCLUDED.\"modified\",
              \"taxonID\" = EXCLUDED.\"taxonID\",
              \"ecotypeID\" = EXCLUDED.\"ecotypeID\",
              \"populationTrend\" = EXCLUDED.\"populationTrend\"
              ;")


  # Drop temporary tables
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_occurrence_import;")
}



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
