# Author: M.L.

# output: 01_Dataset.RData

# 01_Dataset.RData: raw data set. In this data set, the features of interst are
#                   renamed.

# end

library(dplyr)
library(tidyverse)
library(foreign)

setwd("C:\\Users\\li.chao.987@s.kyushu-u.ac.jp\\OneDrive - Kyushu University\\04_Article\\")
data <- read.csv(file = "01_RawData\\country1_42.csv")
data_ori <- data

################# wash the data ########################
data <- data_ori %>% dplyr::select(-(S3_JP_Web:S3_LK_F2F_GN))
data <- data %>% 
  rename(ID = U_Sample_No)
data <- data %>%
  mutate(
    country = NA,
    country = ifelse(country_code == 1, 1, country),
    country = ifelse(country_code == 2, 2, country),
    country = ifelse(country_code == 3, 3, country),
    country = ifelse(country_code == 4 | country_code == 16, 4, country),
    country = ifelse(country_code == 5, 5, country),
    country = ifelse(country_code == 6 | country_code == 17, 6, country),
    country = ifelse(country_code == 7, 7, country),
    country = ifelse(country_code == 8, 8, country),
    country = ifelse(country_code == 9, 9, country),
    country = ifelse(country_code == 10, 10, country),
    country = ifelse(country_code == 11, 11, country),
    country = ifelse(country_code == 12, 12, country),
    country = ifelse(country_code == 13, 13, country),
    country = ifelse(country_code == 14 | country_code == 18 | country_code == 19 | country_code == 20, 14, country),
    country = ifelse(country_code == 15, 15, country),
    country = ifelse(country_code == 21, 16, country),
    country = ifelse(country_code == 22, 17, country),
    country = ifelse(country_code == 23, 18, country),
    country = ifelse(country_code > 23, country_code - 5, country),
  ) %>%
  dplyr::select(ID, country, everything())
data <- data %>% dplyr::select(-(Interviewer_ID:Sample_No)) #country code 1 - 37

data <- data %>%
  mutate(female_dummy = S1 - 1) #female_dummy == 1, if female
data <- data %>%
  mutate(age = S2) %>%
  dplyr::select(-(S1:S2))#age
data <- data %>%
  rename(
    over_LS = Q1_1,
    comm_LS = Q1_2,
    world_LS = Q1_3,
    over_HA = Q2_1,
    comm_HA = Q2_2,
    world_HA = Q2_3,
    cantril = Q3,
    worth_life = Q4,
    LS_10p = Q5
  ) #LS Happiness Cantril Ladder
data <- data %>%
  rename(
    trust = Q7_1,
    trusted = Q7_2,
    social_class = Q8,
    income_group = Q9
  )
data <- data %>%
  mutate(
    eco_ineq_local = ifelse(Q10 == 1, Q10SQ2_1, Q10SQ5_1),
    eco_ineq_nation = ifelse(Q10 == 1, Q10SQ2_2, Q10SQ5_2),
    eco_ineq_world = ifelse(Q10 == 1, Q10SQ2_3, Q10SQ5_3),
    soc_ineq_local = ifelse(Q10 == 1, Q10SQ2_1, Q10SQ5_4),
    soc_ineq_nation = ifelse(Q10 == 1, Q10SQ2_2, Q10SQ5_5),
    soc_ineq_world = ifelse(Q10 == 1, Q10SQ2_3, Q10SQ5_6)
  ) %>%
  dplyr::select((eco_ineq_local:soc_ineq_world), everything())
# inequality
data <- data %>%
  rename(
    pleasure_all = Q11_1_1,
    anger_all = Q11_1_2,
    sadness_all = Q11_1_3,
    enjoyment_all = Q11_1_4,
    smile_all = Q11_1_5,
    pleasure_wk = Q11_2_1,
    anger_wk = Q11_2_2,
    sadness_wk = Q11_2_3,
    enjoyment_wk = Q11_2_4,
    smile_wk = Q11_2_5
  ) # emotion
data <- data %>%
  rename(
    sr_health = Q12
  ) # self-reported health
data <- data %>%
  rename(
    com_livable = Q21,
    com_attach = Q22,
    com_satety = Q24
  )# community livable and attachment
data <- data %>%
  mutate(
    GHQ12 = Q26_1 + Q26_2 + Q26_3 + Q26_4 + Q26_5 + Q26_6 + Q26_7 + Q26_8 +
      Q26_9 + Q26_10 + Q26_11 + Q26_12 - 12
  ) 
data <- data %>%
  rename(
    GHQ12_1 = Q26_1, GHQ12_2 = Q26_2, GHQ12_3 = Q26_3,
    GHQ12_4 = Q26_4, GHQ12_5 = Q26_5, GHQ12_6 = Q26_6,
    GHQ12_7 = Q26_7, GHQ12_8 = Q26_8, GHQ12_9 = Q26_9,
    GHQ12_10 = Q26_10, GHQ12_11 = Q26_11, GHQ12_12 = Q26_12
  )
#GHQ12
data <- data %>%
  rename(partner_dummy = F1) # == 1, if yes
data <- data %>%
  mutate(
    ms_single_dummy = ifelse(F2 == 1, 1, 0),
    ms_married_dummy = ifelse(F2 == 2, 1, 0),
    ms_divorced_dummy = ifelse(F2 == 3, 1, 0)
  ) # marital status 
data <- data %>%
  rename(child_num = F3,
         child_u6_num = F3SQ,
         family_mem = F4)
data <- data %>%
  mutate(child_u6_num = ifelse(child_num == 0, 0, child_u6_num))# children and family number
data <- data %>%
  rename(job = F5) %>%
  mutate(student = ifelse(job == 7, 1, 0),
         worker = ifelse(job < 3, 1, 0),
         company_owner = ifelse(job == 3, 1, 0),
         government_officer = ifelse(job == 4, 1, 0),
         self_employed = ifelse(job == 6, 1, 0),
         professional = ifelse(job == 5, 1, 0),
         housewife = ifelse(job == 8, 1, 0),
         unemployed = ifelse(job == 9, 1, 0)
  ) # job
data <- data %>%
  rename(education_background = F10_1) %>%
  mutate(college_no_diploma = ifelse(education_background == 6 | education_background == 7, 1, 0),
         bachelor = ifelse(education_background == 8, 1, 0),
         master = ifelse(education_background == 9, 1, 0),
         phd = ifelse(education_background == 10, 1, 0)
  ) # educational backgroung

data <- data %>%
  rename(weather = S4)
data[data$weather == 1,]$weather <- "Sunny"
data[data$weather == 2,]$weather <- "Cloudy"
data[data$weather == 3,]$weather <- "L.Rain"
data[data$weather == 4,]$weather <- "H.Rain"
data[data$weather == 5,]$weather <- "Snowy"
data$weather <- data$weather %>% as.factor() #weather

data <- data %>%
  mutate(Q6SQ_1 = ifelse(Q6SQ_1 == 1, 1, 0))

#-----important items------
data <- data %>%
  mutate(
    im_relat_fami = ifelse(is.na(Q6_1), 0, 1),
    im_relat_fri = ifelse(is.na(Q6_2), 0, 1),
    im_nation_policy = ifelse(is.na(Q6_3), 0, 1),
    im_local_policy = ifelse(is.na(Q6_4), 0, 1),
    im_work = ifelse(is.na(Q6_5), 0, 1),
    im_religion = ifelse(is.na(Q6_6), 0, 1),
    im_medical_system = ifelse(is.na(Q6_7), 0, 1),
    im_edu = ifelse(is.na(Q6_8), 0, 1),
    im_edu_sys = ifelse(is.na(Q6_9), 0, 1),
    im_income = ifelse(is.na(Q6_10), 0, 1),
    im_preperty_right = ifelse(is.na(Q6_11), 0, 1),
    im_finan_system = ifelse(is.na(Q6_12), 0, 1),
    im_leisure = ifelse(is.na(Q6_13), 0, 1),
    im_social_pos = ifelse(is.na(Q6_14), 0, 1),
    im_patriotism = ifelse(is.na(Q6_15), 0, 1),
    im_surrounding_nature = ifelse(is.na(Q6_16), 0, 1),
    im_living_env = ifelse(is.na(Q6_17), 0, 1),
    im_freedom_speech = ifelse(is.na(Q6_18), 0, 1),
    im_object_media = ifelse(is.na(Q6_19), 0, 1),
  ) %>%
  dplyr::select(-(Q6_1:Q6_20))
