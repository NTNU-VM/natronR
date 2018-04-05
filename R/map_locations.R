

#************************************#
# MAP LOCATIONS                 ####
#************************************#



#' @title Map all locations
#' @description  Takes all locations from your data and lots them on a map type of your chouce

#' @param data New data you wish to plot
#' @param zoom Determins how far in you want to zoom on the area. Runs from 1 to 15.
#' @param  maptype Type of map you want to use. Defaults to "hybrid".
#' @return Map
#' @export

#flat_data_dummy_std_long <- read_csv("flat_data_dummy_std_long.csv")
#data <- flat_data_dummy_std_long

#map_locations(data,8,"hybrid")

map_locations <- function(data, zoom, maptype = "hybrid") {

width <- max(data$decimalLongitude)-min(data$decimalLongitude)
depth <- max(data$decimalLatitude)-min(data$decimalLatitude)

left <- min(data$decimalLongitude)
bottom <- min(data$decimalLatitude)
right <- max(data$decimalLongitude)
top <- max(data$decimalLatitude)

box_map <- get_map(location = c(left-width/4,bottom-depth/4,right+width/4,top+depth/4), zoom=zoom, maptype=maptype)
d <- data.frame(lat=data$decimalLatitude, lon=data$decimalLongitude)

p <- ggmap(box_map) + geom_point(data=d, aes(lon,lat),col='red')
return(p)
}


