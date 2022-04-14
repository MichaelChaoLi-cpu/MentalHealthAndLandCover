# Author: M.L.



# end

library(ggplot2)
library(cowplot)
library(foreach)
library(doParallel)
library(randomForest)
library(tidyverse)
library(DALEX)

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