# Author: M.L.


# Note: this script to change the range of some land cover variables

# end

library(ggplot2)
library(cowplot)
library(foreach)
#library(doParallel)
library(randomForest)
library(tidyverse)
library(DALEX)
library(doSNOW)
library(tcltk)
library(pdp)

set.seed(123)

load("01_PrivateData/01_Dataset.RData")

data_t <- data %>%
  dplyr::select(over_LS, country, ind_income_usd, di_inc_gdp, weather, trust, trusted, social_class, income_group,
                female_dummy, age, GHQ12, GHQ12_1:GHQ12_12, sr_health, student:unemployed, bachelor:phd,
                pleasure_all, anger_all, sadness_all, enjoyment_all, smile_all,
                pleasure_wk, anger_wk, sadness_wk, enjoyment_wk, smile_wk,
                com_livable, com_attach, com_satety, partner_dummy, 
                child_num, child_u6_num, family_mem, im_relat_fami:im_object_media, dis_space_home:uncreative,
                prec:snow2015)

### we build the dataset with 47 predictors
### since residuals are correlated with y, so we need to add the weights to solve this problem.
data_47 <- data_t %>% dplyr::select(GHQ12, di_inc_gdp, social_class,student:unemployed,
                                    pleasure_all:smile_all,
                                    euthusiastic:uncreative, urban_cent:rural_area,
                                    income_group, female_dummy, age, sr_health, bachelor:phd,
                                    com_livable:com_satety, child_num, crop2015:wate2015, impe2015,
                                    bare2015) %>%
  na.omit()

GHQ12_count <- data_47 %>% count(GHQ12)
GHQ12_count$weights <- 1/(GHQ12_count$n/max(GHQ12_count$n))
GHQ12_count <- GHQ12_count %>% dplyr::select(GHQ12, weights)
data_47 <- left_join(data_47, GHQ12_count)

### data correction
data_47 <- data_47 %>%
  mutate(di_inc_gdp = ifelse(di_inc_gdp > 3, 3, di_inc_gdp))
#here, we think the indiviudal income = 400% gdp per capita is very high
hist(data_47$shru2015, breaks = seq(0, 100, by = 0.05), ylim = c(0, 20)) # 0 - 40
data_47 <- data_47 %>%
  mutate(shru2015 = ifelse(shru2015 > 40, 40, shru2015))
#here, according to distribution of shru2015, we cut shru2015 to 40
hist(data_47$wetl2015, breaks = seq(0, 100, by = 0.05), ylim = c(0, 10), xlim = c(0, 5)) # 0 - 3 
data_47 <- data_47 %>%
  mutate(wetl2015 = ifelse(wetl2015 > 3, 3, wetl2015))
#here, according to distribution of wetl2015, we cut wetl2015 to 3
hist(data_47$wate2015, breaks = seq(0, 60, by = 0.05), ylim = c(0, 20)) #0 - 50
data_47 <- data_47 %>%
  mutate(wate2015 = ifelse(wate2015 > 50, 50, wate2015))
#here, according to distribution of wate2015, we cut wate2015 to 60
hist(data_47$bare2015, breaks = seq(0, 100, by = 0.05), ylim = c(0, 20)) #0 - 20
data_47 <- data_47 %>%
  mutate(bare2015 = ifelse(bare2015 > 20, 20, bare2015))

save(data_47, file = "02_Data/SP_Data_47Variable_Weights_changeRangeOfLandCover.RData", version = 2) 


# do SNOW
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

ntasks <- 100
pb <- tkProgressBar(max=ntasks)
progress <- function(n) setTkProgressBar(pb, n)
opts <- list(progress=progress)

data_47_no_weights <- data_47 %>% dplyr::select(-weights)

data.rf.47.weighted <- 
  foreach(ntree = rep(10, ntasks), .combine = randomForest::combine,
          .multicombine=TRUE, .packages='randomForest',
          .options.snow=opts) %dopar% {
            randomForest(GHQ12 ~ .,  data_47_no_weights,
                         na.action = na.omit, weights = data_47$weights,
                         ntree = ntree, importance = T, mtry = 16)
          }

stopCluster(cl)
# do SNOW
plot(data.rf.47.weighted)
importance(data.rf.47.weighted)
varImpPlot(data.rf.47.weighted)
print(data.rf.47.weighted)

### calculate loss function
loss_root_mean_square(data_47$GHQ12, yhat(data.rf.47.weighted, data_47_no_weights))

### unified the model
explainer_data.rf.47.weighted = explain(data.rf.47.weighted, data = data_47_no_weights, 
                                        y = data_47_no_weights$GHQ12)
diag_data.rf.47.weighted <- model_diagnostics(explainer_data.rf.47.weighted)
plot(diag_data.rf.47.weighted)
plot(diag_data.rf.47.weighted, variable = "y", yvariable = "residuals")
hist(data_47$GHQ12, breaks = rep(0:36, 1))

### model information
model_info(data.rf.47.weighted)

### Dataset Level Variable Importance as Change in Loss Function after Variable Permutations
data.rf.47.weightedr_aps <- model_parts(explainer_data.rf.47.weighted, type = "raw")
head(data.rf.47.weightedr_aps, 10)
plot(data.rf.47.weightedr_aps)

