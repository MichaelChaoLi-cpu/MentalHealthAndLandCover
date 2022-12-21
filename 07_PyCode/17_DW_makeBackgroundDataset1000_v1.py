# -*- coding: utf-8 -*-
"""
Created on Wed Dec 21 14:48:02 2022

@author: li.chao.987@s.kyushu-u.ac.jp

NOTE: 
    GLOBAL_VARIABLE
    local_variable
    functionToRun
    Function_Input_Or_Ouput_Variable
"""

import pandas as pd
import numpy as np

from sklearn.model_selection import train_test_split 
import pyreadr

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
    return repo_location, repo_result_location

def makeBackgroundData1000():
    dataset = pyreadr.read_r(REPO_LOCATION + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
    dataset = dataset[None]
    X = dataset.iloc[:, 1:50]
    y = dataset.iloc[:, 0:1]
    X.to_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv")
    y.to_csv(REPO_LOCATION + "02_Data/97_y_toGPU.csv")
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=1000,
                                                        random_state=1)
    X_test.to_csv(REPO_LOCATION + "02_Data/99_1000_Background.csv")
    return None

REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('y')
makeBackgroundData1000()