col = c("im_relat_fami"  ,       "im_relat_fri"   ,      
        "im_nation_policy"   ,   "im_local_policy"   ,    "im_work"     ,          "im_religion"    ,      
        "im_medical_system"  ,   "im_edu"            ,    "im_edu_sys"  ,          "im_income"      ,      
        "im_preperty_right"  ,   "im_finan_system"   ,    "im_leisure"  ,          "im_social_pos"  ,      
        "im_patriotism"      ,   "im_surrounding_nature" ,"im_living_env" ,        "im_freedom_speech" ,   
        "im_object_media"  )
data[,col] <- lapply(data[,col], factor)
#-----important items------

#-----satisfied items------
data <- data %>%
  mutate(
    sat_relat_fami = ifelse(is.na(Q6SQ_1), 0, 1),
    sat_relat_fri = ifelse(is.na(Q6SQ_2), 0, 1),
    sat_nation_policy = ifelse(is.na(Q6SQ_3), 0, 1),
    sat_local_policy = ifelse(is.na(Q6SQ_4), 0, 1),
    sat_work = ifelse(is.na(Q6SQ_5), 0, 1),
    sat_religion = ifelse(is.na(Q6SQ_6), 0, 1),
    sat_medical_system = ifelse(is.na(Q6SQ_7), 0, 1),
    sat_edu = ifelse(is.na(Q6SQ_8), 0, 1),
    sat_edu_sys = ifelse(is.na(Q6SQ_9), 0, 1),
    sat_income = ifelse(is.na(Q6SQ_10), 0, 1),
    sat_preperty_right = ifelse(is.na(Q6SQ_11), 0, 1),
    sat_finan_system = ifelse(is.na(Q6SQ_12), 0, 1),
    sat_leisure = ifelse(is.na(Q6SQ_13), 0, 1),
    sat_social_pos = ifelse(is.na(Q6SQ_14), 0, 1),
    sat_patriotism = ifelse(is.na(Q6SQ_15), 0, 1),
    sat_surrounding_nature = ifelse(is.na(Q6SQ_16), 0, 1),
    sat_living_env = ifelse(is.na(Q6SQ_17), 0, 1),
    sat_freedom_speech = ifelse(is.na(Q6SQ_18), 0, 1),
    sat_object_media = ifelse(is.na(Q6SQ_19), 0, 1),
  ) %>%
  dplyr::select(-(Q6SQ_1:Q6SQ_0))
col = c("sat_relat_fami"    ,     "sat_relat_fri"     ,     "sat_nation_policy"    , 
        "sat_local_policy"   ,    "sat_work"           ,    "sat_religion"      ,     "sat_medical_system"   , 
        "sat_edu"          ,      "sat_edu_sys"         ,   "sat_income"     ,        "sat_preperty_right"   , 
        "sat_finan_system"  ,     "sat_leisure"       ,     "sat_social_pos"  ,       "sat_patriotism"    ,    
        "sat_surrounding_nature", "sat_living_env"    ,     "sat_freedom_speech"  ,   "sat_object_media"      )
data[,col] <- lapply(data[,col], factor)
#-----satisfied items------

#-----dissatisfied items of environment------
data <- data %>%
  mutate(
    dis_space_home = ifelse(is.na(Q20_1), 0, 1),
    dis_elecitricity = ifelse(is.na(Q20_2), 0, 1),
    dis_gas = ifelse(is.na(Q20_3), 0, 1),
    dis_water = ifelse(is.na(Q20_4), 0, 1),
    dis_gasoline = ifelse(is.na(Q20_5), 0, 1),
    dis_road = ifelse(is.na(Q20_6), 0, 1),
    dis_traf_congestion = ifelse(is.na(Q20_7), 0, 1),
    dis_access_trans = ifelse(is.na(Q20_8), 0, 1),
    dis_cong_public = ifelse(is.na(Q20_9), 0, 1),
    dis_traf_ctrl = ifelse(is.na(Q20_10), 0, 1),
    dis_commuting = ifelse(is.na(Q20_11), 0, 1),
    dis_food_supp = ifelse(is.na(Q20_12), 0, 1),
    dis_cong_center = ifelse(is.na(Q20_13), 0, 1),
    dis_pub_facilities = ifelse(is.na(Q20_14), 0, 1),
    dis_medical_sys = ifelse(is.na(Q20_15), 0, 1),
    dis_disaster_preve = ifelse(is.na(Q20_16), 0, 1),
    dis_landscape = ifelse(is.na(Q20_17), 0, 1),
    dis_noise = ifelse(is.na(Q20_18), 0, 1),
    dis_air_pollution = ifelse(is.na(Q20_19), 0, 1),
    dis_quality_water = ifelse(is.na(Q20_20), 0, 1),
    dis_greeness = ifelse(is.na(Q20_21), 0, 1)
  ) %>%
  dplyr::select(-(Q20_1:Q20_0))
col = c("dis_space_home"     ,    "dis_elecitricity"  ,     "dis_gas"      ,          
        "dis_water"          ,    "dis_gasoline"      ,     "dis_road"     ,          "dis_traf_congestion"  , 
        "dis_access_trans"   ,    "dis_cong_public"   ,     "dis_traf_ctrl",          "dis_commuting"        , 
        "dis_food_supp"      ,    "dis_cong_center"    ,    "dis_pub_facilities"  ,   "dis_medical_sys"   ,    
        "dis_disaster_preve" ,    "dis_landscape"      ,    "dis_noise"         ,     "dis_air_pollution"  ,   
        "dis_quality_water"  ,    "dis_greeness" )
data[,col] <- lapply(data[,col], factor)
#-----dissatisfied items of environment------

data <- data %>%
  mutate(
    satisf_income =  ifelse(F9 == 4, 1, 0)
  ) %>%
  dplyr::select(-F9) #satified with income
data$satisf_income <- as.factor(data$satisf_income)

data <- data %>%
  mutate(
    rent_apart =  ifelse(F11 == 1, 1, 0),
    own_apart =  ifelse(F11 == 2, 1, 0),
    rent_single_family =  ifelse(F11 == 3, 1, 0),
    own_single_family =  ifelse(F11 == 4, 1, 0),
  ) %>%
  dplyr::select(-F11) #house

#---------personality----------------
data <- data %>%
  mutate(
    euthusiastic =  ifelse(F13_1 == 3, 1, 0),
    critical =  ifelse(F13_2 == 3, 1, 0),
    dependable =  ifelse(F13_3 == 3, 1, 0),
    anxious =  ifelse(F13_4 == 3, 1, 0),
    open_to_new_exp =  ifelse(F13_5 == 3, 1, 0),
    reserved =  ifelse(F13_6 == 3, 1, 0),
    sympathetic =  ifelse(F13_7 == 3, 1, 0),
    careless =  ifelse(F13_8 == 3, 1, 0),
    calm =  ifelse(F13_9 == 3, 1, 0),
    uncreative =  ifelse(F13_10 == 3, 1, 0),
  ) %>%
  dplyr::select(-(F13_1:F13_10)) #house
col = c("euthusiastic"      ,     "critical"   ,            "dependable"      ,       "anxious"      ,         
        "open_to_new_exp"   ,     "reserved"   ,            "sympathetic"     ,       "careless"     ,         
        "calm"         ,          "uncreative"       )
data[,col] <- lapply(data[,col], factor)
#---------personality----------------

#---------work and go to school----------------
data <- data %>%
  mutate(
    day_commute = F16
  ) %>%
  dplyr::select(-F16)
data <- data %>%
  mutate(
    day_commute_conge = F16SQ2,
    day_commute_conge = ifelse(is.na(day_commute_conge), 0, day_commute_conge)
  )
#---------work and go to school----------------

