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
  yRangeList <- treeRangeList(data.rf.49.weighted, 'Y', 36)
  xRangeList <- treeRangeList(data.rf.49.weighted, 'X', 36)
}

cat("Range data! \n")

notHave <- F
if(notHave){
  boundaryTibble <- neighborBoundaryDataFrame(data_49, "X", "Y", xRangeList, yRangeList, 36)
  save(boundaryTibble, file = "DP02/04_Results/99_temp_boundaryTibble.Rdata")
} else {
  load("DP02/04_Results/99_temp_boundaryTibble.Rdata")
}

notHave <- T
if(notHave){
  neighborOrderListTibble <- neighborOrderListDf(boundaryTibble, data_49, "X", "Y", 4000, 36)
  save(neighborOrderListTibble, file = "DP02/04_Results/99_temp_neighborOrderListTibble.Rdata")
} else {
  load("DP02/04_Results/99_temp_neighborOrderListTibble.Rdata")
}

notHave <- T
if(notHave){
	crop <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "crop2015", 0.1, 10)
	save(crop, file = "DP02/04_Results/98_temp_cropNeighborOrderListTibble.Rdata")
}

notHave <- F
if(notHave){
	fore <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "fore2015", 0.1, 10)
	save(fore, file = "DP02/04_Results/99_temp_foreNeighborOrderListTibble.Rdata")
}

notHave <- F
if(notHave){
	gras <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "gras2015", 0.1, 10)
	save(gras, file = "DP02/04_Results/99_temp_grasNeighborOrderListTibble.Rdata")
}

notHave <- F
if(notHave){
	shru <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "shru2015", 0.1, 10)
	save(shru, file = "DP02/04_Results/99_temp_shruNeighborOrderListTibble.Rdata")
}

notHave <- F
if(notHave){
	wetl <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "wetl2015", 0.1, 10)
	save(wetl, file = "DP02/04_Results/99_temp_wetlNeighborOrderListTibble.Rdata")
}

notHave <- F
if(notHave){
	wate <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "wate2015", 0.1, 10)
	save(wate, file = "DP02/04_Results/99_temp_wateNeighborOrderListTibble.Rdata")
}

notHave <- F
if(notHave){
	impe <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "impe2015", 0.1, 10)
	save(impe, file = "DP02/04_Results/99_temp_impeNeighborOrderListTibble.Rdata")
}

notHave <- F
if(notHave){
	bare <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "bare2015", 0.1, 10)
	save(bare, file = "DP02/04_Results/99_temp_bareNeighborOrderListTibble.Rdata")
}

income <- allDatasetEstiamtionBasedOnModel(data_49, data.rf.49.weighted, neighborOrderListTibble, "di_inc_gdp", 0.1, 10)
save(income, file = "DP02/04_Results/99_temp_incomeNeighborOrderListTibble.Rdata")

geographicallyMarginalEffect <- cbind(crop, fore, gras, shru, wetl, wate, impe, bare, income)
save(geographicallyMarginalEffect, file = "DP02/04_Results/99_temp_neighborOrderListTibble.Rdata")
