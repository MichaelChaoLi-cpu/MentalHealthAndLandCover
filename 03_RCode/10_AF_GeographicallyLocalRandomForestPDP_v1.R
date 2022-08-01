# Author: M.L.

# Aim: this script is to perform geographical PDP

# Architecture: 1. treeRangeList
#               2. singlePointOneDirectionBoundaryTibble
#               3. whoIsNeighborOfSinglePoint
#               4. singlePointLocalPDP

# Note: 

# end

library(randomForest)
library(tidyverse)
library(dplyr)
library(foreach)
library(doParallel)
library(doSNOW)

treeRangeList <- function(rfObj, aimVariable, clusterNumber = 4, fixedLength = 4000){
  # This function is to obtain the judgment of a certain variable in the rf 
  treeNumber <- rfObj$ntree
  cl <- makeSOCKcluster(clusterNumber)
  registerDoSNOW(cl)
  rangeList <- 
    foreach(treeOrder = seq(1,treeNumber,1), .combine = 'cbind', 
            .packages=c('randomForest','tidyverse')) %dopar% {
    singleTree <- getTree(rfObj, k=treeOrder, labelVar = T)
    singleTree <- singleTree %>% filter(`split var` == aimVariable) %>% 
      arrange(`split point`) %>% dplyr::select(`split point`) %>% distinct()
    if (nrow(singleTree) > 0){
      singleList <- c(as.vector(singleTree$`split point`), rep(NA, (fixedLength-nrow(singleTree))))
    } else {
      singleList <- rep(NA, fixedLength)
    }
    singleList <- as.data.frame(singleList)
  }
  stopCluster(cl)
  return(rangeList)
}

boundaryValuesSelectionSingleTree <- function(valueOfPoi, rangeListSingColumn){
  step = 1
  while (step < 4000){
    if(valueOfPoi < rangeListSingColumn[1]){
      outputBoundary <- c(-180, rangeListSingColumn[1])
      return(outputBoundary)
    }
    if(is.na(rangeListSingColumn[step+1])){
      outputBoundary <- c(rangeListSingColumn[step], 180)
      return(outputBoundary)
    }
    if((rangeListSingColumn[step] < valueOfPoi) & (rangeListSingColumn[step+1] > valueOfPoi)){
      outputBoundary <- c(rangeListSingColumn[step], rangeListSingColumn[step+1])
      return(outputBoundary)
    }
    step = step + 1
  }
}

singlePointBoundaryXY <- function(inputDF.single, Xcolname, Ycolname,
                                  xRangeList, yRangeList, clusterNumber = 4){
  xValueOfPoi = inputDF.single[,Xcolname]
  yValueOfPoi = inputDF.single[,Ycolname]
  xRangeBoundary <- data.frame(Doubles=double(),
                               Integers=integer(),
                               Factors=factor(),
                               Logicals=logical(),
                               Characters=character(),
                               stringsAsFactors=FALSE)
  
  for(i in seq(1,ncol(xRangeList),1)) {
    xBoundarySingleTree <- boundaryValuesSelectionSingleTree(xValueOfPoi, xRangeList[,i]) 
    xRangeBoundary <- rbind(xRangeBoundary, xBoundarySingleTree)
  }
  xRangeBoundary <- xRangeBoundary %>% as.data.frame()
  colnames(xRangeBoundary) <- c("xLower", "xUpper")
  
  yRangeBoundary <- data.frame(Doubles=double(),
                               Integers=integer(),
                               Factors=factor(),
                               Logicals=logical(),
                               Characters=character(),
                               stringsAsFactors=FALSE)
  for(i in seq(1,ncol(xRangeList),1)) {
    yBoundarySingleTree <- boundaryValuesSelectionSingleTree(yValueOfPoi, yRangeList[,i]) 
    yRangeBoundary <- rbind(yRangeBoundary, yBoundarySingleTree)
  }
  yRangeBoundary <- yRangeBoundary %>% as.data.frame()
  colnames(yRangeBoundary) <- c("yLower", "yUpper")
  #we find median small in the left side, from here absolutely more than half amounts 
  # of lines are overlaped.
  # the the left side becomes smaller and smaller until right side small than median
  
  xLeft <- median(xRangeBoundary$xLower)
  xRight <- median(xRangeBoundary$xUpper)
  
  yBottom <- median(yRangeBoundary$yLower)
  yRoof <- median(yRangeBoundary$yUpper)
  
  boundaryXY <- c(xLeft, xRight, yBottom, yRoof)
  return(boundaryXY)
}

progress_fun <- function(n){
  cat(n, ' ')
  if (n%%100==0){
    cat('\n')
  }
}

neighborBoundaryDataFrame <- function(dfUsedInRf, Xcolname, Ycolname, 
                                      xRangeList, yRangeList, clusterNumber = 4){
  cat("Bar:", nrow(dfUsedInRf), " \n")
  cl <- makeSOCKcluster(clusterNumber)
  clusterExport(cl, "singlePointBoundaryXY")
  clusterExport(cl, "boundaryValuesSelectionSingleTree")
  registerDoSNOW(cl)
  opts <- list(progress=progress_fun)
  df <-
    foreach(i = seq(1,nrow(dfUsedInRf),1), .combine = 'rbind', 
            .packages='tidyverse', .export = c("singlePointBoundaryXY",
                                               "boundaryValuesSelectionSingleTree"),
            .options.snow=opts) %dopar% {
              boundaryTibble <- singlePointBoundaryXY(dfUsedInRf[i,], Xcolname=Xcolname, Ycolname=Ycolname,
                                                      yRangeList=yRangeList, xRangeList=xRangeList)
              
            }
  stopCluster(cl)
  colnames(df) <- c("xLeft", "xRight", "yBottom", "yRoof")
  return(df)
}

### example
# not super
#load("DP02/04_Results/10_RFresult_49var_weighted.RData")
#load("DP02/02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")


load("04_Results/10_RFresult_49var_weighted.RData")
load("02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")

yRangeList <- treeRangeList(data.rf.49.weighted, 'Y', 10)
xRangeList <- treeRangeList(data.rf.49.weighted, 'X', 10)


boundaryTibble <- neighborBoundaryDataFrame(data_49, "X", "Y", xRangeList, yRangeList, 10)
