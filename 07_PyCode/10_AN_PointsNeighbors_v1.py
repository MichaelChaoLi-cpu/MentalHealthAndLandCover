#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov  8 20:02:52 2022

@author: lichao
"""

import os
import pandas as pd
import numpy as np

from sklearn.ensemble import RandomForestRegressor
from joblib import dump
import joblib
from sklearn.linear_model import LinearRegression

import pyreadr

from datetime import datetime

from joblib import Parallel, delayed

DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"

### define function
def XYSplit(model):
    total_tree_number = model.n_estimators
    X_split_array = []
    Y_split_array = []
    for tree_order in list(range(total_tree_number)):
        feature = model.estimators_[tree_order].tree_.feature
        threshold = model.estimators_[tree_order].tree_.threshold
        
        df = pd.concat([pd.Series(feature), pd.Series(threshold)], axis=1)
        df.columns = ['feature', 'threshold']
        X_split = df[df['feature']==47]
        Y_split = df[df['feature']==48]
        
        X_split = X_split.sort_values('threshold')
        Y_split = Y_split.sort_values('threshold')
        X_split = np.array(X_split.threshold, dtype='float64')
        Y_split = np.array(Y_split.threshold, dtype='float64')
        
        X_split_array.append(X_split)
        Y_split_array.append(Y_split)
        
    return (X_split_array, Y_split_array)

def findBoundaryArray(split_array, data_degree):
    #boundary_array = []
    #for observation in data_degree:
    #    boundary = findBoundary(split_array, observation)
    #    boundary_array.append(boundary)
        
    boundary_array = joblib.Parallel(n_jobs=10)(
        joblib.delayed(findBoundary)(split_array, observation)
        for observation in data_degree)
        
    return boundary_array
    
    
def findBoundary(split_array, observation):
    before_array = []
    after_array = []
    for split in split_array:
        split_add = np.insert(split, 0, observation)
        split_add = np.sort(split_add)
        location = np.where(split_add == observation)[0][0]
        if location == 0:
            before = observation - 0.1
        else:
            before = split[location - 1]
        if location == len(split_add)-1:
            after = observation + 0.1
        else:
            after = split[location]
        before_array.append(before)
        after_array.append(after)
    before_observation = np.min(np.array(before_array))
    after_observation = np.max(np.array(after_array))
    #np.median
    return [before_observation, after_observation]

def buildNeighborList(data, leftRightBoundary, upDownBoundary):
    data = pd.DataFrame(data[:, 47:49], columns=['X', 'Y'])
    index_select_array = []
    for obs_order in list(range(len(data))):
         data_select = data[
             (data['X'] > leftRightBoundary[obs_order][0]) &
             (data['X'] < leftRightBoundary[obs_order][1]) &
             (data['Y'] > upDownBoundary[obs_order][0]) &
             (data['Y'] < upDownBoundary[obs_order][1])
             ]
         index_select = np.array(data_select.index)
         index_select_array.append(index_select)
    return index_select_array

def getMergeSHAPresult():
    result = pd.read_csv(DP02_result_location + "mergedXSHAP.csv", index_col=0)
    return result

def SpatialCoefficientBetweenLandCoverAndItsSHAP(variable_name, result, 
                                                 neighborList):
    coef_array = []
    intercept_array = []
    for neighbors in neighborList:
        result_selected = result.iloc[neighbors,:]
        result_selected = result_selected[[variable_name, variable_name+'_SHAP']]
        reg = LinearRegression().fit(result_selected[[variable_name]], 
                                     np.array(result_selected[[variable_name+'_SHAP']]))
        coef_array.append(reg.coef_[0][0])
        intercept_array.append(reg.intercept_[0])
    coef_mat = pd.concat([pd.Series(coef_array),
                          pd.Series(intercept_array)], axis=1)
    coef_mat.columns = [variable_name+'_coef', variable_name+'_interc']
    
    return coef_mat
        
### run
dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
dataset = dataset[None]
y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')
X = np.array(dataset.iloc[:, 1:50], dtype='float64')
model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 11, n_jobs=-1, 
                               min_samples_split = 30)
model.fit(X, y)

X_split_array, Y_split_array = XYSplit(model)
leftRightBoundary = findBoundaryArray(X_split_array, X[:,47])
upDownBoundary = findBoundaryArray(Y_split_array, X[:,48])
neighborList = buildNeighborList(X, leftRightBoundary, upDownBoundary)
result = getMergeSHAPresult()

crop_spatialcoefficient = \
    SpatialCoefficientBetweenLandCoverAndItsSHAP('crop2015', result, neighborList)


income_spatialcoefficient = \
    SpatialCoefficientBetweenLandCoverAndItsSHAP('di_inc_gdp', result, neighborList)

"""
# mac
DP02_location = "/Users/lichao/Library/CloudStorage/OneDrive-KyushuUniversity/02_Article/03_RStudio/"
DP02_result_location = "/Users/lichao/Library/CloudStorage/OneDrive-KyushuUniversity/02_Article/03_RStudio/08_PyResults/"

"""
