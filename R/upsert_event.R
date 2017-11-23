# UPSERT event

# takes as input an R object exactly formated to the database table
# ([tablename]_data, and an RPostgreSQL connetion object with write
# permissions (conn).

#' Upserts event data into natron database.
#'
#' @param con Database connection object with write permissions.
#' @param event_data Event data to be upserted.
#' @return Pushes and upserts data to database.
#' @examples
#'
#' To follow.
#'
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

