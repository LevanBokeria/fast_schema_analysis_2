# Description ############################





# Global setup ###########################

rm(list=ls())

source('./scripts/utils/load_all_libraries.R')


file_location <- 'jatos_gui_downloads'

# Start reading the files ##################

# Get the file mapping prolific IDs with randID
prol_to_rand <- read_csv('../../../levan/ownCloud/Cambridge/PhD/projects/fast_schema_mapping/prolific_metadata/prol_id_to_rand_id.csv')

# Get a list of all files in the folder
incoming_files <- list.files(paste0('./data/',file_location,'/incoming_data/'))

prol_ids <- c()

for (iFile in incoming_files){
        
        print(iFile)
        
        # Parse it
        my_data <- read_file(paste0('./data/',file_location,'/incoming_data/',iFile))
        
        # Find the data submission module
        start_loc <- str_locate(my_data, 'data_submission_start---')[2]
        end_loc   <- str_locate(my_data, '---data_submission_end]')[1]
        
        # Get that string
        json_content <- substr(my_data,start_loc+1,end_loc-1)
        
        # Decode that string
        json_decoded <- fromJSON(json_content)
        
        print(json_decoded$prolific_ID)  
        
        # Find the rand_id of this person
        iRand_id <- prol_to_rand$rand_id[prol_to_rand$prol_id == json_decoded$prolific_ID]
        
        # Substitute that ID in the json_content
        json_content <- str_replace_all(json_content,json_decoded$prolific_ID,iRand_id)
        
        # Save the data submission module output
        fileConn <- file(paste0('./data/',iRand_id,'.txt'))
        writeLines(json_content,fileConn)
        close(fileConn)

        
}