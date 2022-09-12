# Author: M.L.


# end

library(tidyverse)
library(dplyr)
library(sp)

source("DP02/03_RCode/16_AF_LocalMeanBasedonRF_v1.R")

load("DP02/04_Results/97_temp_bareCounterfactualValue.Rdata")
load("DP02/04_Results/97_temp_cropCounterfactualValue.Rdata")
load("DP02/04_Results/97_temp_foreCounterfactualValue.Rdata")
load("DP02/04_Results/97_temp_grasCounterfactualValue.Rdata")
load("DP02/04_Results/97_temp_impeCounterfactualValue.Rdata")
load("DP02/04_Results/97_temp_shruCounterfactualValue.Rdata")
load("DP02/04_Results/97_temp_wateCounterfactualValue.Rdata")
load("DP02/04_Results/97_temp_wetlCounterfactualValue.Rdata")

load("DP02/02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")

dataWithCounterfactual <- cbind(data_49, counterfactualValueOfBareChange1, counterfactualValueOfCropChange1,
                                counterfactualValueOfForeChange1, counterfactualValueOfGrasChange1,
                                counterfactualValueOfImpeChange1, counterfactualValueOfShruChange1,
                                counterfactualValueOfWateChange1, counterfactualValueOfWetlChange1)

load("DP02/04_Results/99_temp_neighborOrderListTibble.Rdata")

bare.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfBareChange1",
                                      neighborOrderListTibble, 18)
saveRDS(bare.table, file = "DP02/04_Results/97_temp_counterfactualValueOfBareChange1.rds")
cat("bare.table\n\n\n")
crop.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfCropChange1",
                                      neighborOrderListTibble, 18)
saveRDS(crop.table, file = "DP02/04_Results/97_temp_counterfactualValueOfCropChange1.rds")
cat("crop.table\n\n\n")
fore.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfForeChange1",
                                      neighborOrderListTibble, 18)
saveRDS(fore.table, file = "DP02/04_Results/97_temp_counterfactualValueOfForeChange1.rds")
cat("fore.table\n\n\n")
gras.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfGrasChange1",
                                      neighborOrderListTibble, 18)
saveRDS(gras.table, file = "DP02/04_Results/97_temp_counterfactualValueOfGrasChange1.rds")
cat("gras.table\n\n\n")
impe.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfImpeChange1",
                                      neighborOrderListTibble, 18)
saveRDS(impe.table, file = "DP02/04_Results/97_temp_counterfactualValueOfImpeChange1.rds")
cat("impe.table\n\n\n")
shru.table <- localNeighborMeanSePvalSingle(dataWithCounterfactual, "counterfactualValueOfShruChange1",
                                      neighborOrderListTibble)
saveRDS(shru.table, file = "DP02/04_Results/97_temp_counterfactualValueOfShruChange1.rds")
cat("shru.table\n\n\n")
wate.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfWateChange1",
                                      neighborOrderListTibble, 3)
saveRDS(wate.table, file = "DP02/04_Results/97_temp_counterfactualValueOfWateChange1.rds")
cat("wate.table\n\n\n")
wetl.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfWetlChange1",
                                      neighborOrderListTibble, 3)
saveRDS(wetl.table, file = "DP02/04_Results/97_temp_counterfactualValueOfWetlChange1.rds")
cat("wetl.table\n\n\n")

