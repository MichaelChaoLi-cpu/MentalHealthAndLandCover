#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Jan  9 14:32:14 2023

@author: lichao

NOTE: 
    GLOBAL_VARIABLE
    local_variable
    functionToRun
    Function_Input_Or_Ouput_Variable
"""

import pandas as pd
import numpy as np

from joblib import load
import math

import pyreadr

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

def calculateOneHmLandCover(spatialCoefficientDfWithMvGw):
    spatialCoefficientDfWithMvGw['crop2015_MV'] = spatialCoefficientDfWithMvGw['crop2015_MV'] / (5*5*math.pi*100)
    spatialCoefficientDfWithMvGw['fore2015_MV'] = spatialCoefficientDfWithMvGw['fore2015_MV'] / (5*5*math.pi*100)
    spatialCoefficientDfWithMvGw['gras2015_MV'] = spatialCoefficientDfWithMvGw['gras2015_MV'] / (5*5*math.pi*100)
    spatialCoefficientDfWithMvGw['shru2015_MV'] = spatialCoefficientDfWithMvGw['shru2015_MV'] / (5*5*math.pi*100)
    spatialCoefficientDfWithMvGw['wetl2015_MV'] = spatialCoefficientDfWithMvGw['wetl2015_MV'] / (5*5*math.pi*100)
    spatialCoefficientDfWithMvGw['wate2015_MV'] = spatialCoefficientDfWithMvGw['wate2015_MV'] / (5*5*math.pi*100)
    spatialCoefficientDfWithMvGw['impe2015_MV'] = spatialCoefficientDfWithMvGw['impe2015_MV'] / (5*5*math.pi*100)
    spatialCoefficientDfWithMvGw['bare2015_MV'] = spatialCoefficientDfWithMvGw['bare2015_MV'] / (5*5*math.pi*100)
    return spatialCoefficientDfWithMvGw
    
def makeRawDataset():
    dataset = pyreadr.read_r(REPO_LOCATION + "02_Data/SP_Data_49Variable_counRdsVer.Rds")
    dataset = dataset[None]
    X = dataset.iloc[:, 1:2]
    X['average_inc'] = 0
    X['country'] = X['country'].astype(int)
    X.loc[X['country'] == 1, 'average_inc'] = 34296.76182
    X.loc[X['country'] == 2, 'average_inc'] = 5840.04368088199
    X.loc[X['country'] == 3, 'average_inc'] = 9955.24303866936
    X.loc[X['country'] == 4, 'average_inc'] = 3331.695118502
    X.loc[X['country'] == 5, 'average_inc'] = 55076.9266052493
    X.loc[X['country'] == 6, 'average_inc'] = 2085.10163774086
    X.loc[X['country'] == 7, 'average_inc'] = 2867.14947345595
    X.loc[X['country'] == 8, 'average_inc'] = 9605.97255503339
    X.loc[X['country'] == 9, 'average_inc'] = 11439.1968408022
    X.loc[X['country'] == 10, 'average_inc'] = 13574.1718307245
    X.loc[X['country'] == 11, 'average_inc'] = 8813.98937549952
    X.loc[X['country'] == 12, 'average_inc'] = 6175.87613151291
    X.loc[X['country'] == 13, 'average_inc'] = 5730.93445218042
    X.loc[X['country'] == 14, 'average_inc'] = 1638.55640239958
    X.loc[X['country'] == 15, 'average_inc'] = 1211.73669552402
    X.loc[X['country'] == 16, 'average_inc'] = 10493.2982321916
    X.loc[X['country'] == 17, 'average_inc'] = 3918.58167706494
    X.loc[X['country'] == 18, 'average_inc'] = 3437.21122973619
    X.loc[X['country'] == 19, 'average_inc'] = 9424.48853257256
    X.loc[X['country'] == 20, 'average_inc'] = 7862.66457482127
    X.loc[X['country'] == 21, 'average_inc'] = 52131.3818041621
    X.loc[X['country'] == 22, 'average_inc'] = 56838.6844221412
    X.loc[X['country'] == 23, 'average_inc'] = 41036.0917784737
    X.loc[X['country'] == 24, 'average_inc'] = 44530.4927178004
    X.loc[X['country'] == 25, 'average_inc'] = 36611.7539123875
    X.loc[X['country'] == 26, 'average_inc'] = 25606.8127544494
    X.loc[X['country'] == 27, 'average_inc'] = 30306.1221251231
    X.loc[X['country'] == 28, 'average_inc'] = 51726.2025253337
    X.loc[X['country'] == 29, 'average_inc'] = 43193.7918063055
    X.loc[X['country'] == 30, 'average_inc'] = 45179.0297228225
    X.loc[X['country'] == 31, 'average_inc'] = 18322.9447129746
    X.loc[X['country'] == 32, 'average_inc'] = 11006.2455757441
    X.loc[X['country'] == 33, 'average_inc'] = 12791.4983602489
    X.loc[X['country'] == 34, 'average_inc'] = 12562.731212555
    X.loc[X['country'] == 35, 'average_inc'] = 17736.6294706142
    X.loc[X['country'] == 36, 'average_inc'] = 8928.14904659118
    X.loc[X['country'] == 37, 'average_inc'] = 3855.1737357991
    return X

def calculateOneHmLandCoverUsd(spatialCoefficientDfWithMvGw, Inc_Data):
    spatialCoefficientDfWithMvGw['ave_inc'] = Inc_Data['average_inc']
    spatialCoefficientDfWithMvGw['crop2015_MV'] = spatialCoefficientDfWithMvGw['crop2015_MV'] * spatialCoefficientDfWithMvGw['ave_inc']
    spatialCoefficientDfWithMvGw['fore2015_MV'] = spatialCoefficientDfWithMvGw['fore2015_MV'] * spatialCoefficientDfWithMvGw['ave_inc']
    spatialCoefficientDfWithMvGw['gras2015_MV'] = spatialCoefficientDfWithMvGw['gras2015_MV'] * spatialCoefficientDfWithMvGw['ave_inc']
    spatialCoefficientDfWithMvGw['shru2015_MV'] = spatialCoefficientDfWithMvGw['shru2015_MV'] * spatialCoefficientDfWithMvGw['ave_inc']
    spatialCoefficientDfWithMvGw['wetl2015_MV'] = spatialCoefficientDfWithMvGw['wetl2015_MV'] * spatialCoefficientDfWithMvGw['ave_inc']
    spatialCoefficientDfWithMvGw['wate2015_MV'] = spatialCoefficientDfWithMvGw['wate2015_MV'] * spatialCoefficientDfWithMvGw['ave_inc']
    spatialCoefficientDfWithMvGw['impe2015_MV'] = spatialCoefficientDfWithMvGw['impe2015_MV'] * spatialCoefficientDfWithMvGw['ave_inc']
    spatialCoefficientDfWithMvGw['bare2015_MV'] = spatialCoefficientDfWithMvGw['bare2015_MV'] * spatialCoefficientDfWithMvGw['ave_inc']
    return spatialCoefficientDfWithMvGw


REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('mac')
spatialCoefficientDfWithMvGw = pd.read_csv(REPO_RESULT_LOCATION + 
                                           "09_spatialCoefficientDfWithMvGw.csv", 
                                           index_col=0)
MvGw1hm = calculateOneHmLandCover(spatialCoefficientDfWithMvGw)
Inc_Data = makeRawDataset()
MvGw1hmUsd = calculateOneHmLandCoverUsd(spatialCoefficientDfWithMvGw, Inc_Data)
Describe_Result = MvGw1hmUsd.iloc[:,36:45].describe()
MvGw1hmUsd.to_csv(REPO_RESULT_LOCATION + "10_MvGw1hmUsd.csv")
