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
#'

upsert_events <- function(data, conn){
  # write to tables to 'temporary' schema
  RPostgreSQL::dbSendQuery(conn,"DROP TABLE IF EXISTS temp_event_import;")
  RPostgreSQL::dbWriteTable(conn, "temp_event_import",
               value = data, row.names = FALSE)

  # UPSERT event table
  # some extra comments.....
  RPostgreSQL::dbSendQuery(conn,"INSERT INTO data.\"Events\"(
              \"eventID\", \"dataSchemaID\", \"collectionID\", \"NaTron_datasetID\", \"locationID\",
              \"samplingProtocolID\", \"samplingEffort\", \"eventDate\", \"dateQualifier\",
              \"samplingDuration\", \"sampleNumber\", \"recordedBy\", \"sampleSizeUnit\",
              \"sampleSizeValue\", \"fieldNumber\", \"eventRemarks\",
              \"minimumDistanceAboveSurfaceInMeters\",
              \"maximumDistanceAboveSurfaceInMeters\", \"roundNumber\", \"seasonNumber\",
              \"periodNumber\", experiment
  )
              SELECT  CAST(\"eventID\" AS uuid), CAST(\"dataSchemaID\" AS uuid),
              CAST(\"collectionID\" AS uuid),
              CAST(\"NaTron_datasetID\" AS uuid), CAST(\"locationID\" AS uuid),
              CAST(\"samplingProtocolID\" AS uuid), CAST(\"samplingEffort\" AS integer),
              CAST(\"eventDate\" AS timestamp without time zone),
              CAST(\"dateQualifier\" as character varying),
              CAST(\"samplingDuration\" AS numeric), CAST(\"sampleNumber\" AS character varying),
              CAST(\"recordedBy\" AS character varying), CAST(\"sampleSizeUnit\" AS character varying),
              CAST(\"sampleSizeValue\" AS numeric), CAST(\"fieldNumber\" AS character varying),
              CAST(\"eventRemarks\" AS text),
              CAST(\"minimumDistanceAboveSurfaceInMeters\" AS numeric),
              CAST(\"maximumDistanceAboveSurfaceInMeters\" AS numeric),
              CAST(\"roundNumber\" AS character varying),
              CAST(\"seasonNumber\" AS character varying),
              CAST(\"periodNumber\" AS character varying),
              CAST(\"experiment\" AS character varying)

              FROM temp.temp_event_import

              ON CONFLICT
              (\"eventID\") DO UPDATE SET
              \"dataSchemaID\" = EXCLUDED.\"dataSchemaID\",
              \"collectionID\" = EXCLUDED.\"collectionID\",
              \"NaTron_datasetID\" = EXCLUDED.\"NaTron_datasetID\",
              \"locationID\" = EXCLUDED.\"locationID\",
              \"samplingProtocolID\" = EXCLUDED.\"samplingProtocolID\",
              \"samplingEffort\" = EXCLUDED.\"samplingEffort\",
              \"eventDate\" = EXCLUDED.\"eventDate\",
              \"dateQualifier\" = EXCLUDED.\"dateQualifier\",
              \"samplingDuration\" = EXCLUDED.\"samplingDuration\",
              \"sampleNumber\" = EXCLUDED.\"sampleNumber\",
              \"recordedBy\" = EXCLUDED.\"recordedBy\",
              \"sampleSizeUnit\" = EXCLUDED.\"sampleSizeUnit\",
              \"sampleSizeValue\" = EXCLUDED.\"sampleSizeValue\",
              \"fieldNumber\" = EXCLUDED.\"fieldNumber\",
              \"eventRemarks\" = EXCLUDED.\"eventRemarks\",
              \"minimumDistanceAboveSurfaceInMeters\" = EXCLUDED.\"minimumDistanceAboveSurfaceInMeters\",
              \"maximumDistanceAboveSurfaceInMeters\" = EXCLUDED.\"maximumDistanceAboveSurfaceInMeters\",
              \"roundNumber\" = EXCLUDED.\"roundNumber\",
              \"seasonNumber\" = EXCLUDED.\"seasonNumber\",
              \"periodNumber\" = EXCLUDED.\"periodNumber\",
              experiment= EXCLUDED.experiment
              ;")

  # Drop temporary tables
  RPostgreSQL::dbSendQuery(conn,"DROP TABLE IF EXISTS temp_event_import;")
}

