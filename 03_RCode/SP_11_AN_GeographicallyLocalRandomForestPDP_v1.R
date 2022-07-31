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

yRangeList <- treeRangeList(data.rf.49.weighted, 'Y', 100)
xRangeList <- treeRangeList(data.rf.49.weighted, 'X', 100)

boundaryTibble <- neighborBoundaryDataFrame(data_49, "X", "Y", xRangeList, yRangeList, 100)

save(boundaryTibble, file = "DP02/04_Results/99_temp_boundaryTibble.Rdata")