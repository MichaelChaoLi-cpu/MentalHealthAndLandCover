# Author: M.L.

# input: 03_pdp_refit_weights_rf47weighted.RData

# 03_pdp_refit_weights_rf47weighted.RData: This is aggregated result, including
#                                          "pred.line.impe2015", "pred.line.fore2015", 
#                                          "pred.line.crop2015", "pred.line.wetl2015", 
#                                          "pred.line.bare2015", "pred.line.gras2015",
#                                          "pred.line.shru2015", "pred.line.wate2015", 
#                                          and "pred.line.di_inc". This are PPDF.
# pred.line.XXXX: [[1]] "data.frame": "yhat_pred" PPDF predicted values.
# pred.line.XXXX: [[2]] "lm": lm regression result.

# input: 01_Dataset.RData

# 01_Dataset.RData: raw data set. In this data set, the features of interst are
#                   renamed.

# input: SP_Data_47Variable_Weights_changeRangeOfLandCover.RData

# SP_Data_47Variable_Weights_changeRangeOfLandCover.RData: This data set for 
#                                                        weighted random forest.
# SP_Data_47Variable_Weights_changeRangeOfLandCover.RData: "di_inc_gdp" -1 to 3,
# SP_Data_47Variable_Weights_changeRangeOfLandCover.RData: "shru2015" 0 to 40,
# SP_Data_47Variable_Weights_changeRangeOfLandCover.RData: "wetl2015" 0 to 3,
# SP_Data_47Variable_Weights_changeRangeOfLandCover.RData: "wate2015" 0 to 60,
# SP_Data_47Variable_Weights_changeRangeOfLandCover.RData: "bare2015" 0 to 20.
# Note: the ranges of di_inc_gdp, shru2015, wetl2015, wate2015, bare2015 have been cut

# output: 05_MSR_landcover.RData

# 05_MSR_landcover.RData: "MSR_bare" Montary values of a 1-ha increase in bare land
# 05_MSR_landcover.RData: "MSR_crop" Montary values of a 1-ha increase in cropland 
# 05_MSR_landcover.RData: "MSR_fore" Montary values of a 1-ha increase in forest 
# 05_MSR_landcover.RData: "MSR_gras" Montary values of a 1-ha increase in grass land 
# 05_MSR_landcover.RData: "MSR_impe" Montary values of a 1-ha increase in urban land
# 05_MSR_landcover.RData: "MSR_shru" Montary values of a 1-ha increase in shrub land 
# 05_MSR_landcover.RData: "MSR_wate" Montary values of a 1-ha increase in water 
# 05_MSR_landcover.RData: "MSR_wetl" Montary values of a 1-ha increase in wetland 
# 05_MSR_landcover.RData: "ME_bare" ME of a 1-ha increase in bare land
# 05_MSR_landcover.RData: "ME_crop" ME of a 1-ha increase in cropland 
# 05_MSR_landcover.RData: "ME_fore" ME of a 1-ha increase in forest 
# 05_MSR_landcover.RData: "ME_gras" ME of a 1-ha increase in grass land 
# 05_MSR_landcover.RData: "ME_impe" ME of a 1-ha increase in urban land
# 05_MSR_landcover.RData: "ME_shru" ME of a 1-ha increase in shrub land 
# 05_MSR_landcover.RData: "ME_wate" ME of a 1-ha increase in water 
# 05_MSR_landcover.RData: "ME_wetl" ME of a 1-ha increase in wetland 

# end

library(dplyr)
library(tidyverse)
library(ggplot2)

load("04_Results/03_pdp_refit_weights_rf47weighted.RData")
load("02_Data/SP_Data_47Variable_Weights_changeRangeOfLandCover.RData")

#### Marginal Substitute Rate functions:
land.ME.estimation <- function(land_value, inc_value, input_land_model, 
                                input_inc_model = pred.line.di_inc[[2]]){
  hm2 <- 0.01273885
  decided_order <- length(coefficients(input_land_model))
  land_value <- land_value %>% as.data.frame()
  x <- land_value
  for (order in seq(1,decided_order)){
    x[,paste0("order_", as.character(order))] <- land_value^order
  }
  x <- x[2:ncol(x)]
  f_LA <- predict(input_land_model, x)
  
  land_value_hm <- (land_value+hm2) %>% as.data.frame()
  x <- land_value_hm
  for (order in seq(1,decided_order)){
    x[,paste0("order_", as.character(order))] <- land_value_hm^order
  }
  x <- x[2:ncol(x)]
  f_LA_delta <- predict(input_land_model, x)
  ME <- f_LA_delta - f_LA
  return(ME)
}

