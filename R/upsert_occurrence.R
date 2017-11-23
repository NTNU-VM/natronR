# UPSERT functions

# takes as input an R object exactly formated to the database table
# ([tablename]_data, and an RPostgreSQL connetion object with write
# permissions (conn).

#' Upsert occurrence into Natron database.
#'
#' @param con Database connection object with write permissions.
#' @param occurrence_data Occurrence data to be upserted.
#' @return Pushes and upserts data to database.
#' @examples
#'
#' To come.
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

