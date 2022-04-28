# Author: M.L.

# end

library(randomForest)
library(plotrix)

load("04_Results/01_RFresult_48var_weighted.RData")
load("02_Data/SP_Data_48Variable_Weights.RData")
load("04_Results/02_pdp_48weighted_5000.RData")

data_48 <- data_48 %>% dplyr::select(-weights)

data_used_in_prediction = data_48[2:ncol(data_48)] 
data_used_in_prediction[,'impe2015'] = 0

yhat <- predict(data.rf.48.weighted, data_used_in_prediction)
mean_yhat <- mean(yhat) 
stderr_yhat <- std.error(yhat)


findBestFitFunction <- function(input_pdp, highest_order = 20, decide_value = 0.99){
  input_pdp <- input_pdp %>% as.matrix() %>% as.data.frame()
  input_pdp <- input_pdp %>% dplyr::select('yhat', dplyr::everything())
  y <- input_pdp %>% dplyr::select('yhat')
  x <- input_pdp %>% dplyr::select(-'yhat')
  for (order in seq(1,highest_order)){
    x[,paste0("order_", as.character(order))] <- input_pdp[,2]^order
  }
  x <- x[2:ncol(x)]
  r2_array <- c()
  first_time <- T
  for (order in seq(1,highest_order)){
    data <- cbind(y, x[1:order])
    regression <- lm(data)
    r2 <- summary(regression)$adj.r.squared
    if((r2>decide_value)&(first_time == T)){
      first_over_decide_value <- order
      first_time <- F
    }
    r2_array <- append(r2_array, r2)
  }
  result <- list(first_over_decide_value, r2_array)
  return(result)
}

result <- findBestFitFunction(pdp.result.gras2015, 20, 0.99)
result <- findBestFitFunction(pdp.result.di_inc, 20, 0.99)

predictPDP <- function(input_pdp, decided_order = 20){
  input_pdp <- input_pdp %>% as.matrix() %>% as.data.frame()
  input_pdp <- input_pdp %>% dplyr::select('yhat', dplyr::everything())
  y <- input_pdp %>% dplyr::select('yhat')
  x <- input_pdp %>% dplyr::select(-'yhat')
  for (order in seq(1,highest_order)){
    x[,paste0("order_", as.character(order))] <- input_pdp[,2]^order
  }
  x <- x[2:ncol(x)]
  data <- cbind(y, x)
  regression <- lm(data)
  input_pdp$yhat_pred <- predict(regression, data)
  return(input_pdp)
}

result.pred <- predictPDP(pdp.result.di_inc, 10)

ggplot(result.pred, aes(x = di_inc_gdp)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))
