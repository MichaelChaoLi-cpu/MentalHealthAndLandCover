#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Sep 29 10:08:48 2023

@author: lichao
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor, AdaBoostRegressor, GradientBoostingRegressor
from sklearn.metrics import make_scorer, r2_score, mean_absolute_error
from sklearn.model_selection import train_test_split, GridSearchCV
import xgboost as xgb


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

def getYandYTrainTest():
    X = pd.read_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv", index_col=0)
    y = pd.read_csv(REPO_LOCATION + "02_Data/97_y_toGPU.csv", index_col=0)
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1,
                                                        random_state=42)
    return X_train, X_test, y_train, y_test

def getYandY():
    X = pd.read_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv", index_col=0)
    y = pd.read_csv(REPO_LOCATION + "02_Data/97_y_toGPU.csv", index_col=0)
    return X, y

REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('y')

X_train, X_test, y_train, y_test = getYandYTrainTest()

random_forest = RandomForestRegressor( random_state=42, n_jobs=-1)
adaboost = AdaBoostRegressor(random_state=42)
xgboost = xgb.XGBRegressor(random_state=42, n_jobs=-1)
gbm = GradientBoostingRegressor(random_state=42)

models = [random_forest, adaboost, xgboost, gbm]

r2_list = []
for model in models:
    model_name = model.__class__.__name__
    model.fit(X_train, y_train)
    predictions = model.predict(X_test)
    r2 = r2_score(y_test, predictions)
    
    r2_list.append(r2_list)
    print(f"{model_name} - R-squared: {r2}")


### parameter selection
X, y = getYandY()

### tree number
model = RandomForestRegressor(random_state=42,
                              n_jobs=-1, oob_score=True)
param_grid = {
    'n_estimators': [50, 100, 200, 300, 400, 500,
                     1000]
}
scorer = make_scorer(r2_score)
grid_search_n_estimators = GridSearchCV(estimator=model, param_grid=param_grid, 
                                        scoring=scorer, cv=10, verbose=2)
grid_search_n_estimators.fit(X, y)
print(grid_search_n_estimators.cv_results_)
best_params = grid_search_n_estimators.best_params_
best_score = grid_search_n_estimators.best_score_

print("Best Parameters:", best_params)
print("Best R2 Score:", best_score)


### max_features
model = RandomForestRegressor(n_estimators=1000, random_state=42, 
                              n_jobs=-1, oob_score=True)
param_grid = {
    'max_features': list(range(1,50))
}
scorer = make_scorer(r2_score)
grid_search_max_features = GridSearchCV(estimator=model, param_grid=param_grid, 
                                        scoring=scorer, cv=10, verbose=2)
grid_search_max_features.fit(X, y)
print(grid_search_max_features.cv_results_)
best_params = grid_search_max_features.best_params_
best_score = grid_search_max_features.best_score_

print("Best Parameters:", best_params)
print("Best R2 Score:", best_score)

### min_samples_split
model = RandomForestRegressor(n_estimators=1000, random_state=42, 
                              n_jobs=-1, oob_score=True, max_features=11)
param_grid = {
    'min_samples_split': [2, 5, 10, 15, 20,
                          25, 30, 35, 40]
}
scorer = make_scorer(r2_score)
grid_search_min_samples_split = GridSearchCV(estimator=model, param_grid=param_grid, 
                                        scoring=scorer, cv=10, verbose=2)
grid_search_min_samples_split.fit(X, y)
print(grid_search_min_samples_split.cv_results_)
best_params = grid_search_min_samples_split.best_params_
best_score = grid_search_min_samples_split.best_score_

print("Best Parameters:", best_params)
print("Best R2 Score:", best_score)

parameters_list = [50, 100, 200, 300, 400, 500,
                   1000] + list(range(1,50)) + [2, 5, 10, 15, 20,
                                                25, 30, 35, 40]
parameter_r2 = np.concatenate([
    grid_search_n_estimators.cv_results_['mean_test_score'],
    grid_search_max_features.cv_results_['mean_test_score'],
    grid_search_min_samples_split.cv_results_['mean_test_score']
])

parameter_df = pd.DataFrame([parameters_list, parameter_r2.tolist()], 
                            columns=['potential_para','r2_score'])
parameter_df.to_csv(REPO_RESULT_LOCATION + "99_parameter_r2_cv10.csv")