#---------daily schedual----------------
data <- data %>%
  mutate(
    working_hour_workday = 0,
    working_hour_workday = ifelse(F17_1_1 == 0, 0, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 1, 0.25, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 2, 0.5, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 3, 1, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 4, 2, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 5, 3, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 6, 4, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 7, 5, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 8, 6, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 9, 7, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 10, 8, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 11, 9, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 12, 10, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 13, 11, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 14, 12, working_hour_workday),
    working_hour_workday = ifelse(F17_1_1 == 15, 14, working_hour_workday)
  )
data <- data %>%
  mutate(
    comm_hour_conge_wd = 0,
    comm_hour_conge_wd = ifelse(F17_1_2 == 0, 0, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 1, 0.25, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 2, 0.5, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 3, 1, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 4, 2, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 5, 3, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 6, 4, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 7, 5, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 8, 6, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 9, 7, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 10, 8, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 11, 9, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 12, 10, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 13, 11, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 14, 12, comm_hour_conge_wd),
    comm_hour_conge_wd = ifelse(F17_1_2 == 15, 14, comm_hour_conge_wd)
  )
data <- data %>%
  mutate(
    comm_hour_no_conge_wd = 0,
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 0, 0, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 1, 0.25, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 2, 0.5, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 3, 1, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 4, 2, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 5, 3, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 6, 4, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 7, 5, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 8, 6, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 9, 7, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 10, 8, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 11, 9, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 12, 10, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 13, 11, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 14, 12, comm_hour_no_conge_wd),
    comm_hour_no_conge_wd = ifelse(F17_1_3 == 15, 14, comm_hour_no_conge_wd)
  )
data <- data %>%
  mutate(
    housework_wd = 0,
    housework_wd = ifelse(F17_1_4 == 0, 0, housework_wd),
    housework_wd = ifelse(F17_1_4 == 1, 0.25, housework_wd),
    housework_wd = ifelse(F17_1_4 == 2, 0.5, housework_wd),
    housework_wd = ifelse(F17_1_4 == 3, 1, housework_wd),
    housework_wd = ifelse(F17_1_4 == 4, 2, housework_wd),
    housework_wd = ifelse(F17_1_4 == 5, 3, housework_wd),
    housework_wd = ifelse(F17_1_4 == 6, 4, housework_wd),
    housework_wd = ifelse(F17_1_4 == 7, 5, housework_wd),
    housework_wd = ifelse(F17_1_4 == 8, 6, housework_wd),
    housework_wd = ifelse(F17_1_4 == 9, 7, housework_wd),
    housework_wd = ifelse(F17_1_4 == 10, 8, housework_wd),
    housework_wd = ifelse(F17_1_4 == 11, 9, housework_wd),
    housework_wd = ifelse(F17_1_4 == 12, 10, housework_wd),
    housework_wd = ifelse(F17_1_4 == 13, 11, housework_wd),
    housework_wd = ifelse(F17_1_4 == 14, 12, housework_wd),
    housework_wd = ifelse(F17_1_4 == 15, 14, housework_wd)
  )
data <- data %>%
  mutate(
    sleeping_wd = 0,
    sleeping_wd = ifelse(F17_1_5 == 0, 0, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 1, 0.25, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 2, 0.5, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 3, 1, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 4, 2, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 5, 3, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 6, 4, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 7, 5, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 8, 6, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 9, 7, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 10, 8, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 11, 9, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 12, 10, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 13, 11, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 14, 12, sleeping_wd),
    sleeping_wd = ifelse(F17_1_5 == 15, 14, sleeping_wd)
  )

data <- data %>%
  mutate(
    working_hour_wd_id = 0,
    working_hour_wd_id = ifelse(F17_2_1 == 0, 0, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 1, 0.25, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 2, 0.5, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 3, 1, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 4, 2, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 5, 3, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 6, 4, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 7, 5, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 8, 6, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 9, 7, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 10, 8, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 11, 9, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 12, 10, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 13, 11, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 14, 12, working_hour_wd_id),
    working_hour_wd_id = ifelse(F17_2_1 == 15, 14, working_hour_wd_id)
  )
data <- data %>%
  mutate(
    comm_hour_conge_wd_id = 0,
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 0, 0, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 1, 0.25, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 2, 0.5, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 3, 1, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 4, 2, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 5, 3, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 6, 4, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 7, 5, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 8, 6, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 9, 7, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 10, 8, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 11, 9, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 12, 10, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 13, 11, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 14, 12, comm_hour_conge_wd_id),
    comm_hour_conge_wd_id = ifelse(F17_2_2 == 15, 14, comm_hour_conge_wd_id)
  )

data <- data %>%
  mutate(
    housework_wd_id = 0,
    housework_wd_id = ifelse(F17_2_3 == 0, 0, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 1, 0.25, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 2, 0.5, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 3, 1, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 4, 2, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 5, 3, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 6, 4, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 7, 5, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 8, 6, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 9, 7, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 10, 8, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 11, 9, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 12, 10, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 13, 11, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 14, 12, housework_wd_id),
    housework_wd_id = ifelse(F17_2_3 == 15, 14, housework_wd_id)
  )
data <- data %>%
  mutate(
    sleeping_wd_id = 0,
    sleeping_wd_id = ifelse(F17_2_4 == 0, 0, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 1, 0.25, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 2, 0.5, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 3, 1, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 4, 2, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 5, 3, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 6, 4, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 7, 5, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 8, 6, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 9, 7, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 10, 8, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 11, 9, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 12, 10, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 13, 11, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 14, 12, sleeping_wd_id),
    sleeping_wd_id = ifelse(F17_2_4 == 15, 14, sleeping_wd_id)
  )
data <- data %>%
  mutate(
    housework_wknd = 0,
    housework_wknd = ifelse(F17_3_1 == 0, 0, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 1, 0.25, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 2, 0.5, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 3, 1, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 4, 2, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 5, 3, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 6, 4, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 7, 5, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 8, 6, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 9, 7, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 10, 8, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 11, 9, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 12, 10, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 13, 11, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 14, 12, housework_wknd),
    housework_wknd = ifelse(F17_3_1 == 15, 14, housework_wknd)
  )
data <- data %>%
  mutate(
    sleeping_wknd = 0,
    sleeping_wknd = ifelse(F17_3_2 == 0, 0, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 1, 0.25, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 2, 0.5, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 3, 1, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 4, 2, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 5, 3, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 6, 4, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 7, 5, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 8, 6, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 9, 7, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 10, 8, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 11, 9, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 12, 10, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 13, 11, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 14, 12, sleeping_wknd),
    sleeping_wknd = ifelse(F17_3_2 == 15, 14, sleeping_wknd)
  )
data <- data %>%
  mutate(
    housework_wknd_id = 0,
    housework_wknd_id = ifelse(F17_4_1 == 0, 0, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 1, 0.25, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 2, 0.5, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 3, 1, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 4, 2, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 5, 3, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 6, 4, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 7, 5, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 8, 6, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 9, 7, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 10, 8, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 11, 9, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 12, 10, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 13, 11, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 14, 12, housework_wknd_id),
    housework_wknd_id = ifelse(F17_4_1 == 15, 14, housework_wknd_id)
  )
data <- data %>%
  mutate(
    sleeping_wknd_id = 0,
    sleeping_wknd_id = ifelse(F17_4_2 == 0, 0, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 1, 0.25, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 2, 0.5, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 3, 1, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 4, 2, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 5, 3, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 6, 4, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 7, 5, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 8, 6, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 9, 7, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 10, 8, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 11, 9, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 12, 10, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 13, 11, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 14, 12, sleeping_wknd_id),
    sleeping_wknd_id = ifelse(F17_4_2 == 15, 14, sleeping_wknd_id)
  )
#---------daily schedual----------------


data <- data %>%
  mutate(income_currency = NA) %>%
  dplyr::select(ID, country, income_currency, everything())
