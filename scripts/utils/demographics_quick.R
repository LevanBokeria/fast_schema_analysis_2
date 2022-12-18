rm(list=ls())


source('./scripts/utils/load_all_libraries.R')


# Load dataframes #################


metadata <- import('../../ownCloud/Cambridge/PhD/projects/fast_schema_mapping/prolific_metadata/prolific_export_updated.csv')


pid_map <- import('../../ownCloud/Cambridge/PhD/projects/fast_schema_mapping/prolific_metadata/prol_id_to_rand_id_original.csv')

qc_table <- import('./results/qc_check_sheets/qc_table.csv')

# Sanity checks ####################


# Does everyone in metadata that was approved have a qc table entry?

ptp_approved <- metadata[metadata$Status != 'RETURNED','Participant id']

ptp_approved[which(ptp_approved %in% pid_map$prol_id == F)]

# Ok this one person, had a glitch. But should still have been assigned an anonimous ID so we cound as qc fail.
# Will just manually deal with this now.

metadata_approved <- metadata %>%
        filter(Status != 'RETURNED')

# Join pid map and qc table
pid_qc <- merge(pid_map,qc_table,
                by.x = 'rand_id',
                by.y = 'ptp')

# Now merge the metadata and pid qc

pid_qc_metadata <- merge(pid_qc,metadata_approved,
                         by.x = 'prol_id',
                         by.y = 'Participant id',
                         all.y = T)

# For the participant thats not assigned a random id, manually record the qc status
pid_qc_metadata[is.na(pid_qc_metadata$rand_id),"qc_fail_overall"] <- TRUE
pid_qc_metadata[is.na(pid_qc_metadata$rand_id),"qc_fail_manual"] <- TRUE

# Now do the summary stats ########################################

# Total number of people 
pid_qc_metadata %>%
        count(Sex)

pid_qc_metadata %>%
        filter(Age != 'DATA_EXPIRED') %>%
        mutate(Age = as.numeric(Age)) %>% 
        summarise(mean_age = mean(Age),
                  max_age = max(Age),
                  min_age = min(Age),
                  sd_age = sd(Age))

# Now juts qc pass
pid_qc_metadata %>%
        filter(qc_fail_overall == 'FALSE') %>%
        count(Sex)


pid_qc_metadata %>%
        filter(Age != 'DATA_EXPIRED') %>%
        filter(qc_fail_overall == 'FALSE') %>%
        mutate(Age = as.numeric(Age)) %>% 
        summarise(mean_age = mean(Age),
                  max_age = max(Age),
                  min_age = min(Age),
                  sd_age = sd(Age))
