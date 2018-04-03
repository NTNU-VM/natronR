# map_function script, still a mess at the moment
library(readr)
flat_data_dummy_std_long <- read_csv("flat_data_dummy_std_long.csv")
data <- flat_data_dummy_std_long
names(data)
width <- max(data$decimalLongitude)-min(data$decimalLongitude)
depth <- max(data$decimalLatitude)-min(data$decimalLatitude)

left <- min(data$decimalLongitude)
bottom <- min(data$decimalLatitude)
right <- max(data$decimalLongitude)
top <- max(data$decimalLatitude)

box_map <- get_map(location = c(left-width/4,bottom-depth/4,right+width/4,top+depth/4), zoom=5, maptype="hybrid")
d <- data.frame(lat=data$decimalLatitude, lon=data$decimalLongitude)

p <- ggmap(map) + geom_point(data=d, aes(lon,lat))



library(ggmap)
qmap(location = 'norway')
map <- get_map(location = c(2.77,57.33,29.66,71.36), zoom=5, maptype="hybrid")
ggmap(map)
