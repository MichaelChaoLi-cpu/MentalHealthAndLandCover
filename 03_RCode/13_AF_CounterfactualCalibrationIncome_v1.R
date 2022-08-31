# Author: M.L.

# Aim: this script is to calculation monetary value of counterfactual

# end

library(randomForest)
library(tidyverse)
library(dplyr)
library(foreach)
library(doParallel)
library(doSNOW)

dataPre <- function(data){
  X <- data %>% dplyr::select(-GHQ12, -weights)
  return(X)
}

rfPredictYchangeFeature <- function(dataRF, modelRF, landCoverName, marginalChange){
  dataRF[,landCoverName] <- dataRF[,landCoverName] + marginalChange
  y_inc = predict(modelRF, newdata = dataRF)
  return(y_inc)
}

### this function find the reasonable income value to satisfy the counterfactural
singleCounterfactual <- function(singleDataRF, modelRF, aimY, tolerance, incomeName,
                                 incomeChangeLimit, incomeAccuracy){
  lineNumber <- incomeChangeLimit/incomeAccuracy * 2 + 1
  halfLineNumber <- incomeChangeLimit/incomeAccuracy
  searchingDataRF <- singleDataRF[rep(1, lineNumber),]
  changeValue <- seq(-incomeChangeLimit, incomeChangeLimit, incomeAccuracy)
  searchingDataRF[,incomeName] <- searchingDataRF[,incomeName] + changeValue
  y_inc = predict(modelRF, newdata = searchingDataRF)
  yChange <- abs(y_inc - aimY)
  resultTable <- as.data.frame(cbind(seq(-halfLineNumber, halfLineNumber, 1), yChange))
  resultTable <- resultTable[resultTable$yChange<0.1,]
  if(nrow(resultTable) > 0){
    resultTable$direction <- resultTable[,1]/abs(resultTable[,1])
    resultTable[is.na(resultTable[,3]),3] <- 1
    resultTable[,1] <- abs(resultTable[,1])
    direction <- resultTable[resultTable[,1]==min(resultTable[,1]),3]
    returnValue <- min(resultTable[,1]) * direction * incomeAccuracy
    if(length(returnValue)>1){
      returnValue <- returnValue[1]
    }
  } else {
    returnValue <- NA
  }
  return(returnValue)
}

progress_fun <- function(n){
  cat(n, ' ')
  if (n%%100==0){
    cat('\n')
  }
}

# parallel running the singleCounterfactual
aggregateCounterfactual <- function(dataRF, modelRF, landCoverName, marginalChange, 
                                    tolerance, incomeName, incomeChangeLimit, 
                                    incomeAccuracy, clusterNumber){
  y_inc <- rfPredictYchangeFeature(dataRF, modelRF, landCoverName, marginalChange)
  cl <- makeSOCKcluster(clusterNumber)
  clusterExport(cl, "singleCounterfactual")
  registerDoSNOW(cl)
  opts <- list(progress=progress_fun)
  df.ouput <-
    foreach(i = seq(1,nrow(dataRF), 1), .combine = 'c', 
            .packages='randomForest', .options.snow=opts) %dopar% {
              singleCounterfactual(dataRF[i,], modelRF, y_inc[i], tolerance, 
                                   incomeName, incomeChangeLimit, incomeAccuracy)
            }
  stopCluster(cl)
  return(df.ouput)
}

load("02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")
load("04_results/10_RFresult_49var_weighted.RData")
X <- dataPre(data_49)
#y_inc <- rfPredictYchangeFeature(X, data.rf.49.weighted, "crop2015", 1)
#stepIncrease <- singleCounterfactual(X[1,], data.rf.49.weighted, y_inc[1], 0.01, "di_inc_gdp", 1, 10^-3)
counterfactualValueOfCropChange1 <-
  aggregateCounterfactual(X, data.rf.49.weighted, "crop2015",marginalChange = 1,
                          0.01, "di_inc_gdp", 1, 10^-3, 10)
save(counterfactualValueOfCropChange1, file = "04_Results/97_temp_cropCounterfactualValue.Rdata")

counterfactualValueOfForeChange1 <-
  aggregateCounterfactual(X, data.rf.49.weighted, "fore2015",marginalChange = 1,
                          0.01, "di_inc_gdp", 1, 10^-3, 10)
save(counterfactualValueOfForeChange1, file = "04_Results/97_temp_foreCounterfactualValue.Rdata")
