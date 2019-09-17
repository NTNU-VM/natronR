
# ----------------------------------------------#
# Compare scientific names against NaTron    ####
# ----------------------------------------------#

#' @title Compare scientific names against NaTron
#'
#' @description This functions checks the scientificNames column in your dataset against the Taxa register in NaTron and return a warning when there are species not in the register (either due to misspelling, synonyms, etc.)

#' @param names A vector of scientific species names.
#' @param conn DB connection with access permission (see \code{natron_connect()}).
#'

#' @return Returns a dataframe with your species list alongside the three best gueses for taxon in NaTron

#' @import RPostgreSQL
#' @import stringdist
#'
#' @examples
#' \dontrun{
#' data("setesdal")
#' myConnection <- natron_connect("YOUR-USERNAME-HERE")
#'
#' myNames <- comp_names(
#'     names = setesdal$scientificName,
#'     conn = myConnection)
#'
#' View(myNames)
#' }

#' @export




#-------------------------------------------------#
# Start                              ----------####
#-------------------------------------------------#


comp_names <- function(names, conn) {

  # get species list
    spList <- data.frame(
    mySpeciesList = unique(names))

  # get the Taxa list from NaTron.
  fullTaxaList <- RPostgreSQL::dbGetQuery(conn,
                       "select \"scientificName\",   \"taxonID\"
                        from lib.\"Taxa\"
                        ;")

  spList$perfectMatch <- fullTaxaList$scientificName[match(
                                 spList$mySpeciesList,
                                 fullTaxaList$scientificName)]

  # now get imperfect matches
  missing <- spList$mySpeciesList[is.na(spList$perfectMatch)]
  d <- expand.grid(missing, fullTaxaList$scientificName)
  names(d) <- c("myMissingNames","natronNames")
  d$dist <- stringdist::stringdist(d$myMissingNames,d$natronNames, method="jw")

spList2 <- spList
spList2$fuzzyMatch1 <- as.character("")
spList2$fuzzyMatch2 <- as.character("")

  for(i in unique(d$myMissingNames)){
    temp <- d[d$myMissingNames==i, ]
    spList2$fuzzyMatch1[spList2$mySpeciesList==i] <- as.character(temp$natronNames[which.min(temp$dist)])
    temp <- temp[-which.min(temp$dist),]
    spList2$fuzzyMatch2[spList2$mySpeciesList==i] <- as.character(temp$natronNames[which.min(temp$dist)])

  }


  return(spList2)

}





