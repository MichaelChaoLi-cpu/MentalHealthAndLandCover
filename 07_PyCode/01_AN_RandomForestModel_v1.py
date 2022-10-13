# -*- coding: utf-8 -*-
"""
#NOTE: this script only works on HPC

M.L.
"""

import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib

import pyreadr

from sklearn.model_selection import train_test_split

DP02_location = "/home/usr6/q70176a/DP02/"
DP02_result_location = "/home/usr6/q70176a/DP02/04_Results/"

dataset = pyreadr.read_r(DP01_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")

dataset = dataset[None]
print("data here\n")

y = dataset.iloc[:, 0:1]
X = dataset.iloc[:, 1:50]
weight = dataset[['weights']].values.flatten()
model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, n_jobs=-1, max_features = 16)
model.fit(X, y, sample_weight = weight)

print(model.oob_score_)
dump(model, DP02_result_location + 'model_1000tree_49var_reg_weights.joblib') 