data$income_currency <- data$income_currency %>% as.numeric() 
#------------------------------------------household income in their currency------------------
data <- data %>%
  mutate(
    income_currency = ifelse(country == 1 & F6_JP_Web == 1, 250000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 2, 750000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 3, 1250000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 4, 1750000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 5, 2500000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 6, 4000000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 7, 6000000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 8, 8500000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 9, 12500000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 10, 17500000, income_currency),
    income_currency = ifelse(country == 1 & F6_JP_Web == 11, 20000000, income_currency), # Annual Japan
    income_currency = ifelse(country == 2 & F6_TH_Web == 1, 1000 * 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 2, 3500 * 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 3, 7500 * 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 4, 15000 * 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 5, 25000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 6, 35000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 7, 45000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 8, 55000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 9, 65000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 10, 75000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 11, 85000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 12, 95000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 13, 115000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 14, 140000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 15, 160000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 16, 185000* 12, income_currency),
    income_currency = ifelse(country == 2 & F6_TH_Web == 17, 200000* 12, income_currency), # Monthly Thailand
    income_currency = ifelse(country == 3 & F6_MY_Web == 1,500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 2,1500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 3,2500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 4,3500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 5,4500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 6,5500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 7,6500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 8,7500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 9,8500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 10,9500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 11,11000* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 12,13000* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 13,14500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 14,15500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 15,16500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 16,17500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 17,18500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 18,19500* 12, income_currency),
    income_currency = ifelse(country == 3 & F6_MY_Web == 19,20000* 12, income_currency), # Monthly Malaysia
    income_currency = ifelse(country == 4 & F6_ID_Web == 1,350000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 2,850000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 3,1125000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 4,1375000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 5,1625000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 6,1875000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 7,2125000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 8,2375000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 9,3000000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 10,4000000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 11,5000000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 12,5750000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 13,6600000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 14,7450000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 15,7950000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 16,9100000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 17,11250000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 18,13250000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 19,15250000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 20,17250000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 21,19250000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 22,21250000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 23,28500000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 24,41000000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 25,55000000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 26,65000000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 27,88500000* 12, income_currency),
    income_currency = ifelse(country == 4 & F6_ID_Web == 28,107000000* 12, income_currency), 
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 1,350000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 2,850000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 3,1125000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 4,1375000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 5,1625000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 6,1875000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 7,2125000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 8,2375000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 9,3000000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 10,4000000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 11,5000000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 12,5750000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 13,6600000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 14,7450000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 15,7950000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 16,9100000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 17,11250000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 18,13250000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 19,15250000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 20,17250000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 21,19250000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 22,21250000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 23,28500000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 24,41000000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 25,55000000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 26,65000000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 27,88500000* 12, income_currency),
    income_currency = ifelse(country_code == 16 & F6_ID_F2F == 28,107000000* 12, income_currency),# Month Indonesia
    income_currency = ifelse(country == 5 & F6_SG_Web == 1,500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 2,1500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 3,2500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 4,3500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 5,4500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 6,5500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 7,6500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 8,7500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 9,8500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 10,9500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 11,11500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 12,14000* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 13,16000* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 14,18500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 15,21500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 16,24000* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 17,26000* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 18,28500* 12, income_currency),
    income_currency = ifelse(country == 5 & F6_SG_Web == 19,30000* 12, income_currency), # Month Singapore
    income_currency = ifelse(country == 6 & F6_VN_Web == 1,500000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 2,1500000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 3,3000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 4,5000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 5,7000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 6,9000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 7,11000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 8,13000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 9,15000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 10,17000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 11,19000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 12,21000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 13,23000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 14,25000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 15,27000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 16,29000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 17,31000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 18,33000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 19,35000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 20,37000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 21,39000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 22,41000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 23,43000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 24,45000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 25,47000000* 12, income_currency),
    income_currency = ifelse(country == 6 & F6_VN_Web == 26,48000000* 12, income_currency), 
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 1,500000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 2,1500000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 3,3000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 4,5000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 5,7000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 6,9000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 7,11000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 8,13000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 9,15000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 10,17000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 11,19000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 12,21000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 13,23000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 14,25000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 15,27000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 16,29000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 17,31000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 18,33000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 19,35000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 20,37000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 21,39000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 22,41000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 23,43000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 24,45000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 25,47000000* 12, income_currency),
    income_currency = ifelse(country_code == 17 & F6_VN_F2F == 26,48000000* 12, income_currency),# Month Vietnam
    income_currency = ifelse(country == 7 & F6_PH_Web == 1,2500* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 2,7500* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 3,15000* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 4,35000* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 5,67500* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 6,87500* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 7,125000* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 8,175000* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 9,225000* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 10,275000* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 11,325000* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 12,375000* 12, income_currency),
    income_currency = ifelse(country == 7 & F6_PH_Web == 13,400000* 12, income_currency), # Month Philippines
    income_currency = ifelse(country == 8 & F6_MX_Web == 1,500* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 2,2000* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 3,4000* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 4,6000* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 5,8500* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 6,12500* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 7,17500* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 8,25000* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 9,35000* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 10,45000* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 11,55000* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 12,65000* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 13,75000* 12, income_currency),
    income_currency = ifelse(country == 8 & F6_MX_Web == 14,80000* 12, income_currency), # Month Mexico
    income_currency = ifelse(country == 9 & F6_VE_Web == 1,250* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 2,750* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 3,1500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 4,2500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 5,3500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 6,4500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 7,7500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 8,12500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 9,17500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 10,22500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 11,27500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 12,32500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 13,37500* 12, income_currency),
    income_currency = ifelse(country == 9 & F6_VE_Web == 14,40000* 12, income_currency), # Month Venezula
    income_currency = ifelse(country == 10 & F6_CL_Web == 1,25000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 2,75000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 3,150000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 4,250000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 5,350000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 6,450000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 7,625000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 8,875000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 9,1250000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 10,1750000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 11,2250000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 12,2750000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 13,3250000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 14,3750000* 12, income_currency),
    income_currency = ifelse(country == 10 & F6_CL_Web == 15,4000000* 12, income_currency), # Month Chile
    income_currency = ifelse(country == 11 & F6_BR_Web == 1,150* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 2,400* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 3,600* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 4,850* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 5,1500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 6,2500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 7,3500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 8,4500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 9,5500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 10,6500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 11,7500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 12,8500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 13,9500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 14,11500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 15,14000* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 16,16000* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 17,18500* 12, income_currency),
    income_currency = ifelse(country == 11 & F6_BR_Web == 18,20000* 12, income_currency), # Month Brazile
    income_currency = ifelse(country == 12 & F6_CO_Web == 1,50000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 2,200000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 3,400000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 4,600000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 5,850000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 6,2000000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 7,4000000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 8,6000000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 9,8500000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 10,11500000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 11,14000000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 12,16000000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 13,18500000* 12, income_currency),
    income_currency = ifelse(country == 12 & F6_CO_Web == 14,20000000* 12, income_currency), # Month Colombia
    income_currency = ifelse(country == 13 & F6_ZA_Web == 1,1000* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 2,3000* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 3,5000* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 4,7000* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 5,9000* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 6,12500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 7,17500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 8,22500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 9,27500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 10,32500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 11,37500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 12,42500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 13,47500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 14,62500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 15,87500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 16,112500* 12, income_currency),
    income_currency = ifelse(country == 13 & F6_ZA_Web == 17,125000* 12, income_currency), # Month South Africa
    income_currency = ifelse(country == 14 & F6_IN_Web == 1,250* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 2,750* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 3,1250* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 4,1750* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 5,2500* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 6,3500* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 7,4500* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 8,5500* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 9,7000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 10,9000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 11,11000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 12,13500* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 13,17500* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 14,25000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 15,35000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 16,50000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 17,70000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 18,90000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 19,150000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 20,250000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 21,350000* 12, income_currency),
    income_currency = ifelse(country == 14 & F6_IN_Web == 22,400000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 1,250* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 2,750* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 3,1250* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 4,1750* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 5,2500* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 6,3500* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 7,4500* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 8,5500* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 9,7000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 10,9000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 11,11000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 12,13500* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 13,17500* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 14,25000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 15,35000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 16,50000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 17,70000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 18,90000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 19,150000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 20,250000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 21,350000* 12, income_currency),
    income_currency = ifelse(country_code == 18 & F6_IN_Rural_F2F == 22,400000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 1,250* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 2,750* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 3,1250* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 4,1750* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 5,2500* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 6,3500* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 7,4500* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 8,5500* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 9,7000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 10,9000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 11,11000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 12,13500* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 13,17500* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 14,25000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 15,35000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 16,50000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 17,70000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 18,90000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 19,150000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 20,250000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 21,350000* 12, income_currency),
    income_currency = ifelse(country_code == 19 & F6_IN_Slum_F2F == 22,400000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 1,250* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 2,750* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 3,1250* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 4,1750* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 5,2500* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 6,3500* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 7,4500* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 8,5500* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 9,7000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 10,9000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 11,11000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 12,13500* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 13,17500* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 14,25000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 15,35000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 16,50000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 17,70000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 18,90000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 19,150000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 20,250000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 21,350000* 12, income_currency),
    income_currency = ifelse(country_code == 20 & F6_IN_Goa_F2F == 22,400000* 12, income_currency),# Month India
    income_currency = ifelse(country == 15 & F6_MM_F2F == 1,25000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 2,60000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 3,80000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 4,95000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 5,110000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 6,135000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 7,160000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 8,185000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 9,225000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 10,275000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 11,350000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 12,450000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 13,550000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 14,650000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 15,750000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 16,850000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 17,950000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 18,1100000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 19,1350000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 20,1600000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 21,1850000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 22,3500000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 23,7500000* 12, income_currency),
    income_currency = ifelse(country == 15 & F6_MM_F2F == 24,10000000* 12, income_currency), # Month Myanmar
    income_currency = ifelse(country == 16 & F6_KZ_F2F == 1,12500* 12, income_currency),
    income_currency = ifelse(country == 16 & F6_KZ_F2F == 2,37500* 12, income_currency),
    income_currency = ifelse(country == 16 & F6_KZ_F2F == 3,50000* 12, income_currency),
    income_currency = ifelse(country == 16 & F6_KZ_F2F == 4,80000* 12, income_currency),
    income_currency = ifelse(country == 16 & F6_KZ_F2F == 5,150000* 12, income_currency),
    income_currency = ifelse(country == 16 & F6_KZ_F2F == 6,250000* 12, income_currency),
    income_currency = ifelse(country == 16 & F6_KZ_F2F == 7,400000* 12, income_currency),
    income_currency = ifelse(country == 16 & F6_KZ_F2F == 8,500000* 12, income_currency), # Month Kazakhstan
    income_currency = ifelse(country == 17 & F6_MN_F2F == 1,150000* 12, income_currency),
    income_currency = ifelse(country == 17 & F6_MN_F2F == 2,400000* 12, income_currency),
    income_currency = ifelse(country == 17 & F6_MN_F2F == 3,600000* 12, income_currency),
    income_currency = ifelse(country == 17 & F6_MN_F2F == 4,800000* 12, income_currency),
    income_currency = ifelse(country == 17 & F6_MN_F2F == 5,1050000* 12, income_currency),
    income_currency = ifelse(country == 17 & F6_MN_F2F == 6,1350000* 12, income_currency),
    income_currency = ifelse(country == 17 & F6_MN_F2F == 7,1650000* 12, income_currency),
    income_currency = ifelse(country == 17 & F6_MN_F2F == 8,1950000* 12, income_currency),
    income_currency = ifelse(country == 17 & F6_MN_F2F == 9,2300000* 12, income_currency),
    income_currency = ifelse(country == 17 & F6_MN_F2F == 10,2500000* 12, income_currency), # Month Mongolia
    income_currency = ifelse(country == 18 & F6_EG_F2F == 1,300* 12, income_currency),
    income_currency = ifelse(country == 18 & F6_EG_F2F == 2,900* 12, income_currency),
    income_currency = ifelse(country == 18 & F6_EG_F2F == 3,1600* 12, income_currency),
    income_currency = ifelse(country == 18 & F6_EG_F2F == 4,2500* 12, income_currency),
    income_currency = ifelse(country == 18 & F6_EG_F2F == 5,3750* 12, income_currency),
    income_currency = ifelse(country == 18 & F6_EG_F2F == 6,5250* 12, income_currency),
    income_currency = ifelse(country == 18 & F6_EG_F2F == 7,6750* 12, income_currency),
    income_currency = ifelse(country == 18 & F6_EG_F2F == 8,8250* 12, income_currency),
    income_currency = ifelse(country == 18 & F6_EG_F2F == 9,12000* 12, income_currency),
    income_currency = ifelse(country == 18 & F6_EG_F2F == 10,15000* 12, income_currency), # Month Egypt
    income_currency = ifelse(country == 19 & F6_RU_Web == 1,5000* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 2,15000* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 3,30000* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 4,50000* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 5,70000* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 6,90000* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 7,112500* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 8,137500* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 9,162500* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 10,187500* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 11,225000* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 12,275000* 12, income_currency),
    income_currency = ifelse(country == 19 & F6_RU_Web == 13,300000* 12, income_currency), # Month Russia
    income_currency = ifelse(country == 20 & F6_CN_Web == 1,3000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 2,9000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 3,15000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 4,21000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 5,27000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 6,33000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 7,39000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 8,45000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 9,51000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 10,57000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 11,66000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 12,78000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 13,90000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 14,102000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 15,114000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 16,132000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 17,162000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 18,200000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 19,230000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 20,290000, income_currency),
    income_currency = ifelse(country == 20 & F6_CN_Web == 21,340000, income_currency), # Annual China
    income_currency = ifelse(country == 21 & F6_AUS_Web == 1,5000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 2,20000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 3,20000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 4,35000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 5,45000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 6,55000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 7,65000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 8,75000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 9,85000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 10,95000, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 11,137500, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 12,162500, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 13,187500, income_currency),
    income_currency = ifelse(country == 21 & F6_AUS_Web == 14,200000, income_currency), # Annual Australia
    income_currency = ifelse(country == 22 & F6_US_Web == 1,2500, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 2,7500, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 3,7500, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 4,15000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 5,25000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 6,35000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 7,45000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 8,55000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 9,65000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 10,75000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 11,95000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 12,105000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 13,115000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 14,125000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 15,135000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 16,145000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 17,155000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 18,165000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 19,175000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 20,185000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 21,195000, income_currency),
    income_currency = ifelse(country == 22 & F6_US_Web == 22,200000, income_currency), # Annual US
    income_currency = ifelse(country == 23 & F6_DE_Web == 1,2500, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 2,7500, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 3,7500, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 4,15000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 5,25000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 6,35000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 7,45000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 8,55000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 9,65000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 10,75000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 11,95000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 12,105000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 13,115000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 14,125000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 15,135000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 16,145000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 17,155000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 18,165000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 19,175000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 20,185000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 21,195000, income_currency),
    income_currency = ifelse(country == 23 & F6_DE_Web == 22,200000, income_currency), # Annual Germany
    income_currency = ifelse(country == 24 & F6_UK_Web == 1,2000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 2,6000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 3,12000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 4,20000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 5,28000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 6,36000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 7,44000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 8,52000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 9,60000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 10,68000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 11,76000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 12,84000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 13,92000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 14,100000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 15,108000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 16,116000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 17,124000, income_currency),
    income_currency = ifelse(country == 24 & F6_UK_Web == 18,128000, income_currency), # Annual UK
    income_currency = ifelse(country == 25 & F6_FR_Web == 1,2500, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 2,7500, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 3,7500, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 4,15000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 5,25000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 6,35000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 7,45000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 8,55000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 9,65000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 10,75000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 11,95000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 12,105000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 13,115000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 14,125000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 15,135000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 16,145000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 17,155000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 18,165000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 19,175000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 20,185000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 21,195000, income_currency),
    income_currency = ifelse(country == 25 & F6_FR_Web == 22,200000, income_currency), # Annual France
    income_currency = ifelse(country == 26 & F6_ES_Web == 1,2500, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 2,7500, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 3,7500, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 4,15000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 5,25000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 6,35000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 7,45000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 8,55000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 9,65000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 10,75000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 11,95000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 12,105000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 13,115000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 14,125000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 15,135000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 16,145000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 17,155000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 18,165000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 19,175000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 20,185000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 21,195000, income_currency),
    income_currency = ifelse(country == 26 & F6_ES_Web == 22,200000, income_currency), # Annual Spain
    income_currency = ifelse(country == 27 & F6_IT_Web == 1,2500, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 2,7500, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 3,7500, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 4,15000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 5,25000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 6,35000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 7,45000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 8,55000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 9,65000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 10,75000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 11,95000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 12,105000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 13,115000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 14,125000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 15,135000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 16,145000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 17,155000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 18,165000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 19,175000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 20,185000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 21,195000, income_currency),
    income_currency = ifelse(country == 27 & F6_IT_Web == 22,200000, income_currency), # Annual Italy
    income_currency = ifelse(country == 28 & F6_SE_Web == 1,20000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 2,60000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 3,120000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 4,200000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 5,280000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 6,360000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 7,440000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 8,520000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 9,600000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 10,680000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 11,760000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 12,840000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 13,920000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 14,1000000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 15,1080000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 16,1160000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 17,1240000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 18,1320000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 19,1400000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 20,1480000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 21,1560000, income_currency),
    income_currency = ifelse(country == 28 & F6_SE_Web == 22,1600000, income_currency), # Annual Sweden
    income_currency = ifelse(country == 29 & F6_CA_Web == 1,2500, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 2,7500, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 3,15000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 4,25000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 5,35000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 6,45000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 7,55000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 8,65000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 9,75000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 10,85000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 11,95000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 12,105000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 13,115000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 14,125000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 15,135000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 16,145000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 17,155000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 18,165000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 19,175000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 20,185000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 21,195000, income_currency),
    income_currency = ifelse(country == 29 & F6_CA_Web == 22,200000, income_currency), # Annual Canada
    income_currency = ifelse(country == 30 & F6_NL_Web == 1,2500, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 2,7500, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 3,7500, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 4,15000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 5,25000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 6,35000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 7,45000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 8,55000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 9,65000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 10,75000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 11,95000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 12,105000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 13,115000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 14,125000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 15,135000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 16,145000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 17,155000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 18,165000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 19,175000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 20,185000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 21,195000, income_currency),
    income_currency = ifelse(country == 30 & F6_NL_Web == 22,200000, income_currency), # Annual Netherlands
    income_currency = ifelse(country == 31 & F6_GR_Web == 1,2500, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 2,7500, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 3,7500, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 4,15000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 5,25000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 6,35000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 7,45000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 8,55000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 9,65000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 10,75000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 11,95000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 12,105000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 13,115000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 14,125000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 15,135000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 16,145000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 17,155000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 18,165000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 19,175000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 20,185000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 21,195000, income_currency),
    income_currency = ifelse(country == 31 & F6_GR_Web == 22,200000, income_currency), # Annual Greece
    income_currency = ifelse(country == 32 & F6_TR_Web == 1,5000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 2,15000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 3,30000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 4,50000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 5,70000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 6,90000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 7,110000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 8,140000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 9,180000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 10,220000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 11,260000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 12,300000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 13,340000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 14,380000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 15,420000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 16,460000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 17,500000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 18,540000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 19,580000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 20,620000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 21,660000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 22,700000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 23,740000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 24,780000, income_currency),
    income_currency = ifelse(country == 32 & F6_TR_Web == 25,800000, income_currency), # Annual Turkey
    income_currency = ifelse(country == 33 & F6_HU_Web == 1,375000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 2,1125000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 3,2250000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 4,3750000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 5,5250000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 6,6750000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 7,8250000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 8,10500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 9,13500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 10,16500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 11,19500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 12,22500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 13,25500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 14,28500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 15,31500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 16,34500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 17,37500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 18,40500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 19,43500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 20,46500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 21,49500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 22,52500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 23,55500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 24,58500000, income_currency),
    income_currency = ifelse(country == 33 & F6_HU_Web == 25,60000000, income_currency), # Annual Hungary
    income_currency = ifelse(country == 34 & F6_PL_Web == 1,5000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 2,15000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 3,30000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 4,50000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 5,70000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 6,90000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 7,110000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 8,140000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 9,180000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 10,220000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 11,260000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 12,300000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 13,340000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 14,380000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 15,420000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 16,460000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 17,500000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 18,540000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 19,580000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 20,620000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 21,660000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 22,700000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 23,740000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 24,780000, income_currency),
    income_currency = ifelse(country == 34 & F6_PL_Web == 25,800000, income_currency), # Annual Poland
    income_currency = ifelse(country == 35 & F6_CZ_Web == 1,31250, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 2,93750, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 3,187500, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 4,312500, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 5,437500, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 6,562500, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 7,687500, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 8,825000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 9,1125000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 10,1375000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 11,1625000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 12,1875000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 13,2125000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 14,2375000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 15,2625000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 16,2875000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 17,3125000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 18,3375000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 19,3625000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 20,3875000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 21,4125000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 22,4375000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 23,4625000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 24,4875000, income_currency),
    income_currency = ifelse(country == 35 & F6_CZ_Web == 25,5000000, income_currency), # Annual Czech
    income_currency = ifelse(country == 36 & F6_RO_Web == 1,5000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 2,15000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 3,30000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 4,50000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 5,70000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 6,90000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 7,110000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 8,140000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 9,180000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 10,220000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 11,260000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 12,300000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 13,340000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 14,380000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 15,420000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 16,460000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 17,500000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 18,540000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 19,580000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 20,620000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 21,660000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 22,700000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 23,740000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 24,780000, income_currency),
    income_currency = ifelse(country == 36 & F6_RO_Web == 25,800000, income_currency), # Annual Romania
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 1,3750* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 2,13750* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 3,12500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 4,17500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 5,22500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 6,27500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 7,32500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 8,37500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 9,42500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 10,47500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 11,52500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 12,57500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 13,62500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 14,67500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 15,72500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 16,77500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 17,82500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 18,87500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 19,92500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 20,97500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_r == 21,100000* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 1,3750* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 2,13750* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 3,12500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 4,17500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 5,22500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 6,27500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 7,32500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 8,37500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 9,42500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 10,47500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 11,52500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 12,57500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 13,62500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 14,67500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 15,72500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 16,77500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 17,82500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 18,87500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 19,92500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 20,97500* 12, income_currency),
    income_currency = ifelse(country == 37 & F6_LK_F2F_i == 21,100000* 12, income_currency)# Month Sri Lanka
  ) # household income in their currency
