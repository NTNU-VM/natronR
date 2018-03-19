

#************************************#
# GET NEW LOCATIONS                 ####
#************************************#



#' @title Generate new locations
#' @description  This next function lets you remove newLocations from the 'possible_matches' table if you think the new locations should be imported into Natron instead of matched with existing ones. The newLocations not removed will not be upserted to NaTron, instead we will get the locationIDs from the altermnative locations and use them in the event table.

#' @param matched_localities output from location_check - List of localities with pre-matching locality already in database
#' @param new_localities output from location_check - List of new localities
#' @param  matched_localities_toimport:        a vector of the localities which have a match in Natron but you still want to import as new (i.e. new localities, but there is an existing locality within the pre-specified radius)
#' @return 3 data frames - 1 with localities that did not need changing, 1 with those that did, 1 with all combined
#' @export


# Testing
#matched_localities <- MyLocationCheck$possible_matches
#new_localities <- MyLocationCheck$no_matches
#matched_localities_toimport <- MyLocationCheck$possible_matches[1:10,1]


#-----------------------------------------------###
# Function starts                   -----------####
#-----------------------------------------------###


get_new_loc <- function(matched_localities = NA, new_localities, matched_localities_toimport = NA){
                    require(dplR)

  # Split the locations table into 'new' and 'pre-existing'
  if(missing(matched_localities)) {
            new_localities <- new_localities
  }else{
  # Add new localities from the matched_localities to import into new localities
  new_localities_matched <- subset(matched_localities, (matched_localities$newLocality %in% matched_localities_toimport))

  # Gets all matched localities minus those that are to be imported as new
  preexisting_localities <- subset(matched_localities, !(matched_localities$newLocality %in% matched_localities_toimport))

  # Get locationIDs for the chosen pre-existing localities. We get them from Natron
  preexisting_localities$locationID <- matched_localities$locationID[match(preexisting_localities$newLocality, matched_localities$newLocality)]

  # Put new_localities_matched into new_localities format
  all_new_localities <- data.frame(matrix(ncol = length(natron_tableinfo$column_name), nrow = nrow(new_localities_matched)),stringsAsFactors=FALSE)
  colnames(all_new_localities) <- natron_tableinfo$column_name
  all_new_localities$locality <- new_localities_matched$newLocality
  all_new_localities$decimalLatitude <- new_localities_matched$newLat
  all_new_localities$decimalLongitude <- new_localities_matched$newLong

  all_new_localities <- rbind(all_new_localities,new_localities)
  }



  # create UUID as locationIDs for the new localities
                    # adding UUID to new locations:
                    ug <- uuid.gen();
                    myLength <- nrow(all_new_localities);
                    uuids <- character(myLength);
                    for(i in 1:myLength){
                      uuids[i] <- ug()};
                    all_new_localities$locationID <- as.numeric(all_new_localities$locationID);
                    all_new_localities$locationID <- uuids

                    location_table <- rbind(
                      rename(preexisting_localities[,c("newLocality","locationID")],locality=newLocality),
                             all_new_localities[,c("locality","locationID")] )

                    print(
                      "************************************************************\n
The 'new_localities' dataframe is ready to be upserted\ninto Natron using the location_upsert function.\n
If you hade any, then a dataframe with the 'preexisting_localities'\nis created which can be used un the event_upsert function to\n get the correct locationIDs into the event table\n
    *************************************************************")
return(list(preexisting_localities = preexisting_localities,new_localities = all_new_localities, location_table = location_table))



}


