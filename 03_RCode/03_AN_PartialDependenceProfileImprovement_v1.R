# Author: M.L.

# end

library(dplyr)
library(tidyverse)
library(randomForest)
library(plotrix)

load("02_Data/SP_Data_47Variable_Weights_changeRangeOfLandCover.RData")
load("04_Results/04_pdp_47weighted_resolution002.RData")

findBestFitFunction <- function(input_pdp, highest_order = 20, decide_value = 0.99, weights = NULL){
  if (!is.null(weights)){
    if(!(nrow(input_pdp)==length(weights))){stop("Weights have a different length with input data!")}
  }
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
    
    if(is.null(weights)) {
      regression <- lm(yhat ~ ., data)
      r2 <- summary(regression)$adj.r.squared
    } else {
      regression <- lm(yhat ~ ., data, weights = weights)
      r2 <- summary(regression)$adj.r.squared
    }
    if((r2>decide_value)&(first_time == T)){
      first_over_decide_value <- order
      keep.model <- regression
      first_time <- F
    }
    r2_array <- append(r2_array, r2)
  }
  if(first_time == T){
    first_over_decide_value <- NULL
    keep.model <- regression
  }
  cat(first_over_decide_value)
  result <- list(first_over_decide_value, r2_array, keep.model)
  return(result)
}

getWeights <- function(input_data, aim_variable, division_num){
  input_data <- input_data[, aim_variable]
  half_step <- ((max(input_data) - min(input_data))/(division_num)/2)
  wetl.weights <- hist(input_data,
                       breaks = seq(min(input_data) - half_step, max(input_data) + half_step,
                                    length = (division_num + 1)),
                       plot = F)
  wetl.weights <- wetl.weights$counts
  return(wetl.weights)
}

predictPDP <- function(input_pdp, decided_order = 20, weights_vector = NULL){
  if (is.null(decided_order)) {decided_order = 20}
  cat("decide order: ", decided_order)
  input_pdp <- input_pdp %>% as.matrix() %>% as.data.frame()
  input_pdp <- input_pdp %>% dplyr::select('yhat', dplyr::everything())
  y <- input_pdp %>% dplyr::select('yhat')
  x <- input_pdp %>% dplyr::select(-'yhat')
  for (order in seq(1,decided_order)){
    x[,paste0("order_", as.character(order))] <- input_pdp[,2]^order
  }
  x <- x[2:ncol(x)]
  data <- cbind(y, x)
  regression <- lm(yhat ~., data = data, weights = weights_vector)
  input_pdp$yhat_pred <- predict(regression, data)
  output_list <- list(input_pdp, regression)
  return(output_list)
}

##### find the best order with the weights
result.bare2015 <- findBestFitFunction(pdp.result.bare2015, 20, 0.99,
                                       weights = getWeights(data_47, "bare2015",4001))
result.crop2015 <- findBestFitFunction(pdp.result.crop2015, 20, 0.99,
                                       weights = getWeights(data_47, "crop2015",5000))
result.fore2015 <- findBestFitFunction(pdp.result.fore2015, 20, 0.99,
                                       weights = getWeights(data_47, "fore2015",5001))
result.gras2015 <- findBestFitFunction(pdp.result.gras2015, 20, 0.99,
                                       weights = getWeights(data_47, "gras2015",5001))
result.impe2015 <- findBestFitFunction(pdp.result.impe2015, 20, 0.99,
                                       weights = getWeights(data_47, "impe2015",5001))
result.shru2015 <- findBestFitFunction(pdp.result.shru2015, 20, 0.99,
                                       weights = getWeights(data_47, "shru2015",4001))
result.wate2015 <- findBestFitFunction(pdp.result.wate2015, 20, 0.99,
                                       weights = getWeights(data_47, "wate2015",5001))
result.wetl2015 <- findBestFitFunction(pdp.result.wetl2015, 20, 0.99,
                                       weights = getWeights(data_47, "wetl2015",3001))
result.di_inc <- findBestFitFunction(pdp.result.di_inc, 20, 0.99,
                                     weights = getWeights(data_47, "di_inc_gdp",5001))
##### find the best order with the weights

##### check the prediction and best order with the weights
#note: the linear should be similar to real line
result.bare2015[[1]] 
result.bare2015[[2]] 
pred.line.bare2015 <- predictPDP(input_pdp = pdp.result.bare2015, decided_order = 20,
                                 weights_vector = getWeights(data_47, "bare2015",4001))
ggplot(pred.line.bare2015[[1]], aes(x = bare2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.crop2015[[1]] 
result.crop2015[[2]] 
pred.line.crop2015 <- predictPDP(pdp.result.crop2015, 19,
                                 getWeights(data_47, "crop2015",5000))
ggplot(pred.line.crop2015[[1]], aes(x = crop2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.fore2015[[1]] 
result.fore2015[[2]] 
pred.line.fore2015 <- predictPDP(pdp.result.fore2015, 20,
                                 getWeights(data_47, "fore2015",5001))
ggplot(pred.line.fore2015[[1]], aes(x = fore2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.gras2015[[1]] 
result.gras2015[[2]] 
pred.line.gras2015 <- predictPDP(pdp.result.gras2015, 20,
                                 getWeights(data_47, "gras2015",nrow(pdp.result.gras2015)))
ggplot(pred.line.gras2015[[1]], aes(x = gras2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.impe2015[[1]] 
result.impe2015[[2]] 
pred.line.impe2015 <- predictPDP(pdp.result.impe2015, 20,
                                 getWeights(data_47, "impe2015",nrow(pdp.result.impe2015)))
ggplot(pred.line.impe2015[[1]], aes(x = impe2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.shru2015[[1]] 
result.shru2015[[2]] 
pred.line.shru2015 <- predictPDP(pdp.result.shru2015, 20,
                                 getWeights(data_47, "shru2015",nrow(pdp.result.shru2015)))
ggplot(pred.line.shru2015[[1]], aes(x = shru2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.wate2015[[1]] 
result.wate2015[[2]] 
pred.line.wate2015 <- predictPDP(pdp.result.wate2015, 20,
                                 getWeights(data_47, "wate2015",nrow(pdp.result.wate2015)))
ggplot(pred.line.wate2015[[1]], aes(x = wate2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.wetl2015[[1]] 
result.wetl2015[[2]] 
pred.line.wetl2015 <- predictPDP(pdp.result.wetl2015, 20,
                                 getWeights(data_47, "wetl2015",nrow(pdp.result.wetl2015)))
ggplot(pred.line.wetl2015[[1]], aes(x = wetl2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.di_inc[[1]] 
result.di_inc[[2]] 
pred.line.di_inc <- predictPDP(pdp.result.di_inc, 10,
                               getWeights(data_47, "di_inc_gdp",nrow(pdp.result.di_inc)))
ggplot(pred.line.di_inc[[1]], aes(x = di_inc_gdp)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))
##### check the prediction and best order with the weights

##### find the best order with the log weights
result.bare2015 <- findBestFitFunction(pdp.result.bare2015, 20, 0.99,
                                       weights = log(getWeights(data_47, "bare2015",4001) + exp(1))
                                       )
result.crop2015 <- findBestFitFunction(pdp.result.crop2015, 20, 0.99,
                                       weights = log(getWeights(data_47, "crop2015",5000) + exp(1)) 
                                       )
result.fore2015 <- findBestFitFunction(pdp.result.fore2015, 20, 0.99,
                                       weights = log(getWeights(data_47, "fore2015",5001) + exp(1)) 
                                       )
result.gras2015 <- findBestFitFunction(pdp.result.gras2015, 20, 0.99,
                                       weights = log(getWeights(data_47, "gras2015",5001) + exp(1))
                                       )
result.impe2015 <- findBestFitFunction(pdp.result.impe2015, 20, 0.99,
                                       weights = log(getWeights(data_47, "impe2015",5001) + exp(1)) 
                                       )
result.shru2015 <- findBestFitFunction(pdp.result.shru2015, 20, 0.99,
                                       weights = log(getWeights(data_47, "shru2015",4001) + exp(1)) 
                                       )
result.wate2015 <- findBestFitFunction(pdp.result.wate2015, 20, 0.99,
                                       weights = log(getWeights(data_47, "wate2015",5001) + exp(1))
                                       )
result.wetl2015 <- findBestFitFunction(pdp.result.wetl2015, 20, 0.99,
                                       weights = log(getWeights(data_47, "wetl2015",3001) + exp(1))
                                       )
result.di_inc <- findBestFitFunction(pdp.result.di_inc, 20, 0.99,
                                     weights = log(getWeights(data_47, "di_inc_gdp",5001) + exp(1))
                                     )
##### find the best order with the weights

##### check the prediction and best order with the weights
#note: the linear should be similar to real line
result.bare2015[[1]] 
result.bare2015[[2]] 
pred.line.bare2015 <- predictPDP(input_pdp = pdp.result.bare2015, decided_order = result.bare2015[[1]],
                                 weights_vector = log(getWeights(data_47, "bare2015", nrow(pdp.result.bare2015)) + exp(1)))
ggplot(pred.line.bare2015[[1]], aes(x = bare2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.crop2015[[1]] 
result.crop2015[[2]] 
pred.line.crop2015 <- predictPDP(pdp.result.crop2015, result.crop2015[[1]],
                                 log(getWeights(data_47, "crop2015", nrow(pdp.result.crop2015)) + exp(1)) )
ggplot(pred.line.crop2015[[1]], aes(x = crop2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.fore2015[[1]] 
result.fore2015[[2]] 
pred.line.fore2015 <- predictPDP(pdp.result.fore2015, result.fore2015[[1]] ,
                                 log(getWeights(data_47, "fore2015", nrow(pdp.result.fore2015)) + exp(1)) )
ggplot(pred.line.fore2015[[1]], aes(x = fore2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.gras2015[[1]] 
result.gras2015[[2]] 
pred.line.gras2015 <- predictPDP(pdp.result.gras2015, result.gras2015[[1]] ,
                                 log(getWeights(data_47, "gras2015",nrow(pdp.result.gras2015)) + exp(1)))
ggplot(pred.line.gras2015[[1]], aes(x = gras2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.impe2015[[1]] 
result.impe2015[[2]] 
pred.line.impe2015 <- predictPDP(pdp.result.impe2015, result.impe2015[[1]] ,
                                 log(getWeights(data_47, "impe2015",nrow(pdp.result.impe2015)) + exp(1)))
ggplot(pred.line.impe2015[[1]], aes(x = impe2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.shru2015[[1]] 
result.shru2015[[2]] 
pred.line.shru2015 <- predictPDP(pdp.result.shru2015, result.shru2015[[1]] ,
                                 log(getWeights(data_47, "shru2015",nrow(pdp.result.shru2015)) + exp(1)))
ggplot(pred.line.shru2015[[1]], aes(x = shru2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.wate2015[[1]] 
result.wate2015[[2]] 
pred.line.wate2015 <- predictPDP(pdp.result.wate2015, result.wate2015[[1]] ,
                                 log(getWeights(data_47, "wate2015",nrow(pdp.result.wate2015)) + exp(1)))
ggplot(pred.line.wate2015[[1]], aes(x = wate2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.wetl2015[[1]] 
result.wetl2015[[2]] 
pred.line.wetl2015 <- predictPDP(pdp.result.wetl2015, result.wetl2015[[1]] ,
                                 log(getWeights(data_47, "wetl2015",nrow(pdp.result.wetl2015)) + exp(1)))
ggplot(pred.line.wetl2015[[1]], aes(x = wetl2015)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

result.di_inc[[1]] 
result.di_inc[[2]] 
pred.line.di_inc <- predictPDP(pdp.result.di_inc, result.di_inc[[1]] ,
                               log(getWeights(data_47, "di_inc_gdp",nrow(pdp.result.di_inc)) + exp(1)))
ggplot(pred.line.di_inc[[1]], aes(x = di_inc_gdp)) +
  geom_point(aes(y = yhat, color = "yhat")) +
  geom_point(aes(y = yhat_pred, color = "yhat_pred"))

save(pred.line.impe2015, pred.line.fore2015, pred.line.crop2015,
     pred.line.wetl2015, pred.line.bare2015, pred.line.gras2015,
     pred.line.shru2015, pred.line.wate2015, pred.line.di_inc,
     file = "04_Results/04_pdp_refit_weights_rf47weighted.RData",
     version = 2)
##### check the prediction and best order with the weights
