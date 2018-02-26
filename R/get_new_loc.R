

#************************************#
# GET NEW LOCATIONS                 ####
#************************************#



#' @title Generate new locations
#' @description  This next function lets you remove newLocations from the 'possible_matches' table if you think the new locations should be imported into Natron instead of matched with existing ones. The newLocations not removed will not be upserted to NaTron, instead we will get the locationIDs from the altermnative locations and use them in the event table.

#' @param matched_localities output from location_check - List of localities with pre-matching locality already in database
#' @param new_localities output from location_check - List of new localities
#' @param  matched_localities_toimport:        a vector of the localities which have a match in Natron but you still want to import (i.e. new localities, but there is an existing locality within the pre-specified radius)
#' @return 3 data frames - 1 with localities that did not need changing, 1 with those that did, 1 with all combined
#' @export


#-----------------------------------------------###
# Function starts                   -----------####
#-----------------------------------------------###


get_new_loc <- function(matched_localities = NA, new_localities, matched_localities_toimport = NA){
                    require(dplR)

  # Split the locations table into 'new' and 'pre-existing'
  if(missing(matched_localities)) {
            new_localities <- new_localities
  }else{
    # produces all localities that are matched and should not be imported as new
  locality_check2 <- subset(matched_localities, !(matched_localities$newLocality %in% unique(matched_localities$newLocality)[matched_localities_toimport]))
  # gets rid of any possible matched localities in new_localities
  new_localities2  <- subset(new_localities, !(new_localities$locality %in% locality_check2$newLocality))
  #
  preexisting_localities    <- subset(new_localities, !(new_localities$locality %in% new_localities2$locality))


                      # get locationIDs for the chosen pre-existing localities. We get them from Natron
  preexisting_localities$locationID <- matched_localities$locationID[match(preexisting_localities$locality, matched_localities$newLocality)]
                       }

  # create UUID as locationIDs for the new localities
                    # adding UUID to new locations:
                    ug <- uuid.gen();
                    myLength <- nrow(new_localities2);
                    uuids <- character(myLength);
                    for(i in 1:myLength){
                      uuids[i] <- ug()};
                    new_localities2$locationID <- as.numeric(new_localities2$locationID);
                    new_localities2$locationID <- uuids;

                    all_localities <- rbind(new_localities2,preexisting_localities)

return(list(preexisting_localities = preexisting_localities,new_localities = new_localities2
            ,all_localities = all_localities))

  print(
    "************************************************************\n
The 'new_localities' dataframe is ready to be upserted\ninto Natron using the location_upsert function.\n
If you hade any, then a dataframe with the 'preexisting_localities'\nis created which can be used un the event_upsert function to\n get the correct locationIDs into the event table\n
    *************************************************************")

}


