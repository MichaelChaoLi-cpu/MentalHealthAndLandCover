# -*- coding: utf-8 -*-
"""
Created on Tue Oct 18 15:17:49 2022

@author: li.chao.987@s.kyushu-u.ac.jp

#!/bin/bash
#PJM -L "rscunit=ito-a"
#PJM -L "rscgrp=ito-m"
#PJM -L "vnode=8"
#PJM -L "vnode-core=36"
#PJM -L "elapse=24:00:00"
#PJM -j
#PJM -X
module use /home/exp/modulefiles
module load gcc/10.2.0
mpirun  -np 8  -ppn 1  -machinefile ${PJM_O_NODEINF}  -launcher-exec /bin/pjrsh python /home/usr6/q70176a/DP02/07_PyCode/03_AN_HyperparameterTuning_v0.py
"""

import os
import dask_mpi as dm
from dask.distributed import Client, progress

import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib

import pyreadr

from sklearn.model_selection import train_test_split
from sklearn.experimental import enable_halving_search_cv
from sklearn.model_selection import GridSearchCV

import warnings

warnings.filterwarnings(action='ignore', category=UserWarning)

DP02_location = "/home/usr6/q70176a/DP02/"
DP02_result_location = "/home/usr6/q70176a/DP02/08_PyResults/"

### X and y
dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
dataset = dataset[None]

X = np.array(dataset.iloc[:, 1:50], dtype='float64')
y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')

print("Data Done!")

dm.initialize(local_directory=os.getcwd(),  nthreads=36, memory=0)
client = Client()
# client = Client(threads_per_worker=8, n_workers=1)

param_grid= {'max_features': [11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                              21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
             'min_samples_split':[5, 10, 15, 20, 25, 30, 35, 40]
             }
base_estimator = RandomForestRegressor(oob_score=True, random_state=1,
                                       n_estimators = 1000, n_jobs=36)

print("To fit!")

from dask_ml.model_selection import GridSearchCV
search = GridSearchCV(base_estimator, param_grid, n_jobs=6)
search.fit(X, y)

print("finish fitting!")

dump(search, DP02_result_location + '01_hyperParaSearching.joblib')

print("Output!")

client.close()

"""
import os
import pyreadr

import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib
from datetime import datetime

from sklearn.model_selection import train_test_split
from sklearn.experimental import enable_halving_search_cv
from sklearn.model_selection import GridSearchCV

DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"

### X and y
dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
dataset = dataset[None]

X = np.array(dataset.iloc[:, 1:50], dtype='float64')
y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')

param_grid= {'max_features': [11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                              21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
             'min_samples_split':[5, 10, 15, 20, 25, 30, 35, 40]
             }
base_estimator = RandomForestRegressor(oob_score=True, random_state=1,
                                       n_estimators = 1000, n_jobs=-1)

search = GridSearchCV(base_estimator, param_grid, n_jobs=1, cv=3,
                      verbose=50, scoring='r2')
search.fit(X, y)

dump(search, DP02_result_location + '01_hyperParaSearching.joblib')
"""