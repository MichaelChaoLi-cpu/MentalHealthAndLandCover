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

devtools::install_github("MichaelChaoLi-cpu/iBreakDown")
library(iBreakDown)

dataPre <- function(data){
  X <- data %>% dplyr::select(-GHQ12, -weights)
  return(X)
}

load("DP02/02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")
load("DP02/04_Results/10_RFresult_49var_weighted.RData")
X <- dataPre(data_49)

explain_rf <- DALEX::explain(model = data.rf.49.weighted,  
                             data = X,
                             y = data_49$GHQ12, 
                             label = "Random Forest")

shap.df <- data.frame(Doubles=double(),
                      Integers=integer(),
                      Factors=factor(),
                      Logicals=logical(),
                      Characters=character(),
                      stringsAsFactors=FALSE)

row.num <- 1
while (row.num < nrow(data_49) + 1){
  test1 <- data_49[row.num,]
  shap_test1 <- DALEX::predict_parts(
    explainer = explain_rf, 
    new_observation = test1,
    B = 20, type = "shap", clusterNumber = 4)
  shap.df <- rbind(shap.df, shap_test1)
  cat(row.num, " ")
  row.num <- row.num + 1
}
