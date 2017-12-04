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
  dbSendQuery(conn,"INSERT INTO data.\"Occurrences\"(
              \"occurrenceID\", \"previousOccurrenceID\", \"occurrenceStatus\",
              \"eventID\", \"catalogNumber\", \"recordNumber\", \"taxonID\",
              \"typeStatus\", \"identificationQualifier\", preparations,
              \"storingObjectID\", \"basisOfRecord\", \"identifiedBy\", year,
              age, \"lifeStage\", \"occurrenceCondition\", sex, \"organismQuantityType\",
              \"organismQuantity\", \"estimatedIndividualCount\", \"individualCount\",
              \"modifiedBy\", \"registrationDate\", \"isProof\", \"proofDate\",
              \"accessRights\", \"publishDate\", \"occurrenceRemarks\", \"preparationBy\",
              \"preparationYear\", habitat,\"organismName\", modified, \"toDelete\")
              SELECT
              CAST(\"occurrenceID\" AS uuid), CAST(\"previousOccurrenceID\" AS uuid),
              \"occurrenceStatus\", CAST(\"eventID\" AS uuid), \"catalogNumber\",
              CAST(\"recordNumber\" AS integer), CAST(\"taxonID\" AS uuid), \"typeStatus\",
              \"identificationQualifier\", preparations, CAST(\"storingObjectID\" AS uuid),
              \"basisOfRecord\", \"identifiedBy\",  CAST(year AS integer), CAST(age AS integer),
              \"lifeStage\", \"occurrenceCondition\", sex, \"organismQuantityType\", \"organismQuantity\",
              CAST(\"estimatedIndividualCount\" AS integer), CAST(\"individualCount\" AS integer),
              \"modifiedBy\", CAST(\"registrationDate\" AS date), CAST(\"isProof\" AS integer),
              CAST(\"proofDate\" AS date), \"accessRights\", CAST(\"publishDate\" AS date),
              CAST(\"occurrenceRemarks\" AS text), \"preparationBy\", CAST(\"preparationYear\" AS integer),
              habitat, \"organismName\", CAST(\"modified\" AS timestamp without time zone),
              CAST(\"toDelete\" AS integer)
              FROM data.temp_occurrence_import
              ON CONFLICT (\"occurrenceID\") DO UPDATE SET
              \"previousOccurrenceID\" = EXCLUDED.\"previousOccurrenceID\",
              \"occurrenceStatus\" = EXCLUDED.\"occurrenceStatus\", \"eventID\" = EXCLUDED.\"eventID\",
              \"catalogNumber\" = EXCLUDED.\"catalogNumber\", \"recordNumber\" = EXCLUDED.\"recordNumber\",
              \"taxonID\" = EXCLUDED.\"taxonID\", \"typeStatus\" = EXCLUDED.\"typeStatus\",
              \"identificationQualifier\" = EXCLUDED.\"identificationQualifier\",
              preparations = EXCLUDED.preparations, \"storingObjectID\" = EXCLUDED.\"storingObjectID\",
              \"basisOfRecord\" = EXCLUDED.\"basisOfRecord\", \"identifiedBy\" = EXCLUDED.\"identifiedBy\",
              year = EXCLUDED.year, age = EXCLUDED.age, \"lifeStage\" = EXCLUDED.\"lifeStage\",
              \"occurrenceCondition\" = EXCLUDED.\"occurrenceCondition\", sex = EXCLUDED.sex,
              \"organismQuantityType\" = EXCLUDED.\"organismQuantityType\",
              \"organismQuantity\" = EXCLUDED.\"organismQuantity\",
              \"estimatedIndividualCount\" = EXCLUDED.\"estimatedIndividualCount\",
              \"individualCount\" = EXCLUDED.\"individualCount\", \"modifiedBy\" = EXCLUDED.\"modifiedBy\",
              \"registrationDate\" = EXCLUDED.\"registrationDate\", \"isProof\" = EXCLUDED.\"isProof\",
              \"proofDate\" = EXCLUDED.\"proofDate\", \"accessRights\" = EXCLUDED.\"accessRights\",
              \"publishDate\" = EXCLUDED.\"publishDate\",
              \"occurrenceRemarks\" = EXCLUDED.\"occurrenceRemarks\",
              \"preparationBy\" = EXCLUDED.\"preparationBy\",
              \"preparationYear\" = EXCLUDED.\"preparationYear\", habitat = EXCLUDED.habitat,
              \"organismName\" = EXCLUDED.\"organismName\", \"modified\" = EXCLUDED.\"modified\",
              \"toDelete\" = EXCLUDED.\"toDelete\"
              ;")


  # Drop temporary tables
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_occurrence_import;")
}

