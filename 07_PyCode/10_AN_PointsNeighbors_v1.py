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
            before = observation - 1
        else:
            before = split[location - 1]
        if location == len(split_add)-1:
            after = observation + 1
        else:
            after = split[location]
        before_array.append(before)
        after_array.append(after)
    #before_observation = np.min(np.array(before_array))
    #after_observation = np.max(np.array(after_array))
    before_observation = np.median(np.array(before_array))
    after_observation = np.median(np.array(after_array))
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
    result = pd.read_csv(REPO_RESULT_LOCATION + "mergedXSHAP.csv", index_col=0)
    return result

def SpatialCoefficientBetweenLandCoverAndItsSHAP(variable_name, result, 
                                                 neighborList):
    coef_mat = joblib.Parallel(n_jobs=10)(
        joblib.delayed(singleCoefficientBetweenLandCoverAndItsSHAP)(neighbors, variable_name, result)
        for neighbors in neighborList)
    coef_mat = pd.DataFrame(np.array(coef_mat))
    coef_mat.columns = [variable_name+'_coef', variable_name+'_interc']
    
    return coef_mat

def singleCoefficientBetweenLandCoverAndItsSHAP(neighbors, variable_name, result):
    result_selected = result.iloc[neighbors,:]
    result_selected = result_selected[[variable_name, variable_name+'_SHAP']]
    X_data = result_selected[[variable_name]]
    y = np.array(result_selected[[variable_name+'_SHAP']])
    reg = LinearRegression().fit(X_data, y)
    predictions = reg.predict(X_data)
    newX = X_data
    newX['Constant'] = 1
    try:
        MSE = (sum((y-predictions)**2))/(len(newX)-len(newX.columns))
        var_b = MSE*(np.linalg.inv(np.dot(newX.T,newX)).diagonal())
        sd_b = np.sqrt(var_b) 
        t_coef = reg.coef_[0][0]/sd_b[0]
        t_interc = reg.intercept_[0]/sd_b[1]
    except:
        t_coef=0
        t_interc=0
    if t_coef > 1.64:
        coef = reg.coef_[0][0]
    else:
        coef = 0
    if t_interc > 1.64:
        intercept = reg.intercept_[0]
    else:
        intercept = 0
    return [coef, intercept]

def obtainSpatialCoefficientDf(result, neighborList):
    ### get the spatial coefficient
    crop_spatialcoefficient = \
        SpatialCoefficientBetweenLandCoverAndItsSHAP('crop2015', result, neighborList)
    fore_spatialcoefficient = \
        SpatialCoefficientBetweenLandCoverAndItsSHAP('fore2015', result, neighborList)
    gras_spatialcoefficient = \
        SpatialCoefficientBetweenLandCoverAndItsSHAP('gras2015', result, neighborList)
    shru_spatialcoefficient = \
        SpatialCoefficientBetweenLandCoverAndItsSHAP('shru2015', result, neighborList)
    wetl_spatialcoefficient = \
        SpatialCoefficientBetweenLandCoverAndItsSHAP('wetl2015', result, neighborList)
    wate_spatialcoefficient = \
        SpatialCoefficientBetweenLandCoverAndItsSHAP('wate2015', result, neighborList)
    impe_spatialcoefficient = \
        SpatialCoefficientBetweenLandCoverAndItsSHAP('impe2015', result, neighborList)
    bare_spatialcoefficient = \
        SpatialCoefficientBetweenLandCoverAndItsSHAP('bare2015', result, neighborList)
    income_spatialcoefficient = \
        SpatialCoefficientBetweenLandCoverAndItsSHAP('di_inc_gdp', result, neighborList)
    spatialCoefficientDf = pd.concat([crop_spatialcoefficient, fore_spatialcoefficient,
                                      gras_spatialcoefficient, shru_spatialcoefficient,
                                      wetl_spatialcoefficient, wate_spatialcoefficient,
                                      impe_spatialcoefficient, bare_spatialcoefficient,
                                      income_spatialcoefficient], axis = 1)
    return spatialCoefficientDf

def calculateMonetaryValue(spatialCoefficientDf):
    spatialCoefficientDf['di_inc_gdp_coef_add'] = spatialCoefficientDf.di_inc_gdp_coef
    spatialCoefficientDf[spatialCoefficientDf['di_inc_gdp_coef_add']==0]['di_inc_gdp_coef_add'] = float('inf')
    spatialCoefficientDf['crop2015_MV'] = spatialCoefficientDf.crop2015_coef/spatialCoefficientDf.di_inc_gdp_coef_add
    spatialCoefficientDf['fore2015_MV'] = spatialCoefficientDf.fore2015_coef/spatialCoefficientDf.di_inc_gdp_coef_add
    spatialCoefficientDf['gras2015_MV'] = spatialCoefficientDf.gras2015_coef/spatialCoefficientDf.di_inc_gdp_coef_add
    spatialCoefficientDf['shru2015_MV'] = spatialCoefficientDf.shru2015_coef/spatialCoefficientDf.di_inc_gdp_coef_add
    spatialCoefficientDf['wetl2015_MV'] = spatialCoefficientDf.wetl2015_coef/spatialCoefficientDf.di_inc_gdp_coef_add
    spatialCoefficientDf['wate2015_MV'] = spatialCoefficientDf.wate2015_coef/spatialCoefficientDf.di_inc_gdp_coef_add
    spatialCoefficientDf['impe2015_MV'] = spatialCoefficientDf.impe2015_coef/spatialCoefficientDf.di_inc_gdp_coef_add
    spatialCoefficientDf['bare2015_MV'] = spatialCoefficientDf.bare2015_coef/spatialCoefficientDf.di_inc_gdp_coef_add
    return spatialCoefficientDf


### run
REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('mac')
X = pd.read_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv", index_col=0)
y = pd.read_csv(REPO_LOCATION + "02_Data/97_y_toGPU.csv", index_col=0)
model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                               random_state=1, max_features = 9, n_jobs=-1, 
                               min_samples_split = 2)
model.fit(X, y)

X_split_array, Y_split_array = XYSplit(model)
leftRightBoundary = findBoundaryArray(X_split_array, X.iloc[:,47])
upDownBoundary = findBoundaryArray(Y_split_array, X.iloc[:,48])
neighborList = buildNeighborList(X, leftRightBoundary, upDownBoundary)
result = getMergeSHAPresult()
spatialCoefficientDf = obtainSpatialCoefficientDf(result, neighborList)
spatialCoefficientDfWithMv = calculateMonetaryValue(spatialCoefficientDf)

dump(spatialCoefficientDfWithMv, REPO_RESULT_LOCATION + "spatialCoefficientDfWithMv.joblib")


"""
# mac
REPO_LOCATION = "/Users/lichao/Library/CloudStorage/OneDrive-KyushuUniversity/02_Article/03_RStudio/"
REPO_RESULT_LOCATION = "/Users/lichao/Library/CloudStorage/OneDrive-KyushuUniversity/02_Article/03_RStudio/08_PyResults/"

"""
