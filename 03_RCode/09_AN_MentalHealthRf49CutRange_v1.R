# Author: M.L.


# Note: this script to change the range of some land cover variables

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

load("01_PrivateData/01_Dataset.RData")
load("01_PrivateData/02_coordOfSID.RData")

coordDF$StandardID <- coordDF$StandardID %>% as.numeric() 
colnames(coordDF)[1] <- "ID"
coordDF <- coordDF %>% as.tibble()

data <- left_join(data, coordDF)
data_t <- data %>%
  dplyr::select(over_LS, country, ind_income_usd, di_inc_gdp, weather, trust, trusted, social_class, income_group,
                female_dummy, age, GHQ12, GHQ12_1:GHQ12_12, sr_health, student:unemployed, bachelor:phd,
                pleasure_all, anger_all, sadness_all, enjoyment_all, smile_all,
                pleasure_wk, anger_wk, sadness_wk, enjoyment_wk, smile_wk,
                com_livable, com_attach, com_satety, partner_dummy, 
                child_num, child_u6_num, family_mem, im_relat_fami:im_object_media, dis_space_home:uncreative,
                prec:snow2015, X, Y, ID)

### we build the dataset with 49 predictors compare to data_47 we add X and Y
### since residuals are correlated with y, so we need to add the weights to solve this problem.
data_49 <- data_t %>% dplyr::select(GHQ12, di_inc_gdp, social_class,student:unemployed,
                                    pleasure_all:smile_all,
                                    euthusiastic:uncreative, urban_cent:rural_area,
                                    income_group, female_dummy, age, sr_health, bachelor:phd,
                                    com_livable:com_satety, child_num, crop2015:wate2015, impe2015,
                                    bare2015, X, Y) %>%
  na.omit()

GHQ12_count <- data_49 %>% count(GHQ12)
GHQ12_count$weights <- 1/(GHQ12_count$n/max(GHQ12_count$n))
GHQ12_count <- GHQ12_count %>% dplyr::select(GHQ12, weights)
data_49 <- left_join(data_49, GHQ12_count)

### data correction
data_49 <- data_49 %>%
  mutate(di_inc_gdp = ifelse(di_inc_gdp > 3, 3, di_inc_gdp))
#here, we think the indiviudal income = 400% gdp per capita is very high
hist(data_49$shru2015, breaks = seq(0, 100, by = 0.05), ylim = c(0, 20)) # 0 - 40
data_49 <- data_49 %>%
  mutate(shru2015 = ifelse(shru2015 > 40, 40, shru2015))
#here, according to distribution of shru2015, we cut shru2015 to 40
hist(data_49$wetl2015, breaks = seq(0, 100, by = 0.05), ylim = c(0, 10), xlim = c(0, 5)) # 0 - 3 
data_49 <- data_49 %>%
  mutate(wetl2015 = ifelse(wetl2015 > 3, 3, wetl2015))
#here, according to distribution of wetl2015, we cut wetl2015 to 3
hist(data_49$wate2015, breaks = seq(0, 60, by = 0.05), ylim = c(0, 20)) #0 - 50
data_49 <- data_49 %>%
  mutate(wate2015 = ifelse(wate2015 > 50, 50, wate2015))
#here, according to distribution of wate2015, we cut wate2015 to 60
hist(data_49$bare2015, breaks = seq(0, 100, by = 0.05), ylim = c(0, 20)) #0 - 20
data_49 <- data_49 %>%
  mutate(bare2015 = ifelse(bare2015 > 20, 20, bare2015))

save(data_49, file = "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData", version = 2) 

cl <- makeSOCKcluster(10)
registerDoSNOW(cl)
getDoParWorkers()

ntasks <- 100
pb <- tkProgressBar(max=ntasks)
progress <- function(n) setTkProgressBar(pb, n)
opts <- list(progress=progress)

data_49_no_weights <- data_49 %>% dplyr::select(-weights)

data.rf.49.weighted <- 
  foreach(ntree = rep(10, ntasks), .combine = randomForest::combine,
          .multicombine=TRUE, .packages='randomForest',
          .options.snow=opts) %dopar% {
            randomForest(GHQ12 ~ .,  data_49_no_weights,
                         na.action = na.omit, weights = data_49$weights,
                         ntree = ntree, importance = T, mtry = 16)
          }

stopCluster(cl)
# do SNOW
plot(data.rf.49.weighted)
importance(data.rf.49.weighted)
varImpPlot(data.rf.49.weighted)
print(data.rf.49.weighted)

### calculate loss function
loss_root_mean_square(data_49$GHQ12, yhat(data.rf.49.weighted, data_49_no_weights))

### unified the model
explainer_data.rf.49.weighted = explain(data.rf.49.weighted, data = data_49_no_weights, 
                                        y = data_49_no_weights$GHQ12)
diag_data.rf.49.weighted <- model_diagnostics(explainer_data.rf.49.weighted)
plot(diag_data.rf.49.weighted)
plot(diag_data.rf.49.weighted, variable = "y", yvariable = "residuals")
hist(data_49$GHQ12, breaks = rep(0:36, 1))

### model information
model_info(data.rf.49.weighted)

### Dataset Level Variable Importance as Change in Loss Function after Variable Permutations
data.rf.49.weightedr_aps <- model_parts(explainer_data.rf.49.weighted, type = "raw")
head(data.rf.49.weightedr_aps, 10)
plot(data.rf.49.weightedr_aps)

### model performance
model_performance_data.rf.49.weighted <- model_performance(explainer_data.rf.49.weighted)
model_performance_data.rf.49.weighted
plot(model_performance_data.rf.49.weighted)

### Dataset Level Variable Profile as Partial Dependence or Accumulated Local Dependence Explanations
model_profile_data.rf.49.weighted <- model_profile(explainer_data.rf.49.weighted)
plot(model_profile_data.rf.49.weighted, 
     variables = c("crop2015", "fore2015", "bare2015","impe2015"))
plot(model_profile_data.rf.49.weighted, 
     variables = c("gras2015", "shru2015", "wetl2015","wate2015"))
plot(model_profile_data.rf.49.weighted, variables = "di_inc_gdp")

save(data.rf.49.weighted, file = "04_Results/10_RFresult_49var_weighted.RData", version = 2)

singleTree <- getTree(data.rf.49.weighted, k=1, labelVar = T)
singleTree <- singleTree %>% filter(`split var` == 'Y')

singleTree2 <- getTree(data.rf.49.weighted, k=2, labelVar = T)
singleTree2 <- singleTree2 %>% filter(`split var` == 'Y')
