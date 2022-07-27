# Description ############################

# This code loads the batch data downloaded from JATOS, and for each prolific ID
# it finds, it will substitute that ID with the randomly generated participant
# Number.


# Global setup ###########################

rm(list=ls())

source('./scripts/utils/load_all_libraries.R')

# Start reading the files ##################

# Get a list of all files in the folder
incoming_files <- list.files('./data/incoming_data/jatos_gui_downloads/')

# Get the prolific ID to rand_id mappings

prol_ids <- import(paste0('../../../',
                          Sys.getenv("USERNAME"),
                          '/ownCloud/Cambridge/PhD/projects/fast_schema_mapping/prolific_metadata/prol_id_to_rand_id.csv'))

for (iFile in incoming_files){
        
        print(iFile)
        
        # Parse it
        my_data <- read_file(paste0('./data/incoming_data/jatos_gui_downloads/',iFile))
        
        # Go through each prolific ID, find it and substitute that in the string
        # Then save the string again.
        
        my_data <- reduce2(prol_ids$prol_id,prol_ids$rand_id, .init = my_data, str_replace_all)
        
        # Now save this file
        fileConn <- file(paste0('./data/anonymized_jatos_data/',iFile))
        writeLines(my_data, fileConn)
        close(fileConn)
        
}