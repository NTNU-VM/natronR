#install.packages("postGIStools")
#install.packages("RPostgreSQL")
#install.packages("readxl")
#install.packages("rstudioapi")

install.packages("sp")

library(sp)
library(postGIStools)
library(RPostgreSQL)
library(readxl)

pg_drv<-dbDriver("PostgreSQL")
pg_db <- "natron"
pg_user <- ""
pg_password <- ""
pg_host <- "vm-srv-zootron.vm.ntnu.no"

con<-dbConnect(pg_drv,dbname=pg_db,user=rstudioapi::askForPassword("Please enter your user name"), password=rstudioapi::askForPassword("Please enter your psw"),host=pg_host)

#load norwegian alphabet
#both encoding support the norwegian alphabet, the first one works best
postgresqlpqExec(con, "SET client_encoding = 'windows-1252'")
#postgresqlpqExec(con, "SET client_encoding = 'UTF_8'")

#create a data frame correspondig to the column name and datatype
data_frm <- data.frame(matrix(ncol = 4, nrow = 0))
x <- c("locationID", "locality", "cartographicCoordinates","modifiedBy")
colnames(data_frm) <- x
data_frm[nrow(data_frm) + 1,] = c("1",as.character("test???01"), "32VNr1234512345", pg_user)
data_frm[nrow(data_frm) + 1,] = c("2","test???02", "32 V 512345 7012345", pg_user)
data_frm[nrow(data_frm) + 1,] = c("3","test???03", "N64 E12", pg_user)
data_frm[nrow(data_frm) + 1,] = c("4","test???04", "N64 55.555 E12 55.555", pg_user)
data_frm[nrow(data_frm) + 1,] = c("5","test???04", "N64 55 55.5 E12 55 55.5" , pg_user)
data_frm[nrow(data_frm) + 1,] = c("3","test???03", "N64.55555 W12.55555", pg_user)

#upload data frame with corresponding column name and datatype
#the file must contain the following columns: "locationID", "locality", "cartographicCoordinates","modifiedBy"
#the "cartographicCoordinates" must be standardized as follow
# metric mgrs: "32VNR1234512345"
#        utm: "32 V 0512345 7012345"
# geodesic "hddd.ddddd": "N64.62022 E12.29833"
#          "hddd mm.mmm": "N64 37.213 E12 17.900"
#          "hddd mm ss.s": "N64 37 12.8 E12 17 54.0"
#datatype must be text
##data_frm <- read.csv("c:\\zootron\\testLocations.csv", header = TRUE, sep = ";", quote = "\"", dec = ".", fill = TRUE)
##data_frm <- read.csv("M:\\XFILES\\WORK\\Dolmen\\Maps\\Tovdalen\\Locations.csv", header = TRUE, sep = ";", quote = "\"", dec = ".", fill = TRUE)
data_frm <- read.csv("c:\\temp\\test.csv", header = TRUE, sep = ";", quote = "\"", dec = ".", fill = TRUE)
data_frm <- read.csv("c:\\temp\\StasjonerDanmark.csv", header = TRUE, sep = ";", quote = "\"", dec = ".", fill = TRUE)

#show data frame content
data_frm

#erase previous user request
postgresqlpqExec(con,paste0('DELETE FROM temp.look_up_coordinates where "modifiedBy" like \'', pg_user, '\'', sep="") )

#send request to the database server
for (i in 1:nrow(data_frm))
{
  print(i)
  write_sql <- paste('Insert into temp.look_up_coordinates ("locationID",locality,"cartographicCoordinates","modifiedBy")
                     values (\'',as.character(data_frm[i,"locationID"]),
                     '\',\'',as.character(data_frm[i,"locality"]),
                     '\',\'',as.character(data_frm[i,"cartographicCoordinates"]),'\',\'',pg_user,'\')',sep="")
  postgresqlpqExec(con,write_sql)
  next
}

#get converted coordinates with the nearest geographic location: fjord, catchement, river, place name and elevation with geometry.
coordinates_list <- dbGetQuery(con,paste0('select * from public.look_up_coordinates_view where "modifiedBy" like \'', pg_user, '\'', sep=""))

coordinates_list <- dbGetQuery(con,paste0('select "rowNumber","locationID","higherGeographyID","country","county","administrativeName","locality","siteNumber","stationNumber","minimumElevationInMeters","verbatimCoordinateSystem","verbatimCoordinates","decimalLatitude","decimalLongitude","geodeticDatum","locationName","distance_To_LocationName","fjordName","distance_To_Fjord","catchmentName","riverName","distance_To_River","waterBody","distance_To_Lake","modifiedBy" from public.look_up_coordinates_view where "modifiedBy" like \'', pg_user, '\'', sep=""))

coordinates_list

write.csv(coordinates_list, file = "c:\\temp\\coordinates_list.csv",row.names=FALSE)
