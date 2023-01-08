# -*- coding: utf-8 -*-
"""
Created on Wed Dec 21 15:15:24 2022

@author: li.chao.987@s.kyushu-u.ac.jp

NOTE: 
    GLOBAL_VARIABLE
    local_variable
    functionToRun
    Function_Input_Or_Ouput_Variable
    
for Linux
"""


import pandas as pd
import numpy as np

from cuml.ensemble import RandomForestRegressor as cuRandomForestRegressor
import cudf
import cupy as cp

from cuml.explainer import KernelExplainer
from joblib import dump, load
from glob import glob

def runLocallyOrRemotely(Locally_Or_Remotely):
    locally_or_remotely = Locally_Or_Remotely
    if locally_or_remotely == 'y':
        repo_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
        repo_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"
    elif locally_or_remotely == 'n':
        repo_location = "/home/usr6/q70176a/DP02/"
        repo_result_location = "/home/usr6/q70176a/DP02/03_Results/"
    elif locally_or_remotely == 'wsl':
        repo_location = "/mnt/d/OneDrive - Kyushu University/02_Article/03_RStudio/"
        repo_result_location = "/mnt/d/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"
    elif  locally_or_remotely == 'linux':
        repo_location = "/mnt/d/OneDrive - Kyushu University/02_Article/03_RStudio/"
        repo_result_location = "/mnt/d/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"
    return repo_location, repo_result_location


def makeCuModel():
    X = pd.read_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv", index_col=0)
    y = pd.read_csv(REPO_LOCATION + "02_Data/97_y_toGPU.csv", index_col=0)
    cuX = cudf.from_pandas(X)
    cuy = cudf.from_pandas(y)
    
    cumodel = cuRandomForestRegressor(n_estimators=1000, min_samples_split = 30, 
                                      max_features = 11, random_state=1)
    ###  min_samples_split = 2, max_features = 9
    cumodel.fit(cuX, cuy) 
    return cumodel

def makeExplainer(cumodel):
    background_dataframe_file_name = REPO_LOCATION + "02_Data/99_1000_Background.csv"
    background_dataframe = pd.read_csv(background_dataframe_file_name,
                                       index_col=0)
    
    cu_explainer = KernelExplainer(model=cumodel.predict,
                                   data=cudf.from_pandas(background_dataframe),
                                   is_gpu_model=True, random_state=1)
    return cu_explainer

def dumpModelAndExplainer():
    cumodel = makeCuModel()
    cu_explainer = makeExplainer(cumodel)
    dump(cumodel, REPO_RESULT_LOCATION + "96_cumodel.joblib")
    dump(cu_explainer, REPO_RESULT_LOCATION + "95_cu_explainer.joblib")
    return None

REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('wsl')
dumpModelAndExplainer()

