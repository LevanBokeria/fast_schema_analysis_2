# Description ############################



# Global setup ###########################

rm(list=ls())

source('./scripts/utils/load_all_libraries.R')


block_results_all_ptp <- NULL
listings_all_ptp      <- NULL
break_rt_all_ptp      <- NULL
# Start reading the files ##################

# Get a list of all files in the folder
incoming_files <- list.files('./data/',pattern = '*.txt')

for (iFile in incoming_files){
        
        ## Preparing -------------------------------------
        print(iFile)
        
        # Parse it
        my_data <- read_file(paste0('./data/',iFile))
        
        # Decode that string
        json_decoded <- fromJSON(my_data)
        
        print(json_decoded$prolific_ID)  
        
        ## Get the performance output df -----------------------

        block_results <- as_tibble(
                json_decoded$outputData$block_results_hidden_pa_learning
        )

        block_results <- block_results %>%
                select(!c('internal_node_id','trial_index','trial_type',
                          starts_with('display_information')))

        # Sanity check
        n_trials_per_block <- block_results %>%
                filter(!condition %in% c('practice','practice2')) %>% 
                group_by(condition,block) %>%
                summarise(n = n())
        if (any(n_trials_per_block$n != 24)){
                stop('n trials per block is wrong!')
        }
        
        # All the mutations
        block_results <- block_results %>%
                mutate(across(.cols = c(block,condition,hidden_pa_img),as.factor),
                       correct = as.numeric(correct),
                       mouse_dist_cb = abs(mouse_clientX - pa_center_x) +
                               abs(mouse_clientY - pa_center_y),
                       mouse_error = sqrt(
                               (mouse_clientX - pa_center_x)^2 +
                                       (mouse_clientY - pa_center_y)^2
                       ),                       
                       )
        
        block_results <- block_results %>%
                mutate(ptp = json_decoded$prolific_ID, .before = rt,
                       ptp = as.factor(ptp))
        
        # Add a row counter for each occurrence of a hidden_pa_img, 
        # within that condition and within that block
        block_results <- block_results %>%
                group_by(condition,block,hidden_pa_img) %>%
                mutate(hidden_pa_img_row_number = row_number()) %>%
                ungroup()
        
        # Add a row counter for each occurrence of a hidden_pa_img, 
        # within that condition, across the two blocks
        block_results <- block_results %>%
                group_by(condition,hidden_pa_img) %>%
                mutate(hidden_pa_img_row_number_across_blocks = row_number()) %>%
                ungroup()
        
        
        # Add trial index counter for each block
        block_results <- block_results %>%
                group_by(condition,block) %>%
                mutate(block_trial_idx = row_number(),
                       .after = block) %>%
                ungroup()
        
        
        # Mark which ones are close to the border of the board
        block_results <- block_results %>%
                mutate(dist_border_l = corr_col - 1,
                       dist_border_r = 12 - corr_col,
                       dist_border_t = corr_row - 1,
                       dist_border_b = 12 - corr_row) %>%
                rowwise() %>%
                mutate(border_dist_closest = min(dist_border_l,
                                                 dist_border_r,
                                                 dist_border_t,
                                                 dist_border_b),
                       border_dist_summed = min(dist_border_l,dist_border_r) + 
                                            min(dist_border_t,dist_border_b))
        
        # Combine the data across participants
        block_results_all_ptp <- bind_rows(block_results_all_ptp,block_results)
        
        
        ## Final Feedback -----------------------
        
        # Add up feedback
        curr_ptp_feedback <- 
                as_tibble(
                        json_decoded[["outputData"]][["debriefing"]][["response"]]
                )
        
        # Remove the NA row, from the experiment explanation page
        curr_ptp_feedback <- curr_ptp_feedback %>%
                filter(rowSums(is.na(curr_ptp_feedback)) != ncol(curr_ptp_feedback))
        
        # Add the participant ID
        curr_ptp_feedback <- curr_ptp_feedback %>%
                mutate(ptp = json_decoded$prolific_ID, .before = Q0,
                       ptp = as.factor(ptp))        
        # Concatenate
        feedback_all_ptp <- bind_rows(feedback_all_ptp,curr_ptp_feedback)
        
        
        ## Hidden/Visible item names ----------------------
        
        # Congregate listing of the hidden and visible items
        curr_ptp_listings <- bind_rows(
                json_decoded$outputData$break_results[[1]][3,],
                json_decoded$outputData$break_results[[3]][3,],
                json_decoded$outputData$break_results[[5]][3,],
                json_decoded$outputData$break_results[[7]][3,],
                json_decoded$outputData$break_results[[9]][3,]
        )
        curr_ptp_listings <- curr_ptp_listings %>%
                select(rt,response) %>%
                mutate(ptp = json_decoded$prolific_ID)
        curr_ptp_listings$boards <- unique(block_results$condition)[3:7]
        
        listings_all_ptp <- bind_rows(listings_all_ptp,curr_ptp_listings)
        
        
        ## Times spent at each break --------------------
        curr_ptp_break_rt <- NULL
        curr_ptp_break_rt[1] <- json_decoded$prolific_ID
        for (iBreak in seq(1,11)){
                curr_ptp_break_rt[iBreak+1] <- sum(json_decoded$outputData$break_results[[iBreak]]$rt,na.rm=T)
        }
        
        break_rt_all_ptp[iPtp,] <- curr_ptp_break_rt
}

block_results_all_ptp <- block_results_all_ptp %>%
        reorder_levels(condition, order = c('practice',
                                            'practice2',
                                            'schema_c',
                                            'schema_ic',
                                            'landmark_schema',
                                            'random_locations',
                                            'no_schema'))

names(feedback_all_ptp) <- c('ptp',
                             'Clear instructions?',
                             'Notice schema_C',
                             'Notice schema_IC',
                             'Notice landmarks',
                             'Notice random',
                             'Strategy?',
                             'Did visible ones help or hinder?',
                             'Anything else')

# Create condition orders ################
condition_orders <- tibble(.rows = 7)

all_ptp <- unique(block_results_all_ptp$ptp)

for (iPtp in as.vector(all_ptp)){
        iPtp
        condition_orders[iPtp] <-
                unique(
                        block_results_all_ptp$condition[
                                block_results_all_ptp$ptp==iPtp
                        ])
}

# Save everything #######################
if (saveDataCSV){
        write_csv(block_results_all_ptp,'./results/pilots/preprocessed_data/block_results_long_form.csv')
        write_csv(feedback_all_ptp,'./results/pilots/preprocessed_data/feedback_all_ptp.csv')
        write_csv(listings_all_ptp,'./results/pilots/preprocessed_data/listings_all_ptp.csv')
        write.csv(break_rt_all_ptp,'./results/pilots/preprocessed_data/break_rt_all_ptp.csv',
                  row.names = FALSE)
}