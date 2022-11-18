# -*- coding: utf-8 -*-
"""
Created on Fri Nov 18 10:06:46 2022

@author: li.chao.987@s.kyushu-u.ac.jp

#!/bin/bash
#PJM -L "rscunit=ito-a"
#PJM -L "rscgrp=ito-s"
#PJM -L "vnode=2"
#PJM -L "vnode-core=36"
#PJM -L "elapse=01:00:00"
#PJM -j
#PJM -X
module use /home/exp/modulefiles
module load gcc/10.2.0
mpirun  -np 12 -ppn 6  -machinefile ${PJM_O_NODEINF}  -launcher-exec /bin/pjrsh python /home/usr6/q70176a/DP02/07_PyCode/99_TE_2node7thread_v0.py

"""

import os
import pandas as pd
import numpy as np

import pyreadr

import dask_mpi as dm
from dask.distributed import Client, progress
import dask
from dask.distributed import performance_report

from datetime import datetime
from joblib import Parallel, delayed
from sklearn.ensemble import RandomForestRegressor
from joblib import dump, load
import joblib

import dask.config
import distributed

os.environ["MALLOC_TRIM_THRESHOLD_"] = str(dask.config.get("distributed.nanny.environ.MALLOC_TRIM_THRESHOLD_"))

DP02_location = "/home/usr6/q70176a/DP02/"
DP02_result_location = "/home/usr6/q70176a/DP02/08_PyResults/"
pd.Series(['import done']).to_csv(DP02_result_location + 
                                  '99_2node_7Thread_TEST_report.csv')

dm.initialize(local_directory=os.getcwd(),  nthreads=1, memory_limit=0.1666)
client = Client()
pd.Series(['import done', client]).to_csv(DP02_result_location + 
                                          '99_2node_7Thread_TEST_report.csv')

dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
dataset = dataset[None]
y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')
X = np.array(dataset.iloc[:, 1:50], dtype='float64')
pd.Series(['import done', client, "load data"]).to_csv(DP02_result_location + 
                                                       '99_2node_7Thread_TEST_report.csv')

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 9, n_jobs=-1)
with joblib.parallel_backend("dask"): model.fit(X, y)
pd.Series(['import done', client, 
           "load data", model.oob_score_]).to_csv(DP02_result_location + 
                                                  '99_2node_7Thread_TEST_report.csv')

# SHAP
import dalex as dx
model_rf_exp = dx.Explainer(model, X, y, label = "RF Pipeline")
pd.Series(['import done', client, "load data", 
           model.oob_score_, "dalex"]).to_csv(DP02_result_location + 
                                              '99_2node_7Thread_TEST_report.csv')

with performance_report(filename="dask-report-scatter.html"):
    X_scattered = client.scatter(X)
    model_rf_exp_scattered = client.scatter(model_rf_exp)

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

delayed_results = [dask.delayed(singleSHAPprocess)(obs_num, X_scattered, model_rf_exp_scattered)  for obs_num in list(range(100))]


with performance_report(filename="dask-report-shap.html"):
    results = dask.compute(*delayed_results)

    
pd.Series(['import done', client, "load data", model.oob_score_, "dalex", 
           "delayed"]).to_csv(DP02_result_location + '99_2node_7Thread_TEST_report.csv')