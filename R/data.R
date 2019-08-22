#' An event-based sampling of vascular plants in Setesdal
#'
#' A dataset from a sheep grazing experiment in Setesdal Norway containing the abundances of vascular plants inside and outside of sheep exclosures.
#'
#' @format A dataframe with 150 rows (a random subset of the original file which is 88k) and 14 variables.
#' \describe{
#' \item{locality}{a unique human-friendly identification of a sampling location}
#' \item{verbatimLocality}{the original location identifier (ie the one on the field sheets)}
#' \item{stationNumber}{sampling plot of which there are 20 per site)}
#' \item{siteNumber}{sheep exclusion treatment (exclosed (no sheep) or browsed (open))}
#' \item{eventDate}{sampling year (2000-2012)}
#' \item{verbatimCoordinateSystem}{the coordinate system used in the field (UTM, unknown zone)}
#' \item{verbatimCoordinates}{original coordinates recorded in the field}
#' \item{decimalLatitude}{latitudinal coordinates (decimal degrees), converted from the verbatim coordinate system}
#' \item{decimalLongitude}{longitudinal coordinates (decimal degrees), converted from the verbatim coordinate system}
#' \item{geodeticDatum}{the datum (WGS84)}
#' \item{eventID}{a globally unique number to identify each event (=sampling occation)}
#' \item{scientificName}{species names of vascular plants}
#' \item{organismQuantity}{abundance meassure. There were sixteen 0.125 x 0.125m sub-quadrats within each 0.5 x 0.5m plot, and the quantity here refers to the percentage of sub-quadrats where the species was recorded.}
#' \item{organismQuantityType}{describes organismQuantity}
#' }
#'
"setesdal"
