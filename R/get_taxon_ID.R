#************************************#
# Retrieve taxonIDs from NaTron   ####
#************************************#

#' @title Retrieve taxonIDs from NaTron
#'
#' @description This function macthes scientific species names against the NaTron taxa register and returns the corresponding taxonIDs (UUIDs).
#'
#' @param names A vector of scientific species names. These should already be checked agains the NaTron taxa register to make sure they exist there.
#' @param conn  A connection object with NaTRON (see \code{?natron_connect})

#' @examples
#' \dontrun{
#' # get some data:
#' data("setesdal")
#'
#' # connect to the database
#' myConnection <- natron_connect("YOUR-USERNAME-HERE")
#'
#' # Then get the taxonIDs inserted into the setesdal data:
#' setesdal$taxonID <- get_taxonID(
#'                     names = setesdal$scientificName,
#'                     conn = myConnection)
#'
#' }
#' @return Returns a vector of UUIDs corresponding to the scientific species names given in the \emph{names} argument.
#'
#' @import RPostgreSQL

#' @export

get_taxonID <- function(names, conn){
  taxa <- RPostgreSQL::dbGetQuery(conn,
                        "select \"taxonID\", \"scientificName\"
                        from lib.\"Taxa\"
                        ;")

  theTaxonIDs <- taxa$taxonID[match(names, taxa$scientificName)]



  if(anyNA(theTaxonIDs))  cat("
******** WARNING *******************************************\n
Not all names got correctly assigned taxonIDs.
************************************************************\n
")

  return(theTaxonIDs)
}
