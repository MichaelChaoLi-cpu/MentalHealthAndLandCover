# -*- coding: utf-8 -*-
"""
Created on Tue Oct 18 15:17:49 2022

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
mpirun  -np 64  -ppn 4  -machinefile ${PJM_O_NODEINF}  -launcher-exec /bin/pjrsh python /home/usr6/q70176a/DP02/07_PyCode/03_AN_HyperparameterTuning_v0.py

"""

import os
import dask_mpi as dm
from dask.distributed import Client, progress

import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib
from dask_ml.model_selection import GridSearchCV

import pyreadr

def initializeLogFile(File_Name):
    file_full_name = REPO_RESULT_LOCATION + File_Name
    start_time = datetime.now()
    f = open(file_full_name, "w")
    f.write("Initialized!" + " ; ")
    f.write(str(start_time) + "\n")
    f.close()
    return start_time, file_full_name

def addRecordToLog(Input_Element):
    now_time = datetime.now()
    f = open(FILE_FULL_NAME, "a")
    f.write(str(Input_Element) + " ; ")
    f.write(str(now_time - LOG_START_TIME) + " ; ")
    f.write(str(now_time) + "\n")
    f.close()
    return None

def makeXandY():
    dataset = pyreadr.read_r(REPO_LOCATION + "02_Data/SP_Data_49Variable_RdsVer.Rds")
    dataset = dataset[None]

    X = np.array(dataset.iloc[:, 1:50], dtype='float64')
    y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')
    return X, y

def searchBestParameter(X, y):
    param_grid= {'max_features': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                                  11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                                  21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
                                  31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
                                  41, 42, 43, 44, 45, 46, 47, 48, 49]
                 }
    base_estimator = RandomForestRegressor(oob_score=True, random_state=1,
                                           n_estimators = 1000, min_samples_split = 30)
    search = GridSearchCV(base_estimator, param_grid, n_jobs=-1, cv=10)
    search.fit(X, y)
    return search

def saveSearchCheckTable(Search):
    mat = Search.cv_results_
    check_table = pd.DataFrame(np.array(
        [mat["rank_test_score"], mat['param_max_features'],
         mat['mean_test_score'], mat['std_test_score']
         ]).T)
    check_table.columns = ["rank_test_score", 'param_max_features', 
                           'mean_test_score', 'std_test_score']
    check_table.to_csv(REPO_RESULT_LOCATION + "02_CheckTable.csv")
    return None
    

REPO_LOCATION = "/home/usr6/q70176a/DP02/"
REPO_RESULT_LOCATION = "/home/usr6/q70176a/DP02/08_PyResults/"

dm.initialize(local_directory=os.getcwd(),  nthreads=9, memory_limit=0.25)
CLIENT = Client()
LOG_NAME = "01_hyperTuningLog.txt"
LOG_START_TIME, FILE_FULL_NAME = initializeLogFile(LOG_NAME)

X, y = makeXandY()
addRecordToLog(CLIENT)
addRecordToLog("Data Loaded")

Search = searchBestParameter(X, y)
addRecordToLog("Search done")

saveSearchCheckTable(Search)
addRecordToLog("Check Table done")

dump(search, DP02_result_location + '01_hyperParaSearching.joblib')
addRecordToLog("Save done")

CLIENT.close()

"""
from joblib import load
from dask_ml.model_selection import GridSearchCV

DP02_result_location = "/home/usr6/q70176a/DP02/08_PyResults/"
search = load(DP02_result_location + '01_hyperParaSearching.joblib')
print(search.cv_results_)
mat = search.cv_results_
check_table = pd.DataFrame(np.array(
    [mat["rank_test_score"], mat['param_max_features'],
     mat['param_min_samples_split'], mat['mean_test_score'],
     mat['std_test_score']
     ]).T)

### max_features = 10 
### min_samples_split = 30
"""
