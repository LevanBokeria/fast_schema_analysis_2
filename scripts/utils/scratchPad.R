rm(list=ls())

# Load

mean_by_rep_long_all_types <- import('./results/mean_by_rep_long_all_types.csv')


# Get one part data
exdata <- 
mean_by_rep_long_all_types %>%
        filter(border_dist_closest == 'all',
               hidden_pa_img_type == 'all_pa',
               ptp == 'sub_001',
               condition == 'schema_c') %>%
        select(ptp,
               hidden_pa_img_row_number_across_blocks,
               mouse_error_mean)


mdl <- nls(mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
    data = exdata,
    start = list(c = 0.1,
                 a = 200))


# Try on grouped data

nls_table(df = exdata,
          model = mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
          mod_start = c(c = 0.1,a = 200),
          output = 'nest'
          ) %>% View()
