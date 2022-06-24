# Description ############################


# Global setup ###########################

rm(list=ls())

source('./scripts/utils/load_all_libraries.R')
source('./scripts/utils/load_transform_data.R')

# Flags
saveData <- F


# Start combining data ######################################################

ml_learning_rate <- import('./results/learning_rate_fits_matlab.csv')


data_summary <- merge(data_summary,
                      ml_learning_rate,
                      by = c('ptp',
                             'condition',
                             'hidden_pa_img_type'),
                      all.x = T) 

## Calculate predicted y values and merge with the long form data ------------
learning_and_intercept_each_participants_y_hat_ml <-
        ml_learning_rate %>%
        group_by(ptp_trunk,
                 condition,
                 border_dist,
                 new_pa_status,
                 accuracy_type) %>% 
        mutate(y_hat_i_c_ml = list(fit_learning_and_intercept(c(intercept,learning_rate,asymptote),
                                                              seq(1:8),
                                                              seq(1:8),
                                                              'fit',
                                                              accuracy_type,
                                                              FALSE)),
               new_pa_img_row_number_across_sessions = list(seq(1:8))) %>%
        unnest(c(y_hat_i_c_ml,
                 new_pa_img_row_number_across_sessions)) %>% 
        select(c(ptp_trunk,
                 condition,
                 border_dist,
                 new_pa_status,
                 accuracy_type,
                 y_hat_i_c_ml,
                 new_pa_img_row_number_across_sessions)) %>%
        ungroup()

mean_by_rep_all_types_long <- merge(mean_by_rep_all_types_long,
                                    learning_and_intercept_each_participants_y_hat_ml,
                                    by = c('ptp_trunk',
                                           'condition',
                                           'border_dist',
                                           'new_pa_status',
                                           'accuracy_type',
                                           'new_pa_img_row_number_across_sessions'),
                                    all = TRUE)