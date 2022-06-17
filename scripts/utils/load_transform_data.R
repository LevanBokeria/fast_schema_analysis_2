# Description ##############################

# Helper function to load the long form data and tranform columns as needed

# Global setup #############################

source('./scripts/utils/load_all_libraries.R')

## long form data ------------------------

### Load the long-form data ======================
long_data <- import('./results/preprocessed_data/block_results_long_form.csv')

### Transform data ====================
long_data <- long_data %>%
        mutate(across(c(ptp,
                        condition,
                        arrangement,
                        block,
                        block_trial_idx,
                        hidden_pa_img,
                        hidden_pa_img_type,
                        hidden_pa_img_row_number_across_blocks,
                        border_dist_closest,
                        border_dist_summed),as.factor)) %>%
        filter(!condition %in% c('practice','practice2'))

## summary data --------------------------------------

if (file.exists('./results/data_summary.csv')){
        
        data_summary <- import('./results/data_summary.csv')
        
        data_summary <- data_summary %>%
                mutate(across(c(ptp,
                                 condition,
                                 type),as.factor))
        
}