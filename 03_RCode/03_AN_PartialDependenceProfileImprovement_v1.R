# Author: M.L.

# end

library(randomForest)
library(plotrix)

load("02_Data/SP_Data_48Variable_Weights.RData")
load("04_Results/02_pdp_48weighted_5000.RData")

findBestFitFunction <- function(input_pdp, highest_order = 20, decide_value = 0.99, weights = NULL){
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
  if(is.null(weights)){cat('Unweighted!\n')} else{
    cat('Weighted!\n')
  }
  for (order in seq(1,highest_order)){
    data <- cbind(y, x[1:order])
    regression <- lm(data)
    if(is.null(weights)) {
      r2 <- summary(regression)$adj.r.squared
    } else {
      r2 <- summary(regression, weights = weights)$adj.r.squared
    }
    if((r2>decide_value)&(first_time == T)){
      first_over_decide_value <- order
      first_time <- F
    }
    r2_array <- append(r2_array, r2)
  }
  if(first_time == T){first_over_decide_value <- NULL}
  result <- list(first_over_decide_value, r2_array)
  return(result)
}

getWeights <- function(input_data, aim_variable){
  input_data <- input_data[, aim_variable]
  half_step <- ((max(input_data) - min(input_data))/5000/2)
  wetl.weights <- hist(input_data,
                       breaks = seq(min(input_data) - half_step, max(input_data) + half_step, length = 5001),
                       plot = F)
  wetl.weights <- wetl.weights$counts
  return(wetl.weights)
}

result <- findBestFitFunction(pdp.result.wetl2015, 20, 0.99, weights = getWeights(data_48, "wetl2015"))
result <- findBestFitFunction(pdp.result.di_inc, 20, 0.99)

predictPDP <- function(input_pdp, decided_order = 20){
  input_pdp <- input_pdp %>% as.matrix() %>% as.data.frame()
  input_pdp <- input_pdp %>% dplyr::select('yhat', dplyr::everything())
  y <- input_pdp %>% dplyr::select('yhat')
  x <- input_pdp %>% dplyr::select(-'yhat')
  for (order in seq(1,decided_order)){
    x[,paste0("order_", as.character(order))] <- input_pdp[,2]^order
  }
  x <- x[2:ncol(x)]
  data <- cbind(y, x)
  regression <- lm(data)
  input_pdp$yhat_pred <- predict(regression, data)
  return(input_pdp)
}

result.pred <- predictPDP(pdp.result.wetl2015, 20)

ggplot(result.pred, aes(x = wetl2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))
