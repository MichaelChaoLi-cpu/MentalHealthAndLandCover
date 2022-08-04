# Author: M.L.

# Note: using 3 nodes, with 108 cores

# end

'
DP02_SP_11_AN_batch.sh

#!/bin/bash
#PJM -L "rscunit=ito-a"
#PJM -L "rscgrp=ito-m"
#PJM -L "vnode=3"
#PJM -L "vnode-core=36"
#PJM -L "elapse=24:00:00"
#PJM -j
#PJM -X

source init.sh

R --slave --vanilla --args 10 20 < /home/usr6/q70176a/DP02/03_RCode/SP_11_AN_GeographicallyLocalRandomForestPDP_v1.R
'

library(randomForest)
library(tidyverse)
library(dplyr)
library(foreach)
library(doParallel)
library(doSNOW)

source("DP02/03_RCode/SP_10_AF_GeographicallyLocalRandomForestPDP_v1.R")

load("DP02/04_Results/10_RFresult_49var_weighted.RData")
load("DP02/02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")

cat("loaded data! \n")

notHave <- F
if(notHave){
  yRangeList <- treeRangeList(data.rf.49.weighted, 'Y', 20)
  xRangeList <- treeRangeList(data.rf.49.weighted, 'X', 20)
}

cat("Range data! \n")

notHave <- F
if(notHave){
  boundaryTibble <- neighborBoundaryDataFrame(data_49, "X", "Y", xRangeList, yRangeList, 100)
  save(boundaryTibble, file = "DP02/04_Results/99_temp_boundaryTibble.Rdata")
} else {
  load("DP02/04_Results/99_temp_boundaryTibble.Rdata")
}

notHave <- F
if(notHave){
  neighborOrderListTibble <- neighborOrderList(boundaryTibble, data_49, "X", "Y", 1000, 100)
  save(neighborOrderListTibble, file = "DP02/04_Results/99_temp_neighborOrderListTibble.Rdata")
} else {
  load("DP02/04_Results/99_temp_neighborOrderListTibble.Rdata")
}

crop <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "crop2015", 0.1, 100)
fore <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "fore2015", 0.1, 100)
gras <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "gras2015", 0.1, 100)
shru <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "shru2015", 0.1, 100)
wetl <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "wetl2015", 0.1, 100)
wate <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "wate2015", 0.1, 100)
impe <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "impe2015", 0.1, 100)
bare <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "bare2015", 0.1, 100)
income <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "di_inc_gdp", 0.1, 100)

geographicallyMarginalEffect <- cbind(crop, fore, gras, shru, wetl, wate, impe, bare, income)
save(geographicallyMarginalEffect, file = "DP02/04_Results/99_temp_neighborOrderListTibble.Rdata")