land.MSR.estimation <- function(land_value, inc_value, input_land_model, 
                                input_inc_model = pred.line.di_inc[[2]]){
  hm2 <- 0.01273885
  decided_order <- length(coefficients(input_land_model))
  land_value <- land_value %>% as.data.frame()
  x <- land_value
  for (order in seq(1,decided_order)){
    x[,paste0("order_", as.character(order))] <- land_value^order
  }
  x <- x[2:ncol(x)]
  f_LA <- predict(input_land_model, x)
  
  land_value_hm <- (land_value+hm2) %>% as.data.frame()
  x <- land_value_hm
  for (order in seq(1,decided_order)){
    x[,paste0("order_", as.character(order))] <- land_value_hm^order
  }
  x <- x[2:ncol(x)]
  f_LA_delta <- predict(input_land_model, x)
  
  decided_order <- length(coefficients(input_inc_model))
  inc_value <- inc_value %>% as.data.frame()
  x <- inc_value
  for (order in seq(1,decided_order)){
    x[,paste0("order_", as.character(order))] <- inc_value^order
  }
  x <- x[2:ncol(x)]
  g_Inc <- predict(input_inc_model, x)
  g_Inc_delta <- g_Inc + f_LA_delta - f_LA
  income_change <- c()
  g_Inc_delta <- g_Inc_delta %>% as.vector()
  inc_value <- inc_value[[1]] %>% as.vector()
  loop_time <-  1
  while(loop_time < (length(g_Inc_delta) + 1)){
    single_g_Inc_delta <- g_Inc_delta[loop_time]
    people_income <- inc_value[loop_time]
    income_change_single <- try(calculate_root(single_g_Inc_delta, people_income = people_income,
                                                 input_inc_model), silent = TRUE)
    if(!inherits(income_change_single, "try-error")){
      income_change_single <- calculate_root(single_g_Inc_delta, people_income = people_income,
                                             input_inc_model)
    } else {
      income_change_single <- NA
    }
    income_change <- append(income_change, income_change_single)
    loop_time <- loop_time + 1
  }
  income_change <- income_change - inc_value
  return(income_change)
}

f <- function(x, coef, b){
  value_function <- coef[1] -  b
  loop_time <- 2
  while(loop_time < (length(coef) + 1)){
    if(is.na(coef[loop_time])){ coef[loop_time] <- 0}
    value_function <- value_function + coef[loop_time]*x^(loop_time-1)
    loop_time <- loop_time + 1 
  }
  value_function <- value_function %>% as.numeric()
  return(value_function)
}

calculate_root <- function(est_MH_inc, people_income, input_inc_model = input_inc_model){
  coef <- coefficients(input_inc_model)
  bound <- 0.5
  root <- try(uniroot(f, c(people_income - bound, people_income + bound),
                      coef = coef, b = est_MH_inc, tol = 0.0001), silent = TRUE)
  while((inherits(root, "try-error")&(bound>0))){
    bound <- bound - 0.005
    root <- try(uniroot(f, c(people_income - bound, people_income + bound),
                        coef = coef, b = est_MH_inc, tol = 0.0001), silent = TRUE)
  } 
  root <- uniroot(f, c(people_income - bound, people_income + bound),
                      coef = coef, b = est_MH_inc, tol = 0.0001)
  return(root$root)
}


#### MSR calculation
data_47_MSR <- data_47

data_47_MSR$MSR_bare <- land.MSR.estimation(data_47_MSR$bare2015, data_47_MSR$di_inc_gdp,
                                            pred.line.bare2015[[2]], pred.line.di_inc[[2]])
summary(data_47_MSR$MSR_bare)
ggplot(data = data_47_MSR) + 
  geom_histogram(aes(x = MSR_bare), bins = 100)

data_47_MSR$MSR_crop <- land.MSR.estimation(data_47_MSR$crop2015, data_47_MSR$di_inc_gdp,
                                            pred.line.crop2015[[2]], pred.line.di_inc[[2]])
summary(data_47_MSR$MSR_crop)
ggplot(data = data_47_MSR) + 
  geom_histogram(aes(x = MSR_crop), bins = 100) 

data_47_MSR$MSR_fore <- land.MSR.estimation(data_47_MSR$fore2015, data_47_MSR$di_inc_gdp,
                                            pred.line.fore2015[[2]], pred.line.di_inc[[2]])
summary(data_47_MSR$MSR_fore)
ggplot(data = data_47_MSR) + 
  geom_histogram(aes(x = MSR_fore), bins = 100) 

data_47_MSR$MSR_gras <- land.MSR.estimation(data_47_MSR$gras2015, data_47_MSR$di_inc_gdp,
                                            pred.line.gras2015[[2]], pred.line.di_inc[[2]])
summary(data_47_MSR$MSR_gras)
ggplot(data = data_47_MSR) + 
  geom_histogram(aes(x = MSR_gras), bins = 100) 

data_47_MSR$MSR_shru <- land.MSR.estimation(data_47_MSR$shru2015, data_47_MSR$di_inc_gdp,
                                            pred.line.shru2015[[2]], pred.line.di_inc[[2]])
summary(data_47_MSR$MSR_shru)
ggplot(data = data_47_MSR) + 
  geom_histogram(aes(x = MSR_shru), bins = 100) 

data_47_MSR$MSR_wetl <- land.MSR.estimation(data_47_MSR$wetl2015, data_47_MSR$di_inc_gdp,
                                            pred.line.wetl2015[[2]], pred.line.di_inc[[2]])
summary(data_47_MSR$MSR_wetl)
ggplot(data = data_47_MSR) + 
  geom_histogram(aes(x = MSR_wetl), bins = 100) 

data_47_MSR$MSR_wate <- land.MSR.estimation(data_47_MSR$wate2015, data_47_MSR$di_inc_gdp,
                                            pred.line.wate2015[[2]], pred.line.di_inc[[2]])
summary(data_47_MSR$MSR_wate)
ggplot(data = data_47_MSR) + 
  geom_histogram(aes(x = MSR_wate), bins = 100) 

data_47_MSR$MSR_impe <- land.MSR.estimation(data_47_MSR$impe2015, data_47_MSR$di_inc_gdp,
                                            pred.line.impe2015[[2]], pred.line.di_inc[[2]])
summary(data_47_MSR$MSR_impe)
ggplot(data = data_47_MSR) + 
  geom_histogram(aes(x = MSR_impe), bins = 100) 

data_47_MSR$ME_bare <- land.ME.estimation(data_47_MSR$bare2015, data_47_MSR$di_inc_gdp,
                                            pred.line.bare2015[[2]], pred.line.di_inc[[2]])

data_47_MSR$ME_crop <- land.ME.estimation(data_47_MSR$crop2015, data_47_MSR$di_inc_gdp,
                                            pred.line.crop2015[[2]], pred.line.di_inc[[2]])

data_47_MSR$ME_fore <- land.ME.estimation(data_47_MSR$fore2015, data_47_MSR$di_inc_gdp,
                                            pred.line.fore2015[[2]], pred.line.di_inc[[2]])

data_47_MSR$ME_gras <- land.ME.estimation(data_47_MSR$gras2015, data_47_MSR$di_inc_gdp,
                                            pred.line.gras2015[[2]], pred.line.di_inc[[2]])

data_47_MSR$ME_shru <- land.ME.estimation(data_47_MSR$shru2015, data_47_MSR$di_inc_gdp,
                                            pred.line.shru2015[[2]], pred.line.di_inc[[2]])

data_47_MSR$ME_wetl <- land.ME.estimation(data_47_MSR$wetl2015, data_47_MSR$di_inc_gdp,
                                            pred.line.wetl2015[[2]], pred.line.di_inc[[2]])

data_47_MSR$ME_wate <- land.ME.estimation(data_47_MSR$wate2015, data_47_MSR$di_inc_gdp,
                                            pred.line.wate2015[[2]], pred.line.di_inc[[2]])

data_47_MSR$ME_impe <- land.ME.estimation(data_47_MSR$impe2015, data_47_MSR$di_inc_gdp,
                                            pred.line.impe2015[[2]], pred.line.di_inc[[2]])

save(data_47_MSR, file = "04_Results/05_MSR_landcover.RData", version = 2)

### test log function with di_inc_gdp
#pdp.result.di_inc.test <- pdp.result.di_inc
#pdp.result.di_inc.test$yhat_exp <- exp(pdp.result.di_inc.test$yhat)
#coef <- coefficients(lm(yhat_exp ~ di_inc_gdp, data = pdp.result.di_inc.test))
#pdp.result.di_inc.test$yhat_pred <- log(pdp.result.di_inc.test$di_inc_gdp * as.numeric(coef[2]) +
#                                          as.numeric(coef[1]) )
#1 - sum((pdp.result.di_inc.test$yhat - pdp.result.di_inc.test$yhat_pred)^2)/
#  sum((pdp.result.di_inc.test$yhat - mean(pdp.result.di_inc.test$yhat) )^2)
#### fail!!!!

