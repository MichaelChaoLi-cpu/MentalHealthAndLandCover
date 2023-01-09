# Author: M.L.


# Note: this script to make the all data raw
# Note: di_inc_gdp is from 0

# end

library(tidyverse)
library(dplyr)


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

data_49$di_inc_gdp <- data_49$di_inc_gdp + 1
saveRDS(data_49, file = "02_Data/SP_Data_49Variable_RdsVer.Rds", version = 2)

data_49_coun <- data_t %>% dplyr::select(GHQ12, country,
                                         di_inc_gdp, social_class,student:unemployed,
                                         pleasure_all:smile_all,
                                         euthusiastic:uncreative, urban_cent:rural_area,
                                         income_group, female_dummy, age, sr_health, bachelor:phd,
                                         com_livable:com_satety, child_num, crop2015:wate2015, impe2015,
                                         bare2015, X, Y) %>%
  na.omit()

data_49_coun$di_inc_gdp <- data_49_coun$di_inc_gdp + 1
saveRDS(data_49_coun, file = "02_Data/SP_Data_49Variable_counRdsVer.Rds", version = 2)
