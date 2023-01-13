# -*- coding: utf-8 -*-
"""
Created on Wed Jan 11 11:39:27 2023

@author: li.chao.987@s.kyushu-u.ac.jp

NOTE: 
    GLOBAL_VARIABLE
    local_variable
    functionToRun
    Function_Input_Or_Ouput_Variable
"""

from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score
from sklearn.metrics import mean_squared_error
from sklearn.metrics import mean_absolute_error
from math import sqrt
from sklearn.model_selection import cross_val_score

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

def getYandY_pred():
    X = pd.read_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv", index_col=0)
    y = pd.read_csv(REPO_LOCATION + "02_Data/97_y_toGPU.csv", index_col=0)

    model = LinearRegression()
    model.fit(X, y)
    y_pred = model.predict(X)
    return y, y_pred

def getOls10FoldCv():
    X = pd.read_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv", index_col=0)
    y = pd.read_csv(REPO_LOCATION + "02_Data/97_y_toGPU.csv", index_col=0)
    model = LinearRegression()
    scores = cross_val_score(model, X, y, cv=10)
    return scores.mean()
    

REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('y')
y, y_pred = getYandY_pred()  
r2_score(y, y_pred)  
mean_squared_error(y, y_pred)
sqrt(mean_squared_error(y, y_pred))
mean_absolute_error(y, y_pred)
getOls10FoldCv()
