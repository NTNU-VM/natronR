

dat <- read.csv("flat_data_dummy_std_long.csv")
head(dat)
names(dat)


library(dplyr)
require(dplR)



# Location Table
locationTable_X <- select(dat,
                          -scientificName,
                          -organismQuantity,
                          -eventDate)
locationTable <- locationTable_X[!duplicated(locationTable_X$locality),]

levels(locationTable$locality)
any(duplicated(locationTable$locality))
head(locationTable)
# 200 unique locations

# IF the locations exist in Natron we dont need to upload this table.
# Then the location information will be tied to the event automatically
# via the 'Location' column.

# IF locations are not in Natraon, then we can put them there, with UUIDs:
ug <- uuid.gen()

myLength <- nrow(locationTable)
uuids <- character(myLength)
for(i in 1:myLength){
  uuids[i] <- ug()
}
length(unique(uuids)) == 200 # TRUE, UUIDs are unique with high probability

# Add UUID to the location table (bypassing this step here):
locationTable$locationID <- uuids







# The eventTable
# create a temporary "tempEventID" that we can use to shrink the eventTable and to
# match UUID with the occurence table:

dat$tempEventID <- paste0(dat$locality, dat$eventDate)


eventTable_X <- select(dat,
                     locality,
                     eventDate,
                     tempEventID)

eventTable <- eventTable_X[!duplicated(eventTable_X$tempEventID),]
# resulting on 1400 unique events (site x date combinations)

myLength <- nrow(eventTable)
uuids <- character(myLength)
for(i in 1:myLength){
  uuids[i] <- ug()
}
eventTable$eventID <- uuids

dim(eventTable)
head(eventTable)






# Occurence Table
occurenceTable <- select(dat,
                         scientificName,
                         organismQuantity,
                         tempEventID)

# add link to eventTable (multiple occurences per event)
occurenceTable$eventID <- eventTable$eventID[match(occurenceTable$tempEventID, eventTable$tempEventID)]

# add unique identifier to each occurence
myLength <- nrow(occurenceTable)
uuids <- character(myLength)
for(i in 1:myLength){
  uuids[i] <- ug()
}
occurenceTable$occurenceID <- uuids
dim(occurenceTable)
head(occurenceTable)

# 'value' is not a DwC term:
colnames(occurenceTable)[colnames(occurenceTable) == "value"] <- "occurenceQuantity"

# ideally we should also add OccurenceQuantityType, and to the eventCore we should add samplingProtocol stuff as well...


# export it all :
eventTable <- select(eventTable,-tempEventID)
occurenceTable <- select(occurenceTable, -tempEventID)


#write.csv(locationTable, file = "dummy_locationTable.csv", row.names = FALSE)
#write.csv(eventTable, file = "dummy_eventTable.csv", row.names = FALSE)
#write.csv(occurenceTable, file = "dummy_occurenceTable.csv", row.names = FALSE)

