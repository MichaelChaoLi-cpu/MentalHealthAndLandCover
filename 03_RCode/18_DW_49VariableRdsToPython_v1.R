# Author: M.L.

# Note: we are going to discard the R code, and head into python

# end

library(tidyverse)
library(dplyr)

load(file = "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")

saveRDS(data_49, file = "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds", version = 2)


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
                                    bare2015, X, Y, country) %>%
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
levels(data_49$country) <- c("Japan", 'Thailand', "Malaysia", "Indonesia", "Singapore",
                             "Vietnam", "Philippines", "Mexico", "Venezuela", "Chile",
                             "Brazile", "Colombia", 'South Africa', "India", "Myanmar",
                             "Kazakhstan", "Mongolia", "Egypt", "Russia", "China",
                             "Australia", "United States", "Germany", "United Kingdom",
                             "France", "Spain", "Italy", "Sweden", "Canada",
                             "Netherlands", "Greece", "Turkey", "Hungary", "Poland",
                             "Czech", "Romania", "Sri Lanka")
data_49$country <- data_49$country %>% as.character()
saveRDS(data_49, file = "02_Data/SP_Data_49Variable_with_country.Rds", version = 2)

