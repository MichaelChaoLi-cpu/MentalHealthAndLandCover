# Author: M.L.



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

load("01_PrivateData\\01_Dataset.RData")

data_t <- data %>%
  dplyr::select(over_LS, country, ind_income_usd, di_inc_gdp, weather, trust, trusted, social_class, income_group,
                female_dummy, age, GHQ12, GHQ12_1:GHQ12_12, sr_health, student:unemployed, bachelor:phd,
                pleasure_all, anger_all, sadness_all, enjoyment_all, smile_all,
                pleasure_wk, anger_wk, sadness_wk, enjoyment_wk, smile_wk,
                com_livable, com_attach, com_satety, partner_dummy, 
                child_num, child_u6_num, family_mem, im_relat_fami:im_object_media, dis_space_home:uncreative,
                prec:snow2015)

################################# test ##################################
data_t <- data_t %>% dplyr::select(GHQ12, ind_income_usd, di_inc_gdp, social_class,
                                   income_group, female_dummy, age, sr_health, bachelor:phd,
                                   com_livable:com_satety, child_num, crop2015:bare2015) %>%
  na.omit()
data.rf.8 <- randomForest(GHQ12 ~ ., data = data_t, na.action = na.omit, ntree = 1000, 
                           importance = T, mtry = 8)
### since the there is 23 predictors, we select 23/3 ~ 8
plot(data.rf.8)
importance(data.rf.8)
varImpPlot(data.rf.8)
print(data.rf.8)

### calculate loss function
loss_root_mean_square(data_t$GHQ12, yhat(data.rf.8, data_t))

### unified the model
explainer_data.rf.8 = explain(data.rf.8, data = data_t, y = data_t$GHQ12)
diag_data.rf.8 <- model_diagnostics(explainer_data.rf.8)
plot(diag_data.rf.8)
plot(diag_data.rf.8, variable = "y", yvariable = "residuals")

### model information
model_info(data.rf.8)

### Dataset Level Variable Importance as Change in Loss Function after Variable Permutations
data.rf.8r_aps <- model_parts(explainer_data.rf.8, type = "raw")
head(data.rf.8r_aps, 8)
plot(data.rf.8r_aps)

### model performance
model_performance_data.rf.8 <- model_performance(explainer_data.rf.8)
model_performance_data.rf.8
plot(model_performance_data.rf.8)

### Dataset Level Variable Profile as Partial Dependence or Accumulated Local Dependence Explanations
model_profile_data.rf.8 <- model_profile(explainer_data.rf.8)
plot(model_profile_data.rf.8)


### we build the dataset with 48 predictors
data_48 <- data_t %>% dplyr::select(GHQ12, di_inc_gdp, social_class,student:unemployed,
                                   pleasure_all:smile_all,
                                   euthusiastic:uncreative, urban_cent:rural_area,
                                   income_group, female_dummy, age, sr_health, bachelor:phd,
                                   com_livable:com_satety, child_num, crop2015:bare2015) %>%
  na.omit()
data.rf.48 <- randomForest(GHQ12 ~ ., data = data_48, na.action = na.omit, ntree = 1000, 
                          importance = T, mtry = 16)
### since the there is 48 predictors, we select 48/3 ~ 16
plot(data.rf.48)
importance(data.rf.48)
varImpPlot(data.rf.48)
print(data.rf.48)

### calculate loss function
loss_root_mean_square(data_48$GHQ12, yhat(data.rf.48, data_48))

### unified the model
explainer_data.rf.48 = explain(data.rf.48, data = data_48, y = data_48$GHQ12)
diag_data.rf.48 <- model_diagnostics(explainer_data.rf.48)
plot(diag_data.rf.48)
plot(diag_data.rf.48, variable = "y", yvariable = "residuals")
hist(data_48$GHQ12, breaks = rep(0:36, 1))

### model information
model_info(data.rf.48)

### Dataset Level Variable Importance as Change in Loss Function after Variable Permutations
data.rf.48r_aps <- model_parts(explainer_data.rf.48, type = "raw")
head(data.rf.48r_aps, 10)
plot(data.rf.48r_aps)

### model performance
model_performance_data.rf.48 <- model_performance(explainer_data.rf.48)
model_performance_data.rf.48
plot(model_performance_data.rf.48)

### Dataset Level Variable Profile as Partial Dependence or Accumulated Local Dependence Explanations
model_profile_data.rf.48 <- model_profile(explainer_data.rf.48)
plot(model_profile_data.rf.48, 
     variables = c("crop2015", "fore2015", "bare2015","impe2015"))
plot(model_profile_data.rf.48, 
     variables = c("gras2015", "shru2015", "wetl2015","wate2015"))

save(data.rf.48, file = "04_Results/01_RFresult_48var.RData")

### we build the dataset with 48 predictors
### since residuals are correlated with y, so we need to add the weights to solve this problem.
data_48 <- data_t %>% dplyr::select(GHQ12, di_inc_gdp, social_class,student:unemployed,
                                    pleasure_all:smile_all,
                                    euthusiastic:uncreative, urban_cent:rural_area,
                                    income_group, female_dummy, age, sr_health, bachelor:phd,
                                    com_livable:com_satety, child_num, crop2015:bare2015) %>%
  na.omit()

GHQ12_count <- data_48 %>% count(GHQ12)
GHQ12_count$weights <- 1/(GHQ12_count$n/max(GHQ12_count$n))
GHQ12_count <- GHQ12_count %>% dplyr::select(GHQ12, weights)
data_48 <- left_join(data_48, GHQ12_count)

data.rf.48.weighted <- randomForest(GHQ12 ~ ., data = data_48 %>% dplyr::select(-weights), 
                                    na.action = na.omit, weights = data_48$weights,
                                    ntree = 1000, importance = T, mtry = 16)

# do SNOW
cl <- makeSOCKcluster(4)
registerDoSNOW(cl)

ntasks <- 100
pb <- tkProgressBar(max=ntasks)
progress <- function(n) setTkProgressBar(pb, n)
opts <- list(progress=progress)

data_48_no_weights <- data_48 %>% dplyr::select(-weights)

data.rf.48.weighted <- 
  foreach(ntree = rep(10, ntasks), .combine = combine,
          .multicombine=TRUE, .packages='randomForest',
          .options.snow=opts) %dopar% {
            randomForest(GHQ12 ~ .,  data_48_no_weights,
                         na.action = na.omit, weights = data_48$weights,
                         ntree = ntree, importance = T, mtry = 16)
            }
# do SNOW

lm(GHQ12 ~ ., data = data_48) %>% summary()

