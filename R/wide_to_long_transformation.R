

# Transposing dummy flat data to become long format



# get example data - standardised, flat and wide data
library(readxl)
flat_data_dummy_std <- read_excel("flat_data_dummy_std.xlsx",
                                  sheet = "Sheet1")
names(flat_data_dummy_std)





# special for this dataset is that species absenses are recorded explicitly - so the zeros should be saved!
# the resulting long format will become very long indeed.

library(reshape2)
flat_data_dummy_std_long <- melt(flat_data_dummy_std,
                                 id.vars = c(1:5, 67:71),
                                 measure.vars = c(6:70),
                                 variable.name = "scientificName")


dim(flat_data_dummy_std_long) # very long - 91k rows

# I remove the zeros -  although thats perhaps the wrong thing to do, this is just a test
flat_data_dummy_std_long$value <- as.numeric(flat_data_dummy_std_long$value)
flat_data_dummy_std_long_X <- filter(flat_data_dummy_std_long,
                                     value>0 &
                                       !is.na(value))

head(flat_data_dummy_std_long_X)


dim(flat_data_dummy_std_long_X) # 14761 rows


write.csv(flat_data_dummy_std_long_X, file = "flat_data_dummy_std_long.csv", row.names = FALSE)
