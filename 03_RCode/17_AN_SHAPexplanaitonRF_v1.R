# Author: M.L.

# Note: Let test the SHAP to explain the result

# end

library(randomForest)
library(tidyverse)
library(dplyr)
library(foreach)
library(doParallel)
library(doSNOW)
library("DALEX")

dataPre <- function(data){
  X <- data %>% dplyr::select(-GHQ12, -weights)
  return(X)
}

load("02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")
load("04_results/10_RFresult_49var_weighted.RData")
X <- dataPre(data_49)

test1 <- data_49[1,]
explain_rf <- DALEX::explain(model = data.rf.49.weighted,  
                             data = X,
                             y = data_49$GHQ12, 
                             label = "Random Forest")
shap_test1 <- DALEX::predict_parts(
  explainer = explain_rf, 
  new_observation = test1,
  type = "shap",
  B = 1000)
