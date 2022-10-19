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

#import dask_mpi as dm
from dask.distributed import Client, progress

from datetime import datetime

from joblib import Parallel, delayed


DP02_location = "/home/usr6/q70176a/DP02/"
DP02_result_location = "/home/usr6/q70176a/DP02/08_PyResults/"
### local folder on PC:
# DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
# DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"
pd.Series(['import done']).to_csv(DP02_result_location + '03_SHAP_report.csv')

dm.initialize(local_directory=os.getcwd(),  nthreads=36)
client = Client(threads_per_worker=6, n_workers=1)
print(client)
pd.Series(['import done', 'initial done', client]).to_csv(DP02_result_location + '03_SHAP_report.csv')

### local folder on PC:
# DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio"
# DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"

dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")

dataset = dataset[None]
pd.Series(['import done', 'initial done', 'first done']).to_csv(DP02_result_location + '03_SHAP_report.csv')

y = dataset.iloc[:, 0:1]
X = dataset.iloc[:, 1:50]
weight = dataset[['weights']].values.flatten()

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 14)

start = datetime.now()
model.fit(X, y)
end = datetime.now()
test_time6 = end - start
print(f"model without dask: Time taken: {end - start}")
pd.Series(['import done', 'initial done', 'first done', test_time6]).to_csv(DP02_result_location + '03_SHAP_report.csv')

model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 11)
start = datetime.now()
with joblib.parallel_backend("dask"): model.fit(X, y)

end = datetime.now()
test_time7 = end - start
print(f"model with dask: Time taken: {end - start}")
#model.fit(X, y, sample_weight = weight)
pd.Series(['import done', 'initial done', 'first done', test_time6, test_time7]).to_csv(DP02_result_location + '03_SHAP_report.csv')

# SHAP
import dalex as dx

model_14feature_rf_exp = dx.Explainer(model, X, y,  
                                      label = "RF Pipeline")
pd.Series(['import done', 'initial done', 'first done', test_time6, test_time7, 'dalex pass']).to_csv(DP02_result_location + '03_SHAP_report.csv')

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


start = datetime.now()
with joblib.parallel_backend('dask'):
    results_bag = joblib.Parallel(n_jobs=6, verbose=100)(
        joblib.delayed(model_14feature_rf_exp.predict_parts)(X.iloc[int(obs_num):int(obs_num)+1,:],
                                                             type = 'shap', 
                                                             B = 5, N = 5000)
        for obs_num in np.linspace(0, 11, 12))


end = datetime.now()
test_time8 = end - start
print(f"B 5, N 5000: Time taken: {end - start}")   
pd.Series(['import done', 'initial done', 'first done', test_time6, test_time7, 'dalex pass', test_time8]).to_csv(DP02_result_location + '03_SHAP_report.csv')

dump(results_bag, DP02_result_location + '02_SHAP_testResult.joblib') 
pd.Series(['import done', 'initial done', 'first done', test_time6, test_time7, 'dalex pass', test_time8, "dump done"]).to_csv(DP02_result_location + '03_SHAP_report.csv')

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

"""
lazy_results = []
for obs_num in np.linspace(0, 29, 30):
    lazy_result = dask.delayed(singleSHAPprocess)(int(obs_num))
    lazy_results.append(lazy_result)
    
futures = []
for obs_num in np.linspace(0, 29, 30):
    shap_test = model_14feature_rf_exp.predict_parts(int(obs_num), 
                                                     type = 'shap', 
                                                     B = 5, N = 5000)
    return shap_test.result


start = datetime.now()
with joblib.parallel_backend('dask'):
    test_result = joblib.Parallel(verbose=100)(
        joblib.delayed(singleSHAPprocess)(int(obs_num), model_14feature_rf_exp, X)
        for obs_num in np.linspace(0, 35, 36))

end = datetime.now()
test_time8 = end - start
print(f"B 5, N 5000: Time taken: {end - start}")   

"""
