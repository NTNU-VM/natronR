

#************************************#
# MAP LOCATIONS                   ####
#************************************#



#' @title View locations on a map
#' @description  \code{map_locations} takes all locations from your data and plots them on a map type of your choice.

#' @param data New data you wish to plot
#' @param zoom Resolution. 10-12 is a good range. Higher numbers creates long handeling times.
#' @param  maptype Type of map you want to use. Options available are "terrain", "terrain-background", "satellite", "roadmap", "hybrid" (google maps), "terrain", "watercolor", and "toner" (stamen maps). Defaults to "hybrid".

#' @return Map

#' @import ggmap
#' @import ggplot2
#'
#' @examples
#' map_locations(data = myLocationTable)

#' #Or plot it vertically like this:
#' map_locations(data = myLocationTable, vertical = T)
#'
#' #Compare coordinates from twp datasets:
#' scan <- radius_scan(locationTable = myLocationTable, conn = conn, radius = 8000)
#' map_locations(data = myLocationTable, compare = scan)

#' @export



map_locations_old <- function(data, zoom, maptype = "hybrid") {

width <- max(data$decimalLongitude)-min(data$decimalLongitude)+0.1
depth <- max(data$decimalLatitude)-min(data$decimalLatitude)+0.1

left <- min(data$decimalLongitude)
bottom <- min(data$decimalLatitude)
right <- max(data$decimalLongitude)
top <- max(data$decimalLatitude)

box_map <- ggmap::get_map(location =
              c(left-width/4,
                bottom-depth/4,
                right+width/4,
                top+depth/4),
              zoom=zoom,
              maptype=maptype)

d <- data.frame(lat=data$decimalLatitude, lon=data$decimalLongitude)




p <- ggmap::ggmap(box_map) +
  ggplot2::geom_point(data=d, aes(lon,lat),
      col='red', shape = 4) ## At least I think geom_point takes from ggplot, not ggmap


return(p)
}


