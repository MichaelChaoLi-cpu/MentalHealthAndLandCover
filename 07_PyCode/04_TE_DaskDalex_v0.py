# -*- coding: utf-8 -*-
"""
Created on Tue Oct 18 15:53:19 2022

@author: li.chao.987@s.kyushu-u.ac.jp
"""

import os
import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib

import pyreadr

from sklearn.model_selection import train_test_split

#import dask_mpi as dm
from dask.distributed import Client, progress

from datetime import datetime

from joblib import Parallel, delayed


dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")

dataset = dataset[None]

y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')
X = np.array(dataset.iloc[:, 1:50], dtype='float64')

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 14)
with joblib.parallel_backend("dask"): model.fit(X, y)

# SHAP
import dalex as dx

model_rf_exp = dx.Explainer(model, X, y, label = "RF Pipeline")

def singleSHAPprocess(obs_num):
    test_obs = X[obs_num:obs_num+1,:]
    shap_test = model_rf_exp.predict_parts(test_obs, type = 'shap', 
                                           B = 5, N = 5000)
    result = shap_test.result[shap_test.result.B == 0]
    result = result[['contribution', 'variable_name']]
    result = result.transpose()
    result = result.rename(columns=result.iloc[1])
    result = result.drop(['variable_name'], axis=0)
    result = result.reset_index(drop=True)
    return result

start = datetime.now()
with joblib.parallel_backend('dask'):
    results_bag = joblib.Parallel(n_jobs=36, verbose=100)(
        joblib.delayed(singleSHAPprocess)(int(obs_num))
        for obs_num in np.linspace(0, 35, 36))


end = datetime.now()
print(f"B 5, N 5000: Time taken: {end - start}")   

client.close()