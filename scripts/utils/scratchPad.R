rm(list=ls())

source('./scripts/utils/load_all_libraries.R')

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


exdata %>% nls(mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
               data = .,
               start = list(c = 0.1,
                            a = 200))


# Try on grouped data
# mean_by_rep_long_all_types %>%
#         filter(border_dist_closest == 'all',
#                hidden_pa_img_type == 'all_pa') %>%
#         droplevels() %>%
#         group_by(ptp,
#                  condition) %>%
#         summarise(
#                 full_model_two_param = list(nls(
#                         mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                         data = cur_data(),
#                         start = list(c = 0.1,
#                                      a = 200),
#                         control = list(maxiter = 200))),
#                 full_model_three_param = list(nls(
#                         mouse_error_mean ~ b * exp(-c*(hidden_pa_img_row_number_across_blocks-1)) + a - b,
#                         data = cur_data(),
#                         start = list(b = 90,
#                                      c = 0.1,
#                                      a = 100),
#                         control = list(maxiter = 200)))) %>%
#         ungroup()
#         rowwise() %>%
#         mutate(a_two_param = coef(full_model_two_param)['a'],
#                c_two_param = coef(full_model_two_param)['c'],
#                loglik_two_param = as.vector(logLik(full_model_two_param))) %>% View()
# 
# 
# a %>%
#         mutate(cf = coefficients(full_model)['a']) %>% View()
# 
# mean_by_rep_long_all_types %>%
#         filter(border_dist_closest == 'all',
#                hidden_pa_img_type == 'all_pa') %>%
#         droplevels() %>%
#         group_by(ptp,
#                  condition) %>%
#         summarise(
#                 loglik_two_param = as.vector(logLik(nls(
#                 mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                 data = cur_data(),
#                 start = list(c = 0.1,
#                              a = 200),
#                 control = list(maxiter = 200)))),
#                a = coefficients(nls(
#                        mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                        data = cur_data(),
#                        start = list(c = 0.1,
#                                     a = 200),
#                        control = list(maxiter = 200)))['a'],
#                c = coefficients(nls(
#                        mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                        data = cur_data(),
#                        start = list(c = 0.1,
#                                     a = 200),
#                        control = list(maxiter = 200)))['c'],
#                mdl = nls(
#                        mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                        data = cur_data(),
#                        start = list(c = 0.1,
#                                     a = 200),
#                        control = list(maxiter = 200))$convInfo$isConv
#                ) %>%
#         ungroup() %>% View()


for (iptp in c('sub_005')){ 
        #unique(mean_by_rep_long_all_types$ptp)){
        
        for (icond in unique(mean_by_rep_long_all_types$condition)){
                
                
                curr_data <- mean_by_rep_long_all_types %>%
                        filter(border_dist_closest == 'all',
                               hidden_pa_img_type == 'all_pa',
                               ptp == iptp,
                               condition == icond) 
                
                print(iptp)
                print(icond)
                
                mdl <- nls(mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
                           data = curr_data,
                           start = list(c = 0.1,
                                        a = 200),
                           control = list(maxiter = 200))
                
                mdl2 <- nls(
                        mouse_error_mean ~ b * exp(-c*(hidden_pa_img_row_number_across_blocks-1)) + a - b,
                        data = curr_data,
                        start = list(b = 150,
                                     c = 0.1,
                                     a = 200),
                        control = list(maxiter = 200,
                                       minFactor = 0.00009))
                
                
                print(logLik(mdl))

                
        }
        
        
        
        
        
}


# mean_by_rep_long_all_types %>%
#         filter(border_dist_closest == 'all',
#                hidden_pa_img_type == 'all_pa',
#                ptp %in% c('sub_001','sub_002'),
#                condition == 'schema_c') %>%
#         droplevels() %>%
#         group_by(ptp) %>%
#         nlsList(model = mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                 data = cur_data(),
#                 start = list(c = 0.1,
#                              a = 200),
#                 )
#         
# 
# gd <- mean_by_rep_long_all_types %>%
#         filter(border_dist_closest == 'all',
#                hidden_pa_img_type == 'all_pa',
#                ptp %in% c('sub_001','sub_002')) %>%
#         droplevels()
# 
# nlsList(model = mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)) | ptp/condition,
#         data = gd,
#         start = list(c = 0.1,
#                      a = 200)) -> a
# 
#         
#         group_by(ptp,
#                  counterbalancing,
#                  condition) %>%
#         # summarise(n = n()) %>% View()
#         mutate(loglik_two_param = logLik(nls(
#                 mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#                 data = .,
#                 start = list(c = 0.1,
#                              a = 200)
#         ))) %>% ungroup() %>% View()
# 
# 
# 
# nls_table(df = exdata,
#           model = mouse_error_mean ~ a * exp(-c*(hidden_pa_img_row_number_across_blocks-1)),
#           mod_start = c(c = 0.1,a = 200),
#           output = 'table'
#           ) %>% View()
