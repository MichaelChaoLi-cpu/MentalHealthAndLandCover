# Author: M.L.



# end

library(foreach)
#library(doParallel)
library(randomForest)
library(tidyverse)
library(doSNOW)

load("DP02/02_Data/SP_Data_48Variable_Weights.RData")

# do SNOW
cl <- makeSOCKcluster(36)
registerDoSNOW(cl)
getDoParWorkers()

data_48_no_weights <- data_48 %>% dplyr::select(-weights)

data.rf.48.weighted <- 
  foreach(ntree = rep(10, 100), .combine = randomForest::combine,
          .multicombine=TRUE, .packages='randomForest') %dopar% {
            randomForest(GHQ12 ~ .,  data_48_no_weights,
                         na.action = na.omit, weights = data_48$weights,
                         ntree = ntree, importance = T, mtry = 16)
          }

stopCluster(cl)

save(data.rf.48.weighted, file = "DP02/04_Results/01_RFresult_48var_weighted.RData")
