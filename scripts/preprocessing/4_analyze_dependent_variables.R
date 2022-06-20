# Description ############################

# This code will load the long form data and analyze the following variables:
# - average block 2 mouse error
# - learning rate across both blocks. 

# The data will be saved as a csv file

# Global setup ###########################

rm(list=ls())

source('./scripts/utils/load_all_libraries.R')
source('./scripts/utils/load_transform_data.R')

# Flags
saveData <- T


# Start analysis ##########################################

## Block 2 average -----------------------------------------

### All PAs ========================================

data_summary_all_pas <- long_data %>%
        filter(block == 2) %>%
        group_by(ptp,
                 counterbalancing,
                 condition) %>%
        summarise(n_trials = n(),
                  block_2_mouse_error_mean = mean(mouse_error, na.rm = T),
                  block_2_mouse_error_sd   = sd(mouse_error, na.rm = T),
                  type = 'all_pa') %>% 
        ungroup()

### Near and Far separately ========================================

data_summary_near_far_pas <- long_data %>%
        filter(block == 2,
               hidden_pa_img_type %in% c('near','far')) %>% 
        group_by(ptp,
                 counterbalancing,
                 condition,
                 hidden_pa_img_type) %>%
        summarise(n_trials = n(),
                  block_2_mouse_error_mean = mean(mouse_error, na.rm = T),
                  block_2_mouse_error_sd   = sd(mouse_error, na.rm = T)) %>% 
        ungroup() %>%
        rename(type = hidden_pa_img_type)

### Combine =============================
data_summary <- NULL
data_summary <- bind_rows(data_summary_all_pas,
                          data_summary_near_far_pas)

# Clean the extra variables
remove(data_summary_all_pas,data_summary_near_far_pas)

# Save the data #####################################

if (saveData){
        
        write_csv(data_summary,
                  './results/data_summary.csv')
        
}