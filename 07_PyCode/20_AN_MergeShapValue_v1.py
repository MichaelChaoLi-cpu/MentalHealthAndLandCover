#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jan  3 15:43:48 2023

@author: lichao

NOTE: 
    GLOBAL_VARIABLE
    local_variable
    functionToRun
    Function_Input_Or_Ouput_Variable
"""

import pandas as pd
import numpy as np

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
    elif locally_or_remotely == 'mac':
        repo_location = "/Users/lichao/Library/CloudStorage/OneDrive-KyushuUniversity/02_Article/03_RStudio/"
        repo_result_location = "/Users/lichao/Library/CloudStorage/OneDrive-KyushuUniversity/02_Article/03_RStudio/08_PyResults/"
    return repo_location, repo_result_location

def mergeShapDataset():
    csv_read_list = []
    for order_num in list(range(1, 91, 1)):
        csv_name = REPO_RESULT_LOCATION + "shap_thousand_" + str(order_num) + ".csv"
        csv_read = pd.read_csv(csv_name, index_col=0)
        csv_read_list.append(csv_read)
    shap_value_merge = pd.concat(csv_read_list, axis=0)
    shap_value_merge.reset_index(inplace = True)
    shap_value_merge.drop(columns='index', inplace=True)
    return shap_value_merge

def getXwithShap(Merged_Shap_Value):
    X = pd.read_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv", index_col=0)
    X_colname = X.columns
    shap_colnames = X_colname + "_shap"
    Merged_Shap_Value.columns = shap_colnames
    dataset_to_analysis = pd.concat([X, Merged_Shap_Value], axis=1)
    return dataset_to_analysis

REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('mac')
Merged_Shap_Value = mergeShapDataset()
Dataset_To_Analysis = getXwithShap(Merged_Shap_Value)
Dataset_To_Analysis.to_csv(REPO_RESULT_LOCATION + "mergedXSHAP.csv")



