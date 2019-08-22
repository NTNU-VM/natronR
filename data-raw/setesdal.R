## This is the code that generates the 'Setesdal' dataset



# This script takes a wide dataset as it typically looks originally
# (after some standardisation of column names). The rows are event and species are
# in seperate columns. It creates UUID per event and then transposes the data.
# UUIDs for locations are not made here. Insted a unique locations name (globally or at least Natron unique)
# and matches it to existing location names in the database.


# get example data - standardised, flat and wide data
library(readxl)
library(dplyr)
library(dplR)
library(reshape2)


wide_data <- read_excel("OldData/flat_data_dummy_std.xlsx",
                        sheet = "Sheet1")


# create EventIDs
ug <- dplR::uuid.gen()
myLength <- nrow(wide_data)
uuids <- character(myLength)
for(i in 1:myLength){
  uuids[i] <- ug()
}
any(duplicated(uuids))

wide_data$eventID <- uuids




# special for this dataset is that species absenses are recorded explicitly - so the zeros should be saved!
# the resulting long format will become very long indeed.


long_data <- reshape2::melt(wide_data,
                            id.vars = c(1:5, 67:72),
                            measure.vars = c(6:68),
                            variable.name = "scientificName",
                            value.name = "organismQuantity")


dim(long_data) # very long - 88.2k rows

long_data$organismQuantity <- as.numeric(long_data$organismQuantity)
long_data$organismQuantity[is.na(long_data$organismQuantity)] <- 0
long_data$organismQuantityType <- "Percentage of sub-quadrats (16) where species was present"

head(long_data)


#save example dataset with 150 random rows
setesdal <- long_data[sample(1:nrow(long_data), 150, replace = FALSE),]
write_csv(setesdal, "data-raw/setesdal.csv")




usethis::use_data(setesdal, overwrite = TRUE)
