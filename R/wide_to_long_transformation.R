

# Transposing dummy flat data to become long format

# This script takes a wide dataset as it typically looks originally
# (after some standardisation of column names). The rows are event and species are
# in seperate columns. It creates UUID per event and then transposes the data.
# UUIDs for locations are not made here. Insted a unique locations name (globally or at least Natron unique)
# and matches it to existing location names in the database.


# get example data - standardised, flat and wide data
library(readxl)
library(dplyr)
require(dplR)




wide_data <- read_excel("flat_data_dummy_std.xlsx",
                                  sheet = "Sheet1")
names(wide_data)

#
# craetinf EventIDs
ug <- uuid.gen()
myLength <- nrow(wide_data)
uuids <- character(myLength)
for(i in 1:myLength){
  uuids[i] <- ug()
}
any(duplicated(uuids))

wide_data$eventID <- uuids




# special for this dataset is that species absenses are recorded explicitly - so the zeros should be saved!
# the resulting long format will become very long indeed.

library(reshape2)
long_data <- melt(wide_data,
                      id.vars = c(1:5, 67:72),
                      measure.vars = c(6:70),
                      variable.name = "scientificName",
                      value.name = "organismQuantity")


dim(long_data) # very long - 91k rows

# I remove the zeros -  although thats perhaps the wrong thing to do, this is just a test
long_data$organismQuantity <- as.numeric(long_data$organismQuantity)
long_data <- filter(long_data,
                       organismQuantity>0 &
                       !is.na(organismQuantity))

head(long_data)


dim(long_data) # 14761 rows


write.csv(long_data, file = "flat_data_dummy_std_long.csv", row.names = FALSE)