data <- data %>%
  dplyr::select(-(F6_JP_Web:F8_LK_F2F))
#------------------------------------------household income in their currency------------------
data <- data %>%
  mutate(ho_income_usd = NA) %>%
  dplyr::select(ID, country, ho_income_usd, everything())
data$ho_income_usd <- data$ho_income_usd %>% as.numeric()
#------------------------------------------household income in usd------------------
data <- data %>%
  mutate(ho_income_usd = ifelse(country == 1, income_currency/121.044, ho_income_usd),
         ho_income_usd = ifelse(country == 2, income_currency/34.248, ho_income_usd),
         ho_income_usd = ifelse(country == 3, income_currency/3.906, ho_income_usd),
         ho_income_usd = ifelse(country == 4, income_currency/13389.413, ho_income_usd),
         ho_income_usd = ifelse(country == 5, income_currency/1.375, ho_income_usd),
         ho_income_usd = ifelse(country == 6, income_currency/21697.568, ho_income_usd),
         ho_income_usd = ifelse(country == 7, income_currency/45.503, ho_income_usd),
         ho_income_usd = ifelse(country == 8, income_currency/15.848, ho_income_usd),
         ho_income_usd = ifelse(country == 9, income_currency/6.284, ho_income_usd),
         ho_income_usd = ifelse(country == 10, income_currency/654.124, ho_income_usd),
         ho_income_usd = ifelse(country == 11, income_currency/3.327, ho_income_usd),
         ho_income_usd = ifelse(country == 12, income_currency/2741.881, ho_income_usd),
         ho_income_usd = ifelse(country == 13, income_currency/12.759, ho_income_usd),
         ho_income_usd = ifelse(country == 14, income_currency/64.152, ho_income_usd),
         ho_income_usd = ifelse(country == 15, income_currency/1162.615, ho_income_usd),
         ho_income_usd = ifelse(country == 16, income_currency/221.728, ho_income_usd),
         ho_income_usd = ifelse(country == 17, income_currency/1970.309, ho_income_usd),
         ho_income_usd = ifelse(country == 18, income_currency/7.691, ho_income_usd),
         ho_income_usd = ifelse(country == 19, income_currency/60.938, ho_income_usd),
         ho_income_usd = ifelse(country == 20, income_currency/6.227, ho_income_usd),
         ho_income_usd = ifelse(country == 21, income_currency/1.331, ho_income_usd),
         ho_income_usd = ifelse(country == 22, income_currency/1, ho_income_usd),
         ho_income_usd = ifelse(country == 23, income_currency/0.901, ho_income_usd),
         ho_income_usd = ifelse(country == 24, income_currency/0.655, ho_income_usd),
         ho_income_usd = ifelse(country == 25, income_currency/0.901, ho_income_usd),
         ho_income_usd = ifelse(country == 26, income_currency/0.901, ho_income_usd),
         ho_income_usd = ifelse(country == 27, income_currency/0.901, ho_income_usd),
         ho_income_usd = ifelse(country == 28, income_currency/8.435, ho_income_usd),
         ho_income_usd = ifelse(country == 29, income_currency/1.279, ho_income_usd),
         ho_income_usd = ifelse(country == 30, income_currency/0.901, ho_income_usd),
         ho_income_usd = ifelse(country == 31, income_currency/0.901, ho_income_usd),
         ho_income_usd = ifelse(country == 32, income_currency/2.72, ho_income_usd),
         ho_income_usd = ifelse(country == 33, income_currency/279.333, ho_income_usd),
         ho_income_usd = ifelse(country == 34, income_currency/3.77, ho_income_usd),
         ho_income_usd = ifelse(country == 35, income_currency/24.599, ho_income_usd),
         ho_income_usd = ifelse(country == 36, income_currency/4.006, ho_income_usd),
         ho_income_usd = ifelse(country == 37, income_currency/135.857, ho_income_usd)
  ) #  exchange rate 2015 
#------------------------------------------household income in usd------------------
#------------------------------------------individual income in usd------------------
data <- data %>%
  mutate(ind_income_usd = ho_income_usd/family_mem) %>%
  dplyr::select(ID, country, ind_income_usd, everything())
#------------------------------------------individual income in usd------------------
#--------------------difference between individual income and GDP in usd ------------------
data <- data %>%
  mutate(
    di_inc_gdp = NA,
    di_inc_gdp = ifelse(country == 1, (ind_income_usd - 34296.76182)/34296.76182, di_inc_gdp),
    di_inc_gdp = ifelse(country == 2, (ind_income_usd - 5840.04368088199)/5840.04368088199, di_inc_gdp),
    di_inc_gdp = ifelse(country == 3, (ind_income_usd - 9955.24303866936)/9955.24303866936, di_inc_gdp),
    di_inc_gdp = ifelse(country == 4, (ind_income_usd - 3331.695118502)/3331.695118502, di_inc_gdp),
    di_inc_gdp = ifelse(country == 5, (ind_income_usd - 55076.9266052493)/55076.9266052493, di_inc_gdp),
    di_inc_gdp = ifelse(country == 6, (ind_income_usd - 2085.10163774086)/2085.10163774086, di_inc_gdp),
    di_inc_gdp = ifelse(country == 7, (ind_income_usd - 2867.14947345595)/2867.14947345595, di_inc_gdp),
    di_inc_gdp = ifelse(country == 8, (ind_income_usd - 9605.97255503339)/9605.97255503339, di_inc_gdp),
    di_inc_gdp = ifelse(country == 9, (ind_income_usd - 11439.1968408022)/11439.1968408022, di_inc_gdp),
    di_inc_gdp = ifelse(country == 10, (ind_income_usd - 13574.1718307245)/13574.1718307245, di_inc_gdp),
    di_inc_gdp = ifelse(country == 11, (ind_income_usd - 8813.98937549952)/8813.98937549952, di_inc_gdp),
    di_inc_gdp = ifelse(country == 12, (ind_income_usd - 6175.87613151291)/6175.87613151291, di_inc_gdp),
    di_inc_gdp = ifelse(country == 13, (ind_income_usd - 5730.93445218042)/5730.93445218042, di_inc_gdp),
    di_inc_gdp = ifelse(country == 14, (ind_income_usd - 1638.55640239958)/1638.55640239958, di_inc_gdp),
    di_inc_gdp = ifelse(country == 15, (ind_income_usd - 1211.73669552402)/1211.73669552402, di_inc_gdp),
    di_inc_gdp = ifelse(country == 16, (ind_income_usd - 10493.2982321916)/10493.2982321916, di_inc_gdp),
    di_inc_gdp = ifelse(country == 17, (ind_income_usd - 3918.58167706494)/3918.58167706494, di_inc_gdp),
    di_inc_gdp = ifelse(country == 18, (ind_income_usd - 3437.21122973619)/3437.21122973619, di_inc_gdp),
    di_inc_gdp = ifelse(country == 19, (ind_income_usd - 9424.48853257256)/9424.48853257256, di_inc_gdp),
    di_inc_gdp = ifelse(country == 20, (ind_income_usd - 7862.66457482127)/7862.66457482127, di_inc_gdp),
    di_inc_gdp = ifelse(country == 21, (ind_income_usd - 52131.3818041621)/52131.3818041621, di_inc_gdp),
    di_inc_gdp = ifelse(country == 22, (ind_income_usd - 56838.6844221412)/56838.6844221412, di_inc_gdp),
    di_inc_gdp = ifelse(country == 23, (ind_income_usd - 41036.0917784737)/41036.0917784737, di_inc_gdp),
    di_inc_gdp = ifelse(country == 24, (ind_income_usd - 44530.4927178004)/44530.4927178004, di_inc_gdp),
    di_inc_gdp = ifelse(country == 25, (ind_income_usd - 36611.7539123875)/36611.7539123875, di_inc_gdp),
    di_inc_gdp = ifelse(country == 26, (ind_income_usd - 25606.8127544494)/25606.8127544494, di_inc_gdp),
    di_inc_gdp = ifelse(country == 27, (ind_income_usd - 30306.1221251231)/30306.1221251231, di_inc_gdp),
    di_inc_gdp = ifelse(country == 28, (ind_income_usd - 51726.2025253337)/51726.2025253337, di_inc_gdp),
    di_inc_gdp = ifelse(country == 29, (ind_income_usd - 43193.7918063055)/43193.7918063055, di_inc_gdp),
    di_inc_gdp = ifelse(country == 30, (ind_income_usd - 45179.0297228225)/45179.0297228225, di_inc_gdp),
    di_inc_gdp = ifelse(country == 31, (ind_income_usd - 18322.9447129746)/18322.9447129746, di_inc_gdp),
    di_inc_gdp = ifelse(country == 32, (ind_income_usd - 11006.2455757441)/11006.2455757441, di_inc_gdp),
    di_inc_gdp = ifelse(country == 33, (ind_income_usd - 12791.4983602489)/12791.4983602489, di_inc_gdp),
    di_inc_gdp = ifelse(country == 34, (ind_income_usd - 12562.731212555)/12562.731212555, di_inc_gdp),
    di_inc_gdp = ifelse(country == 35, (ind_income_usd - 17736.6294706142)/17736.6294706142, di_inc_gdp),
    di_inc_gdp = ifelse(country == 36, (ind_income_usd - 8928.14904659118)/8928.14904659118, di_inc_gdp),
    di_inc_gdp = ifelse(country == 37, (ind_income_usd - 3855.1737357991)/3855.1737357991, di_inc_gdp)
  ) %>%
  dplyr::select(di_inc_gdp, everything())
