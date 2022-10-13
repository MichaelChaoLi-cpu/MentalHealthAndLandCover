# Author: M.L.

# Note: we are going to discard the R code, and head into python

# end

library(tidyverse)
library(dplyr)

load(file = "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")

saveRDS(data_49, file = "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds", version = 2)
