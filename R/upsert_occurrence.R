# ----------------------------------------------#
# Upsert occurence table                         ####
# ----------------------------------------------#

#' @title Occurence data upsert

#' @description Upserts occurence data to Natron.

#' @param data Structured and mapped occurence table to be upserted (see \code{?str_map_occ()}).
#' @param con Database connection object with write permissions (see \code{?natron_connect}).

#' @family upsert functions

#' @return Pushes and upserts data to database. Returns nothing.

#' @examples
#' upsert_occ(data = myOccurences, conn = myConnection)
#'
#' @import RPostgreSQL
#'
#' @export




upsert_occ <- function(data, conn){
  RPostgreSQL::dbSendQuery(conn,"DROP TABLE IF EXISTS temp_occurrence_import;")

  RPostgreSQL::dbWriteTable(conn, "temp_occurrence_import", append = TRUE,
               value = data, row.names = FALSE)

  # update or insert occurrence table
  RPostgreSQL::dbSendQuery(conn,"INSERT INTO data.\"Occurrences\"(
              \"occurrenceID\", \"occurrenceStatus\",
              \"eventID\", \"catalogNumber\", \"recordNumber\", \"taxonID\",
              \"typeStatus\", \"identificationQualifier\", preparations,
              \"storingObjectID\", \"basisOfRecord\", \"identifiedBy\", year,
              age, \"lifeStage\", \"occurrenceCondition\", sex, \"organismQuantityType\",
              \"organismQuantity\", \"estimatedIndividualCount\", \"individualCount\",
              \"registrationDate\", \"isProof\", \"proofDate\",
              \"accessRights\", \"publishDate\", \"occurrenceRemarks\", \"preparationBy\",
              \"preparationYear\", habitat,\"organismName\")
              SELECT
              CAST(\"occurrenceID\" AS uuid),
              \"occurrenceStatus\", CAST(\"eventID\" AS uuid), \"catalogNumber\",
              CAST(\"recordNumber\" AS integer), CAST(\"taxonID\" AS uuid), \"typeStatus\",
              \"identificationQualifier\", preparations, CAST(\"storingObjectID\" AS uuid),
              \"basisOfRecord\", \"identifiedBy\",  CAST(year AS integer), CAST(age AS integer),
              \"lifeStage\", \"occurrenceCondition\", sex, \"organismQuantityType\", \"organismQuantity\",
              CAST(\"estimatedIndividualCount\" AS integer), CAST(\"individualCount\" AS integer),
              CAST(\"registrationDate\" AS date), CAST(\"isProof\" AS integer),
              CAST(\"proofDate\" AS date), \"accessRights\", CAST(\"publishDate\" AS date),
              CAST(\"occurrenceRemarks\" AS text), \"preparationBy\", CAST(\"preparationYear\" AS integer),
              habitat, \"organismName\"
              FROM data.temp_occurrence_import
              ON CONFLICT (\"occurrenceID\") DO UPDATE SET
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
              \"individualCount\" = EXCLUDED.\"individualCount\",
              \"registrationDate\" = EXCLUDED.\"registrationDate\", \"isProof\" = EXCLUDED.\"isProof\",
              \"proofDate\" = EXCLUDED.\"proofDate\", \"accessRights\" = EXCLUDED.\"accessRights\",
              \"publishDate\" = EXCLUDED.\"publishDate\",
              \"occurrenceRemarks\" = EXCLUDED.\"occurrenceRemarks\",
              \"preparationBy\" = EXCLUDED.\"preparationBy\",
              \"preparationYear\" = EXCLUDED.\"preparationYear\", habitat = EXCLUDED.habitat,
              \"organismName\" = EXCLUDED.\"organismName\"
              ;")


  # Drop temporary tables
  dbSendQuery(conn,"DROP TABLE IF EXISTS temp_occurrence_import;")
}

