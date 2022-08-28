# Author: M.L.

# Since the relationships among variables in random forest are non-linear,
# directly using marginally substitute effects is not reasonable
# Counterfactual may be a way to get this.

# Therefore, 13_AF is designed

# end

library(ggplot2)
library(cowplot)
library(foreach)
library(doParallel)
library(randomForest)
library(tidyverse)
library(DALEX)
library(doSNOW)
library(tcltk)
library(pdp)

set.seed(123)

load(file = "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")
load("04_Results/98_temp_bareNeighborOrderListTibble.Rdata")
load("04_Results/98_temp_cropNeighborOrderListTibble.Rdata")
load("04_Results/98_temp_foreNeighborOrderListTibble.Rdata")
load("04_Results/98_temp_grasNeighborOrderListTibble.Rdata")
load("04_Results/98_temp_impeNeighborOrderListTibble.Rdata")
load("04_Results/98_temp_shruNeighborOrderListTibble.Rdata")
load("04_Results/98_temp_wateNeighborOrderListTibble.Rdata")
load("04_Results/98_temp_wetlNeighborOrderListTibble.Rdata")


#load("04_Results/98_temp_incomeNeighborOrderListTibble.Rdata")
#### this does not work, ignored

result_49 <- cbind(data_49, bare, crop, fore, gras, impe, shru,wate, wetl)

