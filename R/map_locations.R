

#************************************#
# MAP LOCATIONS                   ####
#************************************#



#' @title View locations on a map
#' @description  \code{map_locations} takes the coordinates from up to two location tables and plots them on two maps with different zoom.

#' @param data Location table with decimal degree coordinates that you wish to plot. Only DwC terms are recogniced (decimalLatitude and decimalLongitude)
#' @param compare Location table with decimal degree coordinates that you wish to plot alongside the 'data'.
#' @param zoom1 Resolution of the smallest scale map. Defaults to 11. Increasing the resolutions also increases computation time.
#' @param zoom2 Resolution of the largest scale map. Defaults to 8. Increasing the resolutions also increases computation time.

#' @param vertical Should the plots be arranged vertically (T/F)? Defults to FALSE.
#' @return A map (gtable)
#' @examples
#' # Plotting coordinates from one dataset:
#'
#' decimalLatitude <- c(59.02936, 59.03352, 59.04758) #note that the name must be DwC
#' decimalLongitude <- c(7.278987, 7.267469, 7.184718)
#' myData <- data.frame(decimalLatitude, decimalLongitude)
#' map_locations(data = myData)
#' map_locations(data = myData, vertical = T)
#'
#'
#' # Add another location table to compare against:
#'
#' decimalLatitude2 <- c(59.03347)
#' decimalLongitude2 <- c(7.268134)
#' myData2 <- data.frame(decimalLatitude = decimalLatitude2,
#'                       decimalLongitude = decimalLongitude2)
#'
#' map_locations(data = myData, compare = myData2)
#' @import ggmap
#' @import ggplot2
#' @import gridExtra
#' @export


map_locations <- function(data, compare, zoom1 = 11, zoom2 = 8, vertical = FALSE) {


ifelse(!hasArg(compare),
  d <- data.frame(lat   = data$decimalLatitude,
                  lon   = data$decimalLongitude,
                  group = rep("data", nrow(data))),
  d <- data.frame(lat   = c(data$decimalLatitude, compare$decimalLatitude),
                  lon   = c(data$decimalLongitude, compare$decimalLongitude),
                  group = c(rep(c("data", "compare"), c(nrow(data),nrow(compare))))))




  width <- max(d$lon)-min(d$lon)+0.01
  depth <- max(d$lat)-min(d$lat)+0.01

  left   <- min(d$lon)
  bottom <- min(d$lat)
  right  <- max(d$lon)
  top    <- max(d$lat)

  box_map <- ggmap::get_map(location =
                              c(left-width/4,
                                bottom-depth/4,
                                right+width/4,
                                top+depth/4),
                            zoom=zoom1,
                            maptype="hybrid")
  box_map2 <- ggmap::get_map(location =
                              c(left-width*10,
                                bottom-depth*10,
                                right+width*10,
                                top+depth*10),
                            zoom=zoom2,
                            maptype="hybrid")


if(!hasArg(compare)){
  p1 <- ggmap::ggmap(box_map) +
    ggplot2::geom_point(data=d, aes(lon,lat),
                        col='red', shape = 4)
  p2 <- ggmap::ggmap(box_map2) +
    ggplot2::geom_point(data=d, aes(lon,lat),
                        col='red', shape = 4)
}

if(hasArg(compare)){
    p1 <- ggmap::ggmap(box_map) +
      ggplot2::geom_point(data=d, aes(lon,lat,
                                      shape = group), size = 2)+
      theme(legend.position="bottom")+
      scale_shape_manual(values = c(16,4))
    p2 <- ggmap::ggmap(box_map2) +
      ggplot2::geom_point(data=d, aes(lon,lat,
                                      shape = group), size = 2)+
      theme(legend.position="bottom")+
      scale_shape_manual(values = c(16,4))
  }

  ifelse(vertical == FALSE, ncol <- 2, ncol <- 1)
  p3 <- gridExtra::grid.arrange(p1, p2, ncol=ncol)

  return(p3)
}


