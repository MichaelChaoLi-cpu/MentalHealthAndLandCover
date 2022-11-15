# -*- coding: utf-8 -*-
"""
Created on Tue Nov 15 10:06:51 2022

@author: li.chao.987@s.kyushu-u.ac.jp
"""

import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score
from sklearn.metrics import mean_absolute_error
from sklearn.metrics import mean_squared_error
from joblib import dump, load
import joblib

import pyreadr

DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"

### X and y
dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
dataset = dataset[None]
X = np.array(dataset.iloc[:, 1:50], dtype='float64')
y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 9, n_jobs=-1)
model.fit(X, y)

### accuracy index:
print(model.oob_score_)
y_pred = model.predict(X)
r2 = r2_score(y, y_pred)
print(r2)
mae = mean_absolute_error(y, y_pred)
print(mae)
mse = mean_squared_error(y, y_pred)
print(mse)
rmse = np.sqrt(mse)
print(rmse)
reg_count = LinearRegression().fit(pd.DataFrame(y), np.array(y_pred))
reg_count.coef_
reg_count.intercept_

output.table

y_pred_ols = LinearRegression().fit(pd.DataFrame(X), np.array(y)).predict(X)
r2_ols = r2_score(y, y_pred_ols)
print(r2_ols)
mae_ols = mean_absolute_error(y, y_pred_ols)
print(mae_ols)
mse_ols = mean_squared_error(y, y_pred_ols)
print(mse_ols)
rmse_ols = np.sqrt(mse_ols)
print(rmse_ols)

search = load(DP02_result_location + '01_hyperParaSearching.joblib')
print(search.cv_results_.keys())
mat = search.cv_results_
check_table = pd.DataFrame(np.array(
    [mat["rank_test_score"], mat['param_max_features'],
     mat['param_min_samples_split'], mat['mean_test_score'],
     mat['std_test_score']
     ]).T)

"""
DP02_location = "/home/usr6/q70176a/DP02/"
DP02_result_location = "/home/usr6/q70176a/DP02/08_PyResults/"

r2_array = []
for features_num in list(range(1, 50, 1)):
    model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                                   random_state=1, max_features = features_num, n_jobs=-1)
    model.fit(X, y)
    
    model.oob_score_
    y_pred = model.predict(X)
    r2 = r2_score(y, y_pred)
    print(r2)
    r2_array.append(r2)
pd.DataFrame(r2_array).to_csv(DP02_result_location + "r2_array.csv")
"""
