# -*- coding: utf-8 -*-
"""
Created on Tue Oct 18 15:53:19 2022

@author: li.chao.987@s.kyushu-u.ac.jp

#!/bin/bash
#PJM -L "rscunit=ito-a"
#PJM -L "rscgrp=ito-s-dbg"
#PJM -L "vnode=4"
#PJM -L "vnode-core=36"
#PJM -L "elapse=01:00:00"
#PJM -j
#PJM -X
module use /home/exp/modulefiles
module load gcc/10.2.0
mpirun  -np 4  -ppn 1  -machinefile ${PJM_O_NODEINF}  -launcher-exec /bin/pjrsh python /home/usr6/q70176a/DP02/07_PyCode/04_TE_DaskDalex_v0.py
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
#from dask.distributed import Client, progress

from datetime import datetime

from joblib import Parallel, delayed

import warnings

DP02_location = "/home/usr6/q70176a/DP02/"
DP02_result_location = "/home/usr6/q70176a/DP02/08_PyResults/"

#pd.Series(['import done']).to_csv(DP02_result_location + '04_TEST_report.csv')

warnings.filterwarnings(action='ignore', category=UserWarning)

#dm.initialize(local_directory=os.getcwd(),  nthreads=4, memory_limit=0.99)
#client = Client()
#pd.Series(['import done', client]).to_csv(DP02_result_location + '04_TEST_report.csv')

dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")

dataset = dataset[None]

y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')
X = np.array(dataset.iloc[:, 1:50], dtype='float64')
#pd.Series(['import done', client, "load data"]).to_csv(DP02_result_location + '04_TEST_report.csv')


#from sklearn.datasets import make_regression
#X, y = make_regression(n_samples = 100000, n_features = 50, random_state=1)

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 11, n_jobs=-1)
model.fit(X, y)
#with joblib.parallel_backend("dask"): model.fit(X, y)


#pd.Series(['import done', client, "load data", model.oob_score_]).to_csv(DP02_result_location + '04_TEST_report.csv')

# SHAP
import dalex as dx

model_rf_exp = dx.Explainer(model, X, y, label = "RF Pipeline")

#pd.Series(['import done', client, "load data", model.oob_score_, "dalex"]).to_csv(DP02_result_location + '04_TEST_report.csv')


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

#start = datetime.now()
#with joblib.parallel_backend('dask'):
#    results_bag = joblib.Parallel(n_jobs=16, verbose=100)(
#        joblib.delayed(singleSHAPprocess)(int(obs_num))
#        for obs_num in np.linspace(0, 1339, 1400))
    
results_bag = joblib.Parallel(n_jobs=4, verbose=100)(
    joblib.delayed(singleSHAPprocess)(int(obs_num))
    for obs_num in np.linspace(2000, 3999, 2000))


#end = datetime.now()
#print(f"B 5, N 5000: Time taken: {end - start}")   

#pd.Series(['import done', client, "load data", model.oob_score_, "dalex", end - start]).to_csv(DP02_result_location + '04_TEST_report.csv')

dump(results_bag, DP02_result_location + '00_04_TE_result.joblib')

#client.close()