#--------------------difference between individual income and GDP in usd ------------------

#--------------------country--------------------------
data <- data %>%
  mutate(
    japan = ifelse(country == 1, 1, 0),
    thailand = ifelse(country == 2, 1, 0),
    malaysia = ifelse(country == 3, 1, 0),
    indonesia = ifelse(country == 4, 1, 0),
    singapore = ifelse(country == 5, 1, 0),
    vietnam = ifelse(country == 6, 1, 0),
    philippines = ifelse(country == 7, 1, 0),
    mexico = ifelse(country == 8, 1, 0),
    venezuela = ifelse(country == 9, 1, 0),
    chile = ifelse(country == 10, 1, 0),
    brazile = ifelse(country == 11, 1, 0),
    colombia = ifelse(country == 12, 1, 0),
    southafrica = ifelse(country == 13, 1, 0),
    indonesia = ifelse(country == 14, 1, 0),
    india = ifelse(country == 15, 1, 0),
    myanmar = ifelse(country == 16, 1, 0),
    mongolia = ifelse(country == 17, 1, 0),
    egypt = ifelse(country == 18, 1, 0),
    russia = ifelse(country == 19, 1, 0),
    china = ifelse(country == 20, 1, 0),
    australia = ifelse(country == 21, 1, 0),
    US = ifelse(country == 22, 1, 0),
    germany = ifelse(country == 23, 1, 0),
    UK = ifelse(country == 24, 1, 0),
    france = ifelse(country == 25, 1, 0),
    spain = ifelse(country == 26, 1, 0),
    italy = ifelse(country == 27, 1, 0),
    sweden = ifelse(country == 28, 1, 0),
    canada = ifelse(country == 29, 1, 0),
    netherlands = ifelse(country == 30, 1, 0),
    greece = ifelse(country == 31, 1, 0),
    turkey = ifelse(country == 32, 1, 0),
    hungary = ifelse(country == 33, 1, 0),
    poland = ifelse(country == 34, 1, 0),
    czech = ifelse(country == 35, 1, 0),
    romania = ifelse(country == 36, 1, 0),
    sri_lanka = ifelse(country == 37, 1, 0)
  )
