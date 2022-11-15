# -*- coding: utf-8 -*-
"""
Created on Tue Oct 18 15:53:19 2022

@author: li.chao.987@s.kyushu-u.ac.jp

#!/bin/bash
#PJM -L "rscunit=ito-a"
#PJM -L "rscgrp=ito-m"
#PJM -L "vnode=16"
#PJM -L "vnode-core=36"
#PJM -L "elapse=24:00:00"
#PJM -j
#PJM -X
module use /home/exp/modulefiles
module load gcc/10.2.0
mpirun  -np 48 -ppn 3  -machinefile ${PJM_O_NODEINF}  -launcher-exec /bin/pjrsh python /home/usr6/q70176a/DP02/07_PyCode/05_TE_DaskDalex_8nodes4thread_v0.py

B=10 N=900 obs=10000 -> 6 hrs
"""

import os
import pandas as pd
import numpy as np

import pyreadr

import dask_mpi as dm
from dask.distributed import Client, progress
import dask

from datetime import datetime
from joblib import Parallel, delayed
from sklearn.ensemble import RandomForestRegressor
from joblib import dump, load
import joblib

DP02_location = "/home/usr6/q70176a/DP02/"
DP02_result_location = "/home/usr6/q70176a/DP02/08_PyResults/"
#makeDirIfNotExist(DP02_result_location + "result")
pd.Series(['import done']).to_csv(DP02_result_location + '05_8node_TEST_report.csv')


dm.initialize(local_directory=os.getcwd(),  nthreads=1, memory_limit=0.3333)
client = Client()
pd.Series(['import done', client]).to_csv(DP02_result_location + '05_8node_TEST_report.csv')

dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
dataset = dataset[None]
y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')
X = np.array(dataset.iloc[:, 1:50], dtype='float64')
pd.Series(['import done', client, "load data"]).to_csv(DP02_result_location + '05_8node_TEST_report.csv')

#from sklearn.datasets import make_regression
#X, y = make_regression(n_samples = 100000, n_features = 50, random_state=1)

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 9, n_jobs=-1)
with joblib.parallel_backend("dask"): model.fit(X, y)
#model = load(DP02_result_location + '00_randomForest_model.joblib')

pd.Series(['import done', client, "load data", model.oob_score_]).to_csv(DP02_result_location + '05_8node_TEST_report.csv')

# SHAP
import dalex as dx
model_rf_exp = dx.Explainer(model, X, y, label = "RF Pipeline")
pd.Series(['import done', client, "load data", model.oob_score_, "dalex"]).to_csv(DP02_result_location + '05_8node_TEST_report.csv')

X_scattered = client.scatter(X)
model_rf_exp_scattered = client.scatter(model_rf_exp)
pd.Series(['import done', client, "load data", model.oob_score_, "scatter",
           "dalex"]).to_csv(DP02_result_location + '05_8node_TEST_report.csv')

def singleSHAPprocess(obs_num, X, model_rf_exp):
    test_obs = X[obs_num:obs_num+1,:]
    shap_test = model_rf_exp.predict_parts(test_obs, type = 'shap', 
                                           B = 10, N = 900)
    result = shap_test.result[shap_test.result.B == 0]
    result = result[['contribution', 'variable_name']]
    result = result.transpose()
    result = result.rename(columns=result.iloc[1])
    result = result.drop(['variable_name'], axis=0)
    result = result.reset_index(drop=True)
    return result
### B = 10, N = 900
### B = 20, N = 900

start = datetime.now()
results = []
for obs_num in list(range(10000)):
    results.append(dask.delayed(singleSHAPprocess)(obs_num, X_scattered, model_rf_exp_scattered))
pd.Series(['import done', client, "load data", model.oob_score_, "scatter", "dalex", 
           "delayed"]).to_csv(DP02_result_location + '05_8node_TEST_report.csv')

test = dask.compute(*results) 
end = datetime.now()
print(f"B 10, N 900: Time taken: {end - start}")  
pd.Series(['import done', client, "load data", model.oob_score_, "scatter", "dalex", 
           "delayed", end - start]).to_csv(DP02_result_location + '05_8node_TEST_report.csv') 

dump(test, DP02_result_location + '00_05_TE_result_test.joblib')
pd.Series(['import done', client, "load data", model.oob_score_, "scatter", "dalex", 
           "delayed", end - start]).to_csv(DP02_result_location + '05_8node_TEST_report.csv')
 
client.close()

"""
results_bag = joblib.Parallel(n_jobs=100, verbose=2000, 
                              backend="multiprocessing")(
    joblib.delayed(singleSHAPprocess)(int(obs_num))
    for obs_num in np.linspace(0, 99, 100))

joblib.Parallel(n_jobs=4, verbose=2000, 
                backend="multiprocessing")( 
    joblib.delayed(singleSHAPprocess)(obs_num)
    for obs_num in list(range(200)))
      

def makeDirIfNotExist(path):
    isExist = os.path.exists(path)
    if not isExist:
        os.makedirs(path)
        print("The new directory is created!")
    else:
        print(path + " is there!")  

client = Client(n_workers=18, nthreads=1)
X_scattered = client.scatter(X)
model_rf_exp_scattered = client.scatter(model_rf_exp)

@dask.delayed
def singleSHAPprocess(obs_num, X, model_rf_exp):
    test_obs = X[obs_num:obs_num+1,:]
    shap_test = model_rf_exp.predict_parts(test_obs, type = 'shap', 
                                           B = 1, N = 10)
    result = shap_test.result[shap_test.result.B == 0]
    result = result[['contribution', 'variable_name']]
    result = result.transpose()
    result = result.rename(columns=result.iloc[1])
    result = result.drop(['variable_name'], axis=0)
    result = result.reset_index(drop=True)
    return result

results = []
for obs_num in list(range(4)):
    results.append(singleSHAPprocess(obs_num, X = X_scattered,
                                     model_rf_exp = model_rf_exp_scattered))

test = dask.compute(results)                        
"""