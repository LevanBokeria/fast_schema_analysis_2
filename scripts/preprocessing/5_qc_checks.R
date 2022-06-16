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

saveDataCSV <- T

# Start the QC analysis ##################

## 1. Manual QC failures ------------------------------

qc_check_debrief_and_errors <- import('./results/qc_check_sheets/qc_check_debrief_and_errors.xlsx')

## 2. Instruction times -------------------------------