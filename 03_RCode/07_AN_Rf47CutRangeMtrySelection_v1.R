# Author: M.L.


# Note: this script to change the range of some land cover variables

# end

library(ggplot2)
library(cowplot)
library(foreach)
#library(doParallel)
library(randomForest)
library(tidyverse)
library(DALEX)
library(doSNOW)
library(tcltk)
library(pdp)

load("02_Data/SP_Data_47Variable_Weights_changeRangeOfLandCover.RData")
data_47_no_weights <- data_47 %>% dplyr::select(-weights)

accuracy.df <- data.frame(Doubles=double(),
                          Ints=integer(),
                          Factors=factor(),
                          Logicals=logical(),
                          Characters=character(),
                          stringsAsFactors=FALSE)
MTRY <- 11
while(MTRY < 16){
  # do SNOW
  cl <- makeSOCKcluster(12)
  registerDoSNOW(cl)
  getDoParWorkers()
  
  ntasks <- 100
  pb <- tkProgressBar(max=ntasks)
  progress <- function(n) setTkProgressBar(pb, n)
  opts <- list(progress=progress)
  
  data.rf.47.weighted <- 
    foreach(ntree = rep(10, ntasks), .combine = randomForest::combine,
            .multicombine=TRUE, .packages='randomForest',
            .options.snow=opts) %dopar% {
              randomForest(GHQ12 ~ .,  data_47_no_weights,
                           na.action = na.omit, weights = data_47$weights,
                           ntree = ntree, importance = T, mtry = MTRY)
            }
  
  stopCluster(cl)
  # do snow
  
  ### unified the model
  explainer_data.rf.47.weighted = explain(data.rf.47.weighted, data = data_47_no_weights, 
                                          y = data_47_no_weights$GHQ12)
  model_performance_data.rf.47.weighted <- model_performance(explainer_data.rf.47.weighted)
  line.accuracy <- c(MTRY, model_performance_data.rf.47.weighted$measure$mse, 
                     model_performance_data.rf.47.weighted$measure$rmse, 
                     model_performance_data.rf.47.weighted$measure$r2, 
                     model_performance_data.rf.47.weighted$measure$mad)
  accuracy.df <- rbind(accuracy.df, line.accuracy)
  MTRY <- MTRY + 1
}
