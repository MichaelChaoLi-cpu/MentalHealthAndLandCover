#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Dec 30 16:12:05 2023

@author: lichao
"""

import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor, AdaBoostRegressor, GradientBoostingRegressor
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.metrics import make_scorer, r2_score, mean_absolute_error, accuracy_score, mean_squared_error
from sklearn.model_selection import train_test_split, GridSearchCV, cross_val_score, KFold
from sklearn.svm import SVR
import tensorflow as tf
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

def getYandY():
    X = pd.read_csv(REPO_LOCATION + "02_Data/98_X_toGPU.csv", index_col=0)
    y = pd.read_csv(REPO_LOCATION + "02_Data/97_y_toGPU.csv", index_col=0)
    np.random.seed(42)
    random_order = np.random.permutation(len(X))
    X = X.iloc[random_order].reset_index(drop=True)
    y = y.iloc[random_order].reset_index(drop=True)
    return X, y

REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('mac')
X, y = getYandY()

scorer = make_scorer(r2_score)

ols_model = LinearRegression()
cv_scores_ols = cross_val_score(ols_model, X, y, cv=10, 
                                scoring=scorer, n_jobs=10)
print(cv_scores_ols.mean())
cv_scores_ols_MSE = cross_val_score(ols_model, X, y, cv=10, 
                                    scoring='neg_mean_squared_error', n_jobs=10)
print(np.sqrt(-cv_scores_ols_MSE.mean()))
print(-cv_scores_ols_MSE.mean())
cv_scores_ols_MAE = cross_val_score(ols_model, X, y, cv=10, 
                                    scoring='neg_mean_absolute_error', n_jobs=10)
print(-cv_scores_ols_MAE.mean())
# 0.4255168421291932
# 4.775381783484226
# 22.80427117803299
# 3.6475595704801846

olr = LogisticRegression()
cv_scores_olr = cross_val_score(olr, X, y, cv=10, scoring=make_scorer(accuracy_score),
                                n_jobs=10)
print(cv_scores_olr.mean())
# 0.13431837910282243

svr = SVR()
cv_scores_svr = cross_val_score(svr, X, y, cv=10, scoring=scorer, n_jobs=10)
print(cv_scores_svr.mean())
cv_scores_svr_MSE = cross_val_score(svr, X, y, cv=10, 
                                    scoring='neg_mean_squared_error', n_jobs=10)
print(np.sqrt(-cv_scores_svr_MSE.mean()))
print(-cv_scores_svr_MSE.mean())
cv_scores_svr_MAE = cross_val_score(svr, X, y, cv=10, 
                                    scoring='neg_mean_absolute_error', n_jobs=10)
print(-cv_scores_svr_MAE.mean())
# 0.3340057449430974
# 5.141995562914045
# 26.440118369027722
# 3.810401577824988

random_forest = RandomForestRegressor(random_state=42, n_jobs=-1)
cv_scores_rf = cross_val_score(random_forest, X, y, cv=10, scoring=scorer, n_jobs=10)
print(cv_scores_rf.mean())
cv_scores_rf_MSE = cross_val_score(random_forest, X, y, cv=10, 
                                    scoring='neg_mean_squared_error', n_jobs=10)
print(np.sqrt(-cv_scores_rf_MSE.mean()))
print(-cv_scores_rf_MSE.mean())
cv_scores_rf_MAE = cross_val_score(random_forest, X, y, cv=10, 
                                    scoring='neg_mean_absolute_error', n_jobs=10)
print(-cv_scores_rf_MAE.mean())
# 0.47343789517598933
# 4.571793883056028
# 20.90129930914851
# 3.4184587923664838

adaboost = AdaBoostRegressor(random_state=42)
cv_scores_ada = cross_val_score(adaboost, X, y, cv=10, scoring=scorer, n_jobs=10)
print(cv_scores_ada.mean())
cv_scores_ada_MSE = cross_val_score(adaboost, X, y, cv=10, 
                                    scoring='neg_mean_squared_error', n_jobs=10)
print(np.sqrt(-cv_scores_ada_MSE.mean()))
print(-cv_scores_ada_MSE.mean())
cv_scores_ada_MAE = cross_val_score(adaboost, X, y, cv=10, 
                                    scoring='neg_mean_absolute_error', n_jobs=10)
print(-cv_scores_ada_MAE.mean())
# 0.2261887025356172
# 5.541454776761121
# 30.707721042888643
# 4.517704696350529


xgboost = xgb.XGBRegressor(random_state=42, n_jobs=-1, max_depth=3)
cv_scores_xgb = cross_val_score(xgboost, X, y, cv=10, scoring=scorer)
print(cv_scores_xgb.mean())
cv_scores_xgb_MSE = cross_val_score(xgboost, X, y, cv=10, 
                                    scoring='neg_mean_squared_error', n_jobs=10)
print(np.sqrt(-cv_scores_xgb_MSE.mean()))
print(-cv_scores_xgb_MSE.mean())
cv_scores_xgb_MAE = cross_val_score(xgboost, X, y, cv=10, 
                                    scoring='neg_mean_absolute_error', n_jobs=10)
print(-cv_scores_xgb_MAE.mean())
# 0.47186328104127123
# 4.578649272540115
# 20.964029160932128
# 3.4722085096199407

gbm = GradientBoostingRegressor(random_state=42)
cv_scores_gbm = cross_val_score(gbm, X, y, cv=10, scoring=scorer, n_jobs=10)
print(cv_scores_gbm.mean())
cv_scores_gbm_MSE = cross_val_score(gbm, X, y, cv=10, 
                                    scoring='neg_mean_squared_error', n_jobs=10)
print(np.sqrt(-cv_scores_gbm_MSE.mean()))
print(-cv_scores_gbm_MSE.mean())
cv_scores_gbm_MAE = cross_val_score(gbm, X, y, cv=10, 
                                    scoring='neg_mean_absolute_error', n_jobs=10)
print(-cv_scores_gbm_MAE.mean())
# 0.46006348346149695
# 4.629579845362364
# 21.43300954458541
# 3.513122135258871

n_splits = 10
kf = KFold(n_splits=n_splits)
r2_scores = []
RMSEs = []
MSEs = []
MAEs = []
X_np = X.values
y_np = y.values


for train_index, val_index in kf.split(X):
    # Split data
    X_train, X_val = X_np[train_index], X_np[val_index]
    y_train, y_val = y_np[train_index], y_np[val_index]

    model = tf.keras.Sequential()
    model.add(tf.keras.layers.Dense(100, activation='relu', input_shape=(49,)))  # Replace 'input_dim' with your input dimension
    for _ in range(20):
        model.add(tf.keras.layers.Dense(100, activation='relu'))
    
    model.add(tf.keras.layers.Dense(1))
    model.compile(optimizer='adam', loss='mean_squared_error')
    #model.summary()
    # Train the model
    model.fit(X_train, y_train, epochs=20, batch_size=32, verbose=0)  # Adjust epochs, batch_size, etc.

    # Evaluate the model
    eval_result = model.evaluate(X_val, y_val, verbose=0)
    
    y_pred = model.predict(X_val)
    r2 = r2_score(y_val, y_pred)
    print(r2)
    r2_scores.append(r2)
    
    mse = mean_squared_error(y_val, y_pred)
    print(mse)
    MSEs.append(mse)
    print(np.sqrt(mse))
    RMSEs.append(np.sqrt(mse))
    
    mae = mean_absolute_error(y_val, y_pred)
    MAEs.append(mae)

# Calculate average performance across all folds
average_performance = np.mean(r2_scores)
print("Average Evaluation Result:", average_performance)
average_performance = np.mean(RMSEs)
print("Average Evaluation Result:", average_performance)
average_performance = np.mean(MSEs)
print("Average Evaluation Result:", average_performance)
average_performance = np.mean(MAEs)
print("Average Evaluation Result:", average_performance)
# 0.4466676421857917
# 4.647941322476541
# 21.60535658150891
# 3.554596498789766




