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