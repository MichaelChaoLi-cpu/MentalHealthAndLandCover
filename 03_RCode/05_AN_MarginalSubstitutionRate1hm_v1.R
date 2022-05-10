# Author: M.L.

# end

library(dplyr)
library(tidyverse)
library(ggplot2)

load("04_Results/04_pdp_refit_weights_rf47weighted.RData")
load("04_Results/01_RFresult_47var_weighted.RData")

#### Marginal Substitute Rate functions:
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
  root <- uniroot(f, c(people_income-0.05, people_income+0.05), coef = coef, b = est_MH_inc, tol = 0.0001)
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


save(data_47_MSR, file = "04_Results/05_MSR_landcover.RData", version = 2)

### test log function with di_inc_gdp
pdp.result.di_inc.test <- pdp.result.di_inc
pdp.result.di_inc.test$yhat_exp <- exp(pdp.result.di_inc.test$yhat)
coef <- coefficients(lm(yhat_exp ~ di_inc_gdp, data = pdp.result.di_inc.test))
pdp.result.di_inc.test$yhat_pred <- log(pdp.result.di_inc.test$di_inc_gdp * as.numeric(coef[2]) +
                                          as.numeric(coef[1]) )
1 - sum((pdp.result.di_inc.test$yhat - pdp.result.di_inc.test$yhat_pred)^2)/
  sum((pdp.result.di_inc.test$yhat - mean(pdp.result.di_inc.test$yhat) )^2)
#### fail!!!!

