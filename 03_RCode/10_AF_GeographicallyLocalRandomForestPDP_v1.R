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

singlePointBoundaryXY <- function(inputDF.single, Xcolname, Ycolname,
                                  xRangeList, yRangeList, clusterNumber = 4){
  xValueOfPoi = inputDF.single[,Xcolname]
  yValueOfPoi = inputDF.single[,Ycolname]
  cl <- makeSOCKcluster(clusterNumber)
  clusterExport(cl, "boundaryValuesSelectionSingleTree")
  registerDoSNOW(cl)
  xRangeBoundary <-
    foreach(i = seq(1,ncol(xRangeList),1), .combine = 'rbind', 
          .packages='tidyverse', .export = "boundaryValuesSelectionSingleTree") %dopar% {
            xBoundarySingleTree <- 
              boundaryValuesSelectionSingleTree(xValueOfPoi, xRangeList[,i]) 
          }
  xRangeBoundary <- xRangeBoundary %>% as.data.frame()
  colnames(xRangeBoundary) <- c("xLower", "xUpper")
  yRangeBoundary <-
    foreach(i = seq(1,ncol(yRangeList),1), .combine = 'rbind', 
            .packages='tidyverse', .export = "boundaryValuesSelectionSingleTree") %dopar% {
              yBoundarySingleTree <- 
                boundaryValuesSelectionSingleTree(yValueOfPoi, yRangeList[,i])
            }
  yRangeBoundary <- yRangeBoundary %>% as.data.frame()
  colnames(yRangeBoundary) <- c("yLower", "yUpper")
  stopCluster(cl)
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

neighborBoundaryDataFrame <- function(dfUsedInRf, Xcolname, Ycolname, 
                                      xRangeList, yRangeList, clusterNumber = 4){
  df = data.frame(Doubles=double(),
                  Integers=integer(),
                  Factors=factor(),
                  Logicals=logical(),
                  Characters=character(),
                  stringsAsFactors=FALSE)
  i = 1
  cat("Bar:", nrow(dfUsedInRf), " \n")
  while(i < (nrow(dfUsedInRf) + 1)){
    boundaryTibble <- singlePointBoundaryXY(dfUsedInRf[i,], Xcolname=Xcolname, Ycolname=Ycolname,
                                            yRangeList=yRangeList, xRangeList=xRangeList,
                                            clusterNumber=clusterNumber)
    df <- rbind(df, boundaryTibble)
    if(i%%floor(nrow(dfUsedInRf)/100)>(floor(nrow(dfUsedInRf)/100)-1)){
      cat('.')
    }
    if(i%%floor(nrow(dfUsedInRf)/500)>(floor(nrow(dfUsedInRf)/500)-1)){
      cat('|')
    }
    i = i + 1
  }
  colnames(df) <- c("xLeft", "xRight", "yBottom", "yRoof")
  return(df)
}

### example
yRangeList <- treeRangeList(data.rf.49.weighted, 'Y', 10)
xRangeList <- treeRangeList(data.rf.49.weighted, 'X', 10)


boundaryTibble <- neighborBoundaryDataFrame(data_49, "X", "Y", xRangeList, yRangeList, 10)
