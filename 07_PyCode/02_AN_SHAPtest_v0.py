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
mpirun  -np 72  -ppn 18  -machinefile ${PJM_O_NODEINF}  -launcher-exec /bin/pjrsh python /home/usr6/q70176a/DP02/07_PyCode/02_AN_SHAPtest_v0.py
"""

import os
import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib

import pyreadr

from sklearn.model_selection import train_test_split
from sklearn.experimental import enable_halving_search_cv
from sklearn.model_selection import HalvingGridSearchCV

import dask_mpi as dm
from dask.distributed import Client, progress

from datetime import datetime

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
                               random_state=1, n_jobs=-1, max_features = 14)

dm.initialize(local_directory=os.getcwd(),  nthreads=18)
client = Client()

with joblib.parallel_backend("dask"): model.fit(X, y, sample_weight = weight)

# SHAP
import dalex as dx

model_14feature_rf_exp = dx.Explainer(model, X, y,  
                                      label = "RF Pipeline")
test_obs = X.iloc[0:1,:]

start = datetime.now()
shap_test = model_14feature_rf_exp.predict_parts(test_obs, type = 'shap')
end = datetime.now()

print(f"No Dask Time taken: {end - start}")

start = datetime.now()
with joblib.parallel_backend("dask"): shap_test = model_14feature_rf_exp.predict_parts(test_obs, type = 'shap')
end = datetime.now()
print(f"With Dask Time taken: {end - start}")
