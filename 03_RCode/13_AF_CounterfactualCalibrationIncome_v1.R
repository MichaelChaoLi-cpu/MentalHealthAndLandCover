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
singleCounterfactual <- function(singleDataRF, modelRF, aimY, tolerance, incomeName, changeLimit){
  stepLength <- changeLimit/10
  y_inc = aimY - 1
  #### init y_inc
  #predictValue = c()
  #### trun on this in the test 
  originalData <- singleDataRF
  
  loop3 <- 0
  while(loop3 < 3){
    stepLength <- changeLimit/10
    y_inc = aimY - 1
    #### init y_inc
    singleDataRF <- originalData
    i = 0
    while(i < 10 & y_inc < aimY){
      singleDataRF[,incomeName] <- singleDataRF[,incomeName] + stepLength
      y_inc = predict(modelRF, newdata = singleDataRF)
      #predictValue <- append(predictValue, singleDataRF[,incomeName])
      i = i + 1
    }
    if(i == 10){
      singleDataRF <- originalData
      i = 0
      while(i < 10 & y_inc < aimY){
        singleDataRF[,incomeName] <- singleDataRF[,incomeName] - stepLength
        y_inc = predict(modelRF, newdata = singleDataRF)
        #predictValue <- append(predictValue, singleDataRF[,incomeName])
        i = i + 1
      }
    } 
    if(abs(y_inc - aimY) < tolerance){
      #return(predictValue)
      return(singleDataRF[,incomeName])
    } else {
      originalData <- singleDataRF
      changeLimit <- -changeLimit/10
    }
    loop3 <- loop3 + 1
    #### if finish three time, the changeLimit is to 10^-3
  }
  #return(predictValue)
  if(loop3 == 3 & i == 10){
    singleDataRF[,incomeName] = NA
  }
  return(singleDataRF[,incomeName])
}

progress_fun <- function(n){
  cat(n, ' ')
  if (n%%100==0){
    cat('\n')
  }
}

# parallel running the singleCounterfactual
aggregateCounterfactual <- function(dataRF, modelRF, landCoverName, marginalChange, 
                                    tolerance, incomeName, changeLimit, clusterNumber){
  y_inc <- rfPredictYchangeFeature(dataRF, modelRF, landCoverName, marginalChange)
  cl <- makeSOCKcluster(clusterNumber)
  clusterExport(cl, "singleCounterfactual")
  registerDoSNOW(cl)
  opts <- list(progress=progress_fun)
  df.ouput <-
    foreach(i = seq(1,nrow(dataRF), 1), .combine = 'c', 
            .packages='randomForest', .options.snow=opts) %dopar% {
              singleCounterfactual(dataRF[i,], modelRF, y_inc[i], tolerance, incomeName, changeLimit)
            }
  stopCluster(cl)
  return(df.ouput)
}

load("02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")
load("04_results/10_RFresult_49var_weighted.RData")
X <- dataPre(data_49)
#y_inc <- rfPredictYchangeFeature(X, data.rf.49.weighted, "crop2015", 0.01)
#stepIncrease <- singleCounterfactual(X[2,], data.rf.49.weighted, y_inc[2], 0.01, "di_inc_gdp", 1)
test <- aggregateCounterfactual(X[1:200,], data.rf.49.weighted, "crop2015",marginalChange = 0.01,
                                0.01, "di_inc_gdp", 1, 2)
