

# Transposing dummy flat data to become long format

library(readxl)
flat_data_dummy_std <- read_excel("flat_data_dummy_std.xlsx",
                                  sheet = "Sheet1")
names(flat_data_dummy_std)


# special for this dataset is that species absenses are recorded explicitly - so the zeros should be saved.
# the resulting long format will become very long indeed.

library(reshape2)
flat_data_dummy_std_long <- melt(flat_data_dummy_std,
                                 id.vars = c(1:5, 67:71),
                                 measure.vars = c(6:70),
                                 variable.name = "scientificName")


dim(flat_data_dummy_std_long) # very long
head(flat_data_dummy_std_long)

write.csv(flat_data_dummy_std_long, file = "flat_data_dummy_std_long.csv", row.names = FALSE)
