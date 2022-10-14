# Author: M.L.

# Aim: this script is to calculation monetary value of counterfactual
# on HPC

# end

library(randomForest)
library(tidyverse)
library(dplyr)
library(foreach)
library(doParallel)
library(doSNOW)

source("DP02/03_RCode/SP_13_AF_CounterfactualCalibrationIncome_v1.R")

load("DP02/02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")
load("DP02/04_Results/10_RFresult_49var_weighted.RData")
X <- dataPre(data_49)

notHave <- T
if(notHave){
  counterfactualValueOfCropChangeReversal0.01 <-
    aggregateCounterfactual(X, data.rf.49.weighted, "di_inc_gdp",marginalChange = 0.01,
                            0.01, "crop2015", 10, 10^-3, 20)
  save(counterfactualValueOfCropChangeReversal0.01, file = "DP02/04_Results/96_test_counterfactualValueOfCropChangeReversal0.01.Rdata")
  counterfactualValueOfForeChangeReversal0.01 <-
    aggregateCounterfactual(X, data.rf.49.weighted, "di_inc_gdp",marginalChange = 0.01,
                            0.01, "fore2015", 10, 10^-3, 20)
  save(counterfactualValueOfForeChangeReversal0.01, file = "DP02/04_Results/96_test_counterfactualValueOfForeChangeReversal0.01.Rdata") 
  counterfactualValueOfGrasChangeReversal0.01 <-
    aggregateCounterfactual(X, data.rf.49.weighted, "di_inc_gdp",marginalChange = 0.01,
                            0.01, "gras2015", 10, 10^-3, 20)
  save(counterfactualValueOfGrasChangeReversal0.01, file = "DP02/04_Results/96_test_counterfactualValueOfGrasChangeReversal0.01.Rdata")
  counterfactualValueOfShruChangeReversal0.01 <-
    aggregateCounterfactual(X, data.rf.49.weighted, "di_inc_gdp",marginalChange = 0.01,
                            0.01, "shru2015", 10, 10^-3, 20)
  save(counterfactualValueOfShruChangeReversal0.01, file = "DP02/04_Results/96_test_counterfactualValueOfShruChangeReversal0.01.Rdata")
  counterfactualValueOfWetlChangeReversal0.01 <-
    aggregateCounterfactual(X, data.rf.49.weighted, "di_inc_gdp",marginalChange = 0.01,
                            0.01, "wetl2015", 10, 10^-3, 20)
  save(counterfactualValueOfWetlChangeReversal0.01, file = "DP02/04_Results/96_test_counterfactualValueOfWetlChangeReversal0.01.Rdata")
  counterfactualValueOfWateChangeReversal0.01 <-
    aggregateCounterfactual(X, data.rf.49.weighted, "di_inc_gdp",marginalChange = 0.01,
                            0.01, "wate2015", 10, 10^-3, 20)
  save(counterfactualValueOfWateChangeReversal0.01, file = "DP02/04_Results/96_test_counterfactualValueOfWateChangeReversal0.01.Rdata")
  counterfactualValueOfImpeChangeReversal0.01 <-
    aggregateCounterfactual(X, data.rf.49.weighted, "di_inc_gdp",marginalChange = 0.01,
                            0.01, "impe2015", 10, 10^-3, 20)
  save(counterfactualValueOfImpeChangeReversal0.01, file = "DP02/04_Results/96_test_counterfactualValueOfImpeChangeReversal0.01.Rdata")
  counterfactualValueOfBareChangeReversal0.01 <-
    aggregateCounterfactual(X, data.rf.49.weighted, "di_inc_gdp",marginalChange = 0.01,
                            0.01, "bare2015", 10, 10^-3, 20)
  save(counterfactualValueOfBareChangeReversal0.01, file = "DP02/04_Results/96_test_counterfactualValueOfBareChangeReversal0.01.Rdata")
}