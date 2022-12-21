# -*- coding: utf-8 -*-
"""
Created on Wed Dec 21 15:26:58 2022

@author: li.chao.987@s.kyushu-u.ac.jp

NOTE: 
    GLOBAL_VARIABLE
    local_variable
    functionToRun
    Function_Input_Or_Ouput_Variable
"""

import pandas as pd
import numpy as np

from cuml.ensemble import RandomForestRegressor as cuRandomForestRegressor
import cudf
import cupy as cp

from cuml.explainer import KernelExplainer
from joblib import dump, load

import sys

from glob import glob

def runLocallyOrRemotely(Locally_Or_Remotely):
    locally_or_remotely = Locally_Or_Remotely
    if locally_or_remotely == 'y':
        repo_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
        repo_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/07_PyResults/"
    elif locally_or_remotely == 'n':
        repo_location = "/home/usr6/q70176a/DP02/"
        repo_result_location = "/home/usr6/q70176a/DP02/03_Results/"
    elif locally_or_remotely == 'wsl':
        repo_location = "/mnt/d/OneDrive - Kyushu University/02_Article/03_RStudio/"
        repo_result_location = "/mnt/d/OneDrive - Kyushu University/02_Article/03_RStudio/07_PyResults/"
    elif  locally_or_remotely == 'linux':
        repo_location = "/mnt/d/OneDrive - Kyushu University/02_Article/03_RStudio/"
        repo_result_location = "/mnt/d/OneDrive - Kyushu University/02_Article/03_RStudio/07_PyResults/"
    return repo_location, repo_result_location

def getShapCSV(Cu_Explainer, kID=1):
    X = pd.read_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv", index_col=0)
    cu_shap_value_merge = Cu_Explainer.shap_values(X.iloc[(kID-1)*1000:kID*1000,:])
    pd.DataFrame(cu_shap_value_merge).to_csv(REPO_RESULT_LOCATION + "shap_thousand_" + str(kID) + ".csv")
    return None

INPUT_PARAMETER_1 = sys.argv[1]

REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely()
CU_EXPLAINER = load(REPO_RESULT_LOCATION + "95_cu_explainer.joblib")

getShapCSV(CU_EXPLAINER, kID=int(INPUT_PARAMETER_1))