col <- c("japan"     ,              
         "thailand" ,                "malaysia"     ,            "indonesia"  ,              "singapore"  ,             
         "vietnam"   ,               "philippines"   ,           "mexico"      ,             "venezuela"   ,            
         "chile"      ,              "brazile"        ,          "colombia"     ,            "southafrica"  ,           
         "india"       ,             "myanmar"         ,         "mongolia"      ,           "egypt"         ,          
         "russia"       ,            "china"            ,        "australia"      ,          "US"             ,         
         "germany"       ,           "UK"                ,       "france"          ,         "spain"           ,        
         "italy"          ,          "sweden"             ,      "canada"           ,        "netherlands"      ,       
         "greece"          ,         "turkey"              ,     "hungary"           ,       "poland"            ,      
         "czech"            ,        "romania"              ,    "sri_lanka"               )
data[,col] <- lapply(data[,col], factor)
#--------------------country--------------------------

data$country <- data$country %>% as.factor()
run <- F
if(run){
  data$over_LS <- data$over_LS %>% as.factor()
  data$comm_LS <- data$comm_LS %>% as.factor()
  data$world_LS <- data$world_LS %>% as.factor()
  data$over_HA <- data$over_HA %>% as.factor()
  data$comm_HA <- data$comm_HA %>% as.factor()
  data$world_HA <- data$world_HA %>% as.factor()
  data$cantril <- data$cantril %>% as.factor()
  data$LS_10p <- data$LS_10p %>% as.factor()
  data$trust <- data$trust %>% as.factor()
  data$trusted <- data$trusted %>% as.factor()
  data$social_class <- data$social_class %>% as.factor()
  data$income_group <- data$income_group %>% as.factor()
  data$female_dummy <- data$female_dummy %>% as.factor()
  data$ms_single_dummy <- data$ms_single_dummy %>% as.factor()
  data$ms_married_dummy <- data$ms_married_dummy %>% as.factor()
  data$ms_divorced_dummy <- data$ms_divorced_dummy %>% as.factor()
  data$student <- data$student %>% as.factor()
  data$worker <- data$worker %>% as.factor()
  data$company_owner <- data$company_owner %>% as.factor()
  data$government_officer <- data$government_officer %>% as.factor()
  data$self_employed <- data$self_employed %>% as.factor()
  data$professional <- data$professional %>% as.factor()
  data$housewife <- data$housewife %>% as.factor()
  data$unemployed <- data$unemployed %>% as.factor()
  data$college_no_diploma <- data$college_no_diploma %>% as.factor()
  data$bachelor <- data$bachelor %>% as.factor()
  data$master <- data$master %>% as.factor()
  data$phd <- data$phd %>% as.factor()
  data$pleasure_all <- data$pleasure_all %>% as.factor()
  data$anger_all <- data$anger_all %>% as.factor()
  data$sadness_all <- data$sadness_all %>% as.factor()
  data$enjoyment_all <- data$enjoyment_all %>% as.factor()
  data$smile_all <- data$smile_all %>% as.factor()
  data$pleasure_wk <- data$pleasure_wk %>% as.factor()
  data$anger_wk <- data$anger_wk %>% as.factor()
  data$sadness_wk <- data$sadness_wk %>% as.factor()
  data$enjoyment_wk <- data$enjoyment_wk %>% as.factor()
  data$smile_wk <- data$smile_wk %>% as.factor()
  data$com_livable <- data$com_livable %>% as.factor()
  data$com_attach <- data$com_attach %>% as.factor()
  data$com_satety <- data$com_satety %>% as.factor()
  data$partner_dummy <- data$partner_dummy %>% as.factor()
  data$job <- data$job %>% as.factor()
  data$education_background <- data$education_background %>% as.factor()
  data$eco_ineq_local <- data$eco_ineq_local %>% as.factor()
  data$eco_ineq_nation <- data$eco_ineq_nation %>% as.factor()
  data$eco_ineq_world <- data$eco_ineq_world %>% as.factor()
  data$soc_ineq_local <- data$soc_ineq_local %>% as.factor()
  data$soc_ineq_nation <- data$soc_ineq_nation %>% as.factor()
  data$soc_ineq_world <- data$soc_ineq_world %>% as.factor()
  data$GHQ12_1 <- data$GHQ12_1 %>% as.factor()
  data$GHQ12_2 <- data$GHQ12_2 %>% as.factor()
  data$GHQ12_3 <- data$GHQ12_3 %>% as.factor()
  data$GHQ12_4 <- data$GHQ12_4 %>% as.factor()
  data$GHQ12_5 <- data$GHQ12_5 %>% as.factor()
  data$GHQ12_6 <- data$GHQ12_6 %>% as.factor()
  data$GHQ12_7 <- data$GHQ12_7 %>% as.factor()
  data$GHQ12_8 <- data$GHQ12_8 %>% as.factor()
  data$GHQ12_9 <- data$GHQ12_9 %>% as.factor()
  data$GHQ12_10 <- data$GHQ12_10 %>% as.factor()
  data$GHQ12_11 <- data$GHQ12_11 %>% as.factor()
  data$GHQ12_12 <- data$GHQ12_12 %>% as.factor()
}

data <- data %>%
  mutate(bi_LS = ifelse(over_LS == 4 | over_LS == 5, 1, 0)) %>%
  dplyr::select(bi_LS, everything())
data$bi_LS <- data$bi_LS %>% as.factor()
################# wash the data ########################

################# Merge spatial Data ###################
spatial_data <- read.dbf("01_RawData\\ClimateSpatialSID.dbf") %>%
  rename(ID = StandardID,
         AP_mort = mortality) %>%
  dplyr::select(-urban)
col = c("urban_cent", "urban_area",
        "rural_area")
spatial_data[,col] <- lapply(spatial_data[,col], factor)
data <- left_join(data, spatial_data)
################# Merge spatial Data ###################

################# Land Cover Data ###################
land_cover_data <- read.csv("01_RawData\\2017LandCover.csv") %>%
  rename(ID = StandardID)
data <- left_join(data, land_cover_data)
################# Land Cover Data ###################

setwd("C:\\Users\\li.chao.987@s.kyushu-u.ac.jp\\OneDrive - Kyushu University\\02_Article\\03_RStudio\\")
save(data, file = "01_PrivateData\\01_Dataset.RData")
