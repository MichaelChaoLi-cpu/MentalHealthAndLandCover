# -*- coding: utf-8 -*-
"""
Created on Sun Nov  6 10:15:12 2022

@author: li.chao.987@s.kyushu-u.ac.jp
"""

from joblib import load
import pandas as pd
import numpy as np
import pyreadr

DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"

def makeSHAPdataframe():
    results_0_9999 = pd.concat(
        load(DP02_result_location + '00_05_TE_result_0_9999.2nd.joblib')
        )
    results_10000_19999 = pd.concat(
        load(DP02_result_location + '00_05_TE_result_10000_19999.2nd.joblib')
        )
    results_20000_29999 = pd.concat(
        load(DP02_result_location + '00_05_TE_result_20000_29999.2nd.joblib')
        )
    results_30000_39999 = pd.concat(
        load(DP02_result_location + '00_05_TE_result_30000_39999.2nd.joblib')
        )
    results_40000_49999 = pd.concat(
        load(DP02_result_location + '00_05_TE_result_40000_49999.2nd.joblib')
        )
    results_50000_59999 = pd.concat(
        load(DP02_result_location + '00_05_TE_result_50000_59999.2nd.joblib')
        )
    results_60000_69999 = pd.concat(
        load(DP02_result_location + '00_05_TE_result_60000_69999.2nd.joblib')
        )
    results_70000_79999 = pd.concat(
        load(DP02_result_location + '00_05_TE_result_70000_79999.2nd.joblib')
        )
    results_80000_89272 = pd.concat(
        load(DP02_result_location + '00_05_TE_result_80000_89273.2nd.joblib')
        )
    
    results = pd.concat(
        [results_0_9999, results_10000_19999, results_20000_29999, 
         results_30000_39999, results_40000_49999, results_50000_59999,
         results_60000_69999, results_70000_79999, results_80000_89272]
        )
    return results

def renameReindexDataframe(results):
    dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
    dataset = dataset[None]
    X = dataset.iloc[:, 1:50]
    name_num = []
    for num in np.linspace(0, 48, 49):
        name_num.append(str(int(num)))
    results = results[name_num]
    results.columns = X.columns
    results['index_col'] = list(range(89273))
    results = results.set_index('index_col')
    results = results.add_suffix('_SHAP')
    return results
    
def mergeXandResults(results):
    dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
    dataset = dataset[None]
    #X = dataset.iloc[:, 1:50]
    XResults = pd.concat([dataset, results], axis=1)
    return XResults

results = makeSHAPdataframe()
results = renameReindexDataframe(results)
XResults = mergeXandResults(results)

XResults.to_csv(DP02_result_location + "mergedXSHAP.csv")





