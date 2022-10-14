# -*- coding: utf-8 -*-
"""
#NOTE: this script only works on HPC

M.L.
"""

import pandas as pd
import numpy as np
from datetime import datetime

# Random Forest
from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib

import pyreadr

from sklearn.model_selection import train_test_split
from sklearn.experimental import enable_halving_search_cv
from sklearn.model_selection import HalvingGridSearchCV

DP02_location = "/home/usr6/q70176a/DP02/"
DP02_result_location = "/home/usr6/q70176a/DP02/08_PyResults/"

### local folder on PC:
# DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio"
# DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"

dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")

dataset = dataset[None]
print("data here\n")

y = dataset.iloc[:, 0:1]
X = dataset.iloc[:, 1:50]
weight = dataset[['weights']].values.flatten()

param_grid= {'max_features': [11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                              21, 22, 23, 24, 25, 26, 27, 28, 29 ,30]}
base_estimator = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1)
sh = HalvingGridSearchCV(base_estimator, param_grid, 
                         n_jobs=-1).fit(X, y, sample_weight = weight)
sh.best_estimator_

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, n_jobs=-1, max_features = 14)
model.fit(X, y, sample_weight = weight)

print(model.oob_score_)
dump(model, DP02_result_location + '01_model_1000tree_49var_reg_weights_14feature.joblib') 

# SHAP
import dalex as dx

model_14feature_rf_exp = dx.Explainer(model, X, y,  
                                      label = "RF Pipeline")

test_obs1 = X.iloc[1:2,:]

"""
start = datetime.now()
shap_test1 = model_14feature_rf_exp.predict_parts(test_obs1, type = 'shap')
end = datetime.now()
test_time1 = end - start

print(f"Perfect Time taken: {end - start}")

start = datetime.now()
shap_test1_N = model_14feature_rf_exp.predict_parts(test_obs1, type = 'shap', 
                                                    N = 10000)
end = datetime.now()
test_time2 = end - start

print(f"N 10000: Time taken: {end - start}")

start = datetime.now()
shap_test1_B = model_14feature_rf_exp.predict_parts(test_obs1, type = 'shap', 
                                                    B = 10)
end = datetime.now()
test_time3 = end - start

print(f"B 10: Time taken: {end - start}")

start = datetime.now()
shap_test1_NB = model_14feature_rf_exp.predict_parts(test_obs1, type = 'shap', 
                                                    B = 10, N = 10000)
end = datetime.now()
test_time4 = end - start

print(f"B 10, N 10000: Time taken: {end - start}")

start = datetime.now()
shap_test1_NB2 = model_14feature_rf_exp.predict_parts(test_obs1, type = 'shap', 
                                                    B = 10, N = 40000)
end = datetime.now()
test_time5 = end - start

print(f"B 10, N 40000: Time taken: {end - start}")

start = datetime.now()
shap_test1_NB3 = model_14feature_rf_exp.predict_parts(test_obs1, type = 'shap', 
                                                    B = 5, N = 5000)
end = datetime.now()
test_time6 = end - start

print(f"B 5, N 5000: Time taken: {end - start}")

shap_test1_N.result[shap_test1_N.result.B == 0]
shap_test1_B.result[shap_test1_B.result.B == 0]
shap_test1_NB2.result[shap_test1_NB2.result.B == 0]
shap_test1.result[shap_test1.result.B == 0]

# Because of time, 
"""