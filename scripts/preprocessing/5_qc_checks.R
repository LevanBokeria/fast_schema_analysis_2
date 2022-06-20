# Description ############################

# 1. Check the manual fail table
# 
# 2. Check 1 sec at instructions 
# 
# 3. Check break durations 
# 
# 4. Check missing data %
# 
# 5. Check the percentile of the permuted null distribution
# 
# 6. Check for 1.5IQR rule, relative to non-fail participants!

# Global setup ###########################

rm(list=ls())

source('./scripts/utils/load_all_libraries.R')
source('./scripts/utils/load_transform_data.R')
source('./scripts/utils/qc_checks_permutations.R')

saveDataCSV <- T

# Start the QC analysis ##################

## 1. Manual QC failures ------------------------------

qc_check_debrief_and_errors <- import('./results/qc_check_sheets/qc_check_debrief_and_errors.xlsx') %>%
        select(-reason) %>%
        rename(ptp = participant)

## 2. Instruction times -------------------------------

instruction_rt <- import('./results/preprocessed_data/instructions_rt_all_ptp.csv')

# Check that for each participant, for each page (except the first) have at least 1 second
instructions_summary <- instruction_rt %>%
        filter(page_index != 0) %>% 
        group_by(ptp,
                 test_part,
                 page_index) %>%
        summarise(total_view_time = sum(viewing_time)) %>%
        ungroup()

# Did they fail here?
qc_check_instructions_rt <- instructions_summary %>%
        group_by(ptp) %>%
        summarise(qc_fail_instructions_rt = any(total_view_time < 1000)) %>%
        ungroup()

## 3. Break times -----------------------------------------

max_break_mins_allowed <- 10

break_rt <- import('./results/preprocessed_data/break_rt_all_ptp.csv')

qc_check_break_rt <- break_rt %>%
        group_by(ptp) %>%
        summarise(qc_fail_break_rt = any(
                time_spent_msec > max_break_mins_allowed * 60 * 1000)
                )

## 4. Missing data ---------------------------------------
rt_threshold <- 3
missed_perc_threshold <- 80

long_data <- long_data %>%
        mutate(missed_or_too_fast = case_when(
                is.na(rt) ~ TRUE,
                rt < rt_threshold ~ TRUE,
                TRUE ~ FALSE
        ))

# Now, count

missing_data_summary <- long_data %>%
        group_by(ptp,
                 condition) %>%
        summarise(n_trials = n(),
                  n_missed_or_fast = sum(missed_or_too_fast),
                  perc_missed_or_fast = n_missed_or_fast * 100 / n_trials) %>%
        ungroup()

qc_fail_missing_or_fast <- missing_data_summary %>%
        group_by(ptp) %>%
        summarise(qc_fail_missing_or_fast = any(perc_missed_or_fast > missed_perc_threshold))

## 5. Check against permuted null distributions -------------------------

qc_check_permutation <- permute_mouse_error(long_data,
                                        load_existing_data = T,
                                        saveData = F)

qc_check_permutation <- qc_check_permutation %>%
        select(-c(n_perm,
                  mean_mouse_error,
                  n_perm_less_mouse_error,
                  percentile_sim_mouse_error))

## Combine all the qc tables ----------------------------------------------
qc_table <- merge(qc_check_debrief_and_errors,
                  qc_check_instructions_rt,
                  by = 'ptp')

qc_table <- merge(qc_table,
                  qc_check_break_rt,
                  by = 'ptp')

qc_table <- merge(qc_table,
                  qc_fail_missing_or_fast,
                  by = 'ptp')

qc_table <- merge(qc_table,
                  qc_check_permutation,
                  by = 'ptp')


## 6. Check for 1.5IQR rule --------------------------------------------

# Get the list of people passing QC till now
good_ptp <- qc_table %>%
        filter(qc_fail_break_rt == F,
               qc_fail_missing_or_fast == F,
               qc_fail_manual == F,
               qc_fail_mouse_error == F,
               qc_fail_instructions_rt == F) %>%
        select(ptp) %>% .[[1]]

# Get data from only these participants 

good_ptp_data <- data_summary %>%
        filter(ptp %in% good_ptp,
               type == 'all_pa') %>%
        droplevels() 

# Get the across condition accuracy for block 2
good_ptp_data <- good_ptp_data %>%
        group_by(ptp) %>%
        summarise(block_2_mouse_error_mean = mean(block_2_mouse_error_mean, na.rm = T))

# Calculate the Q1, Q2, IQR, and Q1-1.5xIQR and Q3+1.5xIQR


