# Description ############################





# Global setup ###########################

rm(list=ls())

source('./scripts/utils/load_all_libraries.R')

# Start reading the files ##################

# Get the file mapping prolific IDs with randID
prol_to_rand <- read_csv('../../../levan/ownCloud/Cambridge/PhD/projects/fast_schema_mapping/prolific_metadata/prol_id_to_rand_id.csv')

# Get a list of all files in the folder
incoming_files <- list.files('./data/jatos_gui_downloads/incoming_data/')

prol_ids <- c()

for (iFile in incoming_files){
        
        print(iFile)
        
        # Parse it
        my_data <- read_file(paste0('./data/jatos_gui_downloads/incoming_data/',iFile))
        
        # Find the data submission module
        start_loc <- str_locate(my_data, 'data_submission_start---')[2]
        end_loc   <- str_locate(my_data, '---data_submission_end]')[1]
        
        # If no data submission module, skip
        if (is.na(start_loc)){
                
                print(print0('No data submission module. Skipping file',
                             iFile))
                next
                
        } else {
                
                json_content <- substr(my_data,start_loc+1,end_loc-1)
                
                json_decoded <- fromJSON(json_content)
                
                print(json_decoded$prolific_ID)  
                
                prol_ids <- append(prol_ids,json_decoded$prolific_ID)
                
        }

}