### model performance
model_performance_data.rf.47.weighted <- model_performance(explainer_data.rf.47.weighted)
model_performance_data.rf.47.weighted
plot(model_performance_data.rf.47.weighted)

### Dataset Level Variable Profile as Partial Dependence or Accumulated Local Dependence Explanations
model_profile_data.rf.47.weighted <- model_profile(explainer_data.rf.47.weighted)
plot(model_profile_data.rf.47.weighted, 
     variables = c("crop2015", "fore2015", "bare2015","impe2015"))
plot(model_profile_data.rf.47.weighted, 
     variables = c("gras2015", "shru2015", "wetl2015","wate2015"))
plot(model_profile_data.rf.47.weighted, variables = "di_inc_gdp")

save(data.rf.47.weighted, file = "04_Results/01_RFresult_47var_weighted.RData", version = 2)

#### pdp
summary(data_47$impe2015)
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

pdp.result.impe2015 <- pdp::partial(data.rf.47.weighted, pred.var = "impe2015",
                               grid.resolution = 5001,
                               plot = F, rug = T, parallel = T,
                               paropts = list(.packages = "randomForest"))

stopCluster(cl)
registerDoSNOW()

summary(data_47$fore2015)
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

pdp.result.fore2015 <- pdp::partial(data.rf.47.weighted, pred.var = "fore2015",
                               grid.resolution = 5001,
                               plot = F, rug = T, parallel = T,
                               paropts = list(.packages = "randomForest"))

stopCluster(cl)
registerDoSNOW()

summary(data_47$crop2015)
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

pdp.result.crop2015 <- pdp::partial(data.rf.47.weighted, pred.var = "crop2015",
                               grid.resolution = 5000,
                               plot = F, rug = T, parallel = T,
                               paropts = list(.packages = "randomForest"))

stopCluster(cl)
registerDoSNOW()

summary(data_47$wetl2015)
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

pdp.result.wetl2015 <- pdp::partial(data.rf.47.weighted, pred.var = "wetl2015",
                                    grid.resolution = 3001,
                                    plot = F, rug = T, parallel = T,
                                    paropts = list(.packages = "randomForest"))

stopCluster(cl)
registerDoSNOW()

summary(data_47$bare2015)
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

pdp.result.bare2015 <- pdp::partial(data.rf.47.weighted, pred.var = "bare2015",
                                    grid.resolution = 4001,
                                    plot = F, rug = T, parallel = T,
                                    paropts = list(.packages = "randomForest"))

stopCluster(cl)
registerDoSNOW()

summary(data_47$gras2015)
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

pdp.result.gras2015 <- pdp::partial(data.rf.47.weighted, pred.var = "gras2015",
                                    grid.resolution = 5001,
                                    plot = F, rug = T, parallel = T,
                                    paropts = list(.packages = "randomForest"))

stopCluster(cl)
registerDoSNOW()

summary(data_47$shru2015)
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

pdp.result.shru2015 <- pdp::partial(data.rf.47.weighted, pred.var = "shru2015",
                                    grid.resolution = 4001,
                                    plot = F, rug = T, parallel = T,
                                    paropts = list(.packages = "randomForest"))

stopCluster(cl)
registerDoSNOW()

summary(data_47$wate2015)
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

pdp.result.wate2015 <- pdp::partial(data.rf.47.weighted, pred.var = "wate2015",
                                    grid.resolution = 5001,
                                    plot = F, rug = T, parallel = T,
                                    paropts = list(.packages = "randomForest"))

stopCluster(cl)
registerDoSNOW()

summary(data_47$di_inc_gdp)
cl <- makeSOCKcluster(14)
registerDoSNOW(cl)
getDoParWorkers()

pdp.result.di_inc <- pdp::partial(data.rf.47.weighted, pred.var = "di_inc_gdp",
                                    grid.resolution = 5001,
                                    plot = F, rug = T, parallel = T,
                                    paropts = list(.packages = "randomForest"))

stopCluster(cl)
registerDoSNOW()
### pdp

### plot and validation
plot(pdp.result.impe2015$impe2015, pdp.result.impe2015$yhat)

plot(pdp.result.fore2015$fore2015, pdp.result.fore2015$yhat)

plot(pdp.result.crop2015$crop2015, pdp.result.crop2015$yhat)

plot(pdp.result.wetl2015$wetl2015, pdp.result.wetl2015$yhat)

plot(pdp.result.bare2015$bare2015, pdp.result.bare2015$yhat)

plot(pdp.result.gras2015$gras2015, pdp.result.gras2015$yhat)

plot(pdp.result.shru2015$shru2015, pdp.result.shru2015$yhat)

plot(pdp.result.wate2015$wate2015, pdp.result.wate2015$yhat)

plot(pdp.result.di_inc$di_inc_gdp,pdp.result.di_inc$yhat)

save(pdp.result.impe2015, pdp.result.fore2015, pdp.result.crop2015,
     pdp.result.wetl2015, pdp.result.bare2015, pdp.result.gras2015,
     pdp.result.shru2015, pdp.result.wate2015,
     file = "04_Results/04_pdp_47weighted_resolution002.RData",
     version = 2)
