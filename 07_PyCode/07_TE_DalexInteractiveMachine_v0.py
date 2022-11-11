# -*- coding: utf-8 -*-
"""
Created on Tue Oct 18 15:53:19 2022

@author: li.chao.987@s.kyushu-u.ac.jp

This test is from 70000

"""

import os
import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib

import pyreadr
from sklearn.model_selection import train_test_split
from datetime import datetime
from joblib import Parallel, delayed
import warnings

DP02_location = "/home/usr6/q70176a/DP02/"
DP02_result_location = "/home/usr6/q70176a/DP02/08_PyResults/"

#DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
#DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"

warnings.filterwarnings(action='ignore', category=UserWarning)

dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")

dataset = dataset[None]

y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')
X = np.array(dataset.iloc[:, 1:50], dtype='float64')


#from sklearn.datasets import make_regression
#X, y = make_regression(n_samples = 100000, n_features = 50, random_state=1)

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 11, n_jobs=-1)
model.fit(X, y)

# SHAP
import dalex as dx

model_rf_exp = dx.Explainer(model, X, y, label = "RF Pipeline")

def singleSHAPprocess(obs_num):
    test_obs = X[obs_num:obs_num+1,:]
    shap_test = model_rf_exp.predict_parts(test_obs, type = 'shap', 
                                           B = 20, N = 1000)
    result = shap_test.result[shap_test.result.B == 0]
    result = result[['contribution', 'variable_name']]
    result = result.transpose()
    result = result.rename(columns=result.iloc[1])
    result = result.drop(['variable_name'], axis=0)
    result = result.reset_index(drop=True)
    return result
### B = 5, N = 1000 -> 2.2 min
### B = 20, N = 1000 -> testing 

start = datetime.now()
results_bag = joblib.Parallel(n_jobs=-1, verbose=10000, backend="multiprocessing")(
    joblib.delayed(singleSHAPprocess)(int(obs_num))
    for obs_num in np.linspace(70000, 70099, 100))
end = datetime.now()
print(f"B 5, N 5000: Time taken: {end - start}")

dump(results_bag, DP02_result_location + '00_05_TE_result_70000_72999.joblib')

"""
dump(model, DP02_result_location + '00_randomForest_model.joblib')

results_bag = joblib.Parallel(n_jobs=2, verbose=10000, backend="threading")(
    joblib.delayed(singleSHAPprocess)(int(obs_num))
    for obs_num in np.linspace(70000, 70009, 10))

results_bag = joblib.Parallel(n_jobs=-1, verbose=10000, backend="multiprocessing")(
    joblib.delayed(singleSHAPprocess)(int(obs_num))
    for obs_num in np.linspace(70000, 70071, 72))

start = datetime.now()
results_bag = joblib.Parallel(n_jobs=-1, verbose=10000, backend="multiprocessing")(
    joblib.delayed(singleSHAPprocess)(int(obs_num))
    for obs_num in np.linspace(73000, 79999, 7000))
end = datetime.now()
print(f"B 5, N 5000: Time taken: {end - start}")

dump(results_bag, DP02_result_location + '00_05_TE_result_73000_79999.joblib')

start = datetime.now()
results_bag = joblib.Parallel(n_jobs=-1, verbose=10000, backend="multiprocessing")(
    joblib.delayed(singleSHAPprocess)(int(obs_num))
    for obs_num in np.linspace(80000, 89272, 9273))
end = datetime.now()
print(f"B 5, N 5000: Time taken: {end - start}")

dump(results_bag, DP02_result_location + '00_05_TE_result_80000_89272.joblib')
"""

