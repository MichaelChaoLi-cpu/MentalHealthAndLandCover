# -*- coding: utf-8 -*-
"""
Created on Fri Oct 14 09:50:41 2022

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
mpirun  -np 144  -ppn 36  -machinefile ${PJM_O_NODEINF}  -launcher-exec /bin/pjrsh python /home/usr6/q70176a/DP02/07_PyCode/02_AN_SHAPtest_v0.py
"""

import os
import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib

import pyreadr

from sklearn.model_selection import train_test_split

import dask_mpi as dm
from dask.distributed import Client, progress

from datetime import datetime

from joblib import Parallel, delayed

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

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, n_jobs=36, max_features = 14)

dm.initialize(local_directory=os.getcwd(),  nthreads=36)
client = Client()

start = datetime.now()
model.fit(X, y, sample_weight = weight)
end = datetime.now()
test_time8 = end - start
print(f"model without dask: Time taken: {end - start}")

start = datetime.now()
with joblib.parallel_backend("dask"): model.fit(X, y, sample_weight = weight)
end = datetime.now()
test_time8 = end - start
print(f"model with dask: Time taken: {end - start}")
#model.fit(X, y, sample_weight = weight)

# SHAP
import dalex as dx

model_14feature_rf_exp = dx.Explainer(model, X, y,  
                                      label = "RF Pipeline")

def singleSHAPprocess(obs_num):
    test_obs = X.iloc[obs_num:obs_num+1,:]
    shap_test = model_14feature_rf_exp.predict_parts(test_obs, type = 'shap', 
                                                     B = 5, N = 5000)
    result = shap_test.result[shap_test.result.B == 0]
    result = result[['contribution', 'variable_name']]
    result = result.transpose()
    result = result.rename(columns=result.iloc[1])
    result = result.drop(['variable_name'], axis=0)
    result = result.reset_index(drop=True)
    return result

import dask.bag as db
b = db.from_sequence(list(range(144)), npartitions=144)
b = b.map(singleSHAPprocess)

start = datetime.now()
results_bag = b.compute()
end = datetime.now()
test_time8 = end - start
print(f"B 5, N 5000: Time taken: {end - start}")

print(results_bag)

"""
test_obs = X.iloc[0:1,:]

start = datetime.now()
shap_test = model_14feature_rf_exp.predict_parts(test_obs, type = 'shap')
end = datetime.now()

print(f"No Dask Time taken: {end - start}")

start = datetime.now()
with joblib.parallel_backend("dask"): shap_test = model_14feature_rf_exp.predict_parts(test_obs, type = 'shap')
end = datetime.now()
print(f"With Dask Time taken: {end - start}")
"""

"""
def singleSHAPprocess(obs_num, model_rf_exp, X):
    test_obs = X.iloc[obs_num:obs_num+1,:]
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


end = datetime.now()
test_time7 = end - start

print(f"B 5, N 5000: Time taken: {end - start}")

print(test_result)

import dask
from dask.distributed import Client, LocalCluster
cluster = LocalCluster()
client = Client(cluster)

#for obs_num in np.linspace(0, 143, 144):
results = []
for obs_num in np.linspace(0, 9, 10):
    # Note the difference in way the inc function is called!
    y = dask.delayed(singleSHAPprocess)(int(obs_num), model_14feature_rf_exp, X)
    results.append(y)

start = datetime.now()

test_result_2 = dask.persist(*results)

end = datetime.now()
test_time8 = end - start

print(f"B 5, N 5000: Time taken: {end - start}")

print(test_result_2)
"""

