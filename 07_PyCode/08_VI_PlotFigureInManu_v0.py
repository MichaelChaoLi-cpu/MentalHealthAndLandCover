# -*- coding: utf-8 -*-
"""
Created on Tue Nov 15 12:50:06 2022

@author: li.chao.987@s.kyushu-u.ac.jp
"""

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import mpl_scatter_density # adds projection='scatter_density'
import matplotlib.colors
import matplotlib as mpl
import plotly.express as px
import pyreadr
from sklearn.inspection import permutation_importance
### Note: permutation_importance is more suitbale to analysis, rather than 
###       model.feature_importance .

DP02_FIGURE_LOCATION = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/05_Figure/"
CMAP = matplotlib.colors.LinearSegmentedColormap.from_list("", ["blue","green","yellow","red"])

def getYandY_pred():
    DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
    ### X and y
    dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
    dataset = dataset[None]
    X = np.array(dataset.iloc[:, 1:50], dtype='float64')
    y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')

    model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                                   random_state=1, max_features = 9, n_jobs=-1)
    model.fit(X, y)
    y_pred = model.predict(X)
    return y, y_pred

def drawYandY_pred(y, y_pred, figure_name):
    # figure total fitting model
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(20, 21), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.5]})
    
    xedges, yedges = np.linspace(0, 36, 37), np.linspace(0, 36, 181)
    hist, xedges, yedges = np.histogram2d(y, y_pred, (xedges, yedges))
    
    xidx = np.clip(np.digitize(y, xedges), 0, hist.shape[0] - 1)
    yidx = np.clip(np.digitize(y_pred, yedges), 0, hist.shape[1] - 1)
    c = hist[xidx, yidx]
    c[c > 500] = 500
    
    reg = LinearRegression().fit(pd.DataFrame(y), y_pred)
    
    axs[0].scatter(y, y_pred, c=c, cmap=CMAP)
    axs[0].axline((0, 0), (36, 36), linewidth=6, color='r', alpha=0.4, linestyle='--',
                    label='y = x')
    axs[0].axline((0, reg.intercept_), (36, (reg.intercept_ + 36 * reg.coef_[0])), 
                    linewidth=6, color='blue', alpha=0.4, linestyle='-',
                    label='y = ' + str(round(reg.coef_[0], 2))+"x + " + str(round(reg.intercept_, 2)))
    axs[0].grid(True)
    axs[0].legend(fontsize=25)
    axs[0].text(27, 7.2, "N = 89,273", fontsize=25)
    axs[0].text(27, 6, "$R^2$ = 93.09%", fontsize=25)
    axs[0].text(27, 4.8, "RMSE = 1.66", fontsize=25)
    axs[0].text(27, 3.6, "MSE = 2.74", fontsize=25)
    axs[0].text(27, 2.4, "MAE = 3.64", fontsize=25)
    axs[0].text(27, 1.2, "OOB Score = 49.05%", fontsize=25)
    axs[0].text(27, 0, "CV Score = 41.24%", fontsize=25)
    axs[0].set_xlabel("the Observed Mental Health Score", fontsize=25)
    axs[0].set_ylabel("the Predicted Mental Health Score", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    #axs[0,0].set_xlim([0, 10])
    #axs[0,0].set_ylim([0, 10])
    
    norm = mpl.colors.Normalize(vmin=0, vmax=500)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Density',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)
    
def getYwithCountry():
    DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
    ### X and y
    dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_with_country.Rds")
    dataset = dataset[None]
    X = dataset[['GHQ12', 'country']]
    X = X.groupby(['country'])['GHQ12'].value_counts().unstack("country",
                                                               fill_value=0)
    return X

def drawGhqHist(X, figure_name):
    color_array = [
        '#2E91E5', '#E15F99', '#1CA71C', '#FB0D0D', '#DA16FF', '#222A2A',
        '#B68100', '#750D86', '#EB663B', '#511CFB', '#00A08B', '#FB00D1',
        '#FC0080', '#B2828D', '#6C7C32', '#778AAE', '#862A16', '#A777F1',
        '#620042', '#1616A7', '#DA60CA', '#6C4516', '#0D2A63', '#AF0038',
        '#FD3216', '#00FE35', '#6A76FC', '#FED4C4', '#FE00CE', '#0DF9FF',
        '#F6F926', '#FF9616', '#479B55', '#EEA6FB', '#DC587D', '#D626FF',
        '#6E899C'
        ]
    plt.rcParams["figure.dpi"] = 1000
    ax = X.plot.bar(stacked=True, figsize=(21, 14), color = color_array)
    #ax.bar(X.index, X['Japan'], label='Japan', bottom=X['Australia'])
    ax.grid(True)
    ax.set_ylabel("Counts", fontsize=25)
    ax.text(25, 9600, "N = 89,273", fontsize=25)
    ax.text(25, 9200, "Mean = 24.3185", fontsize=25)
    ax.text(25, 8800, "Standard Deviation = 6.301", fontsize=25)
    ax.text(25, 8400, "Median = 25", fontsize=25)
    ax.legend(fontsize=20, ncol=3)
    ax.set_xlabel("Mental Health Score (GHQ-12)", fontsize=25)
    ax.tick_params(axis='both', which='major', labelsize=20)
    plt.savefig(DP02_FIGURE_LOCATION + figure_name)

def getIncWithCountry():
    DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
    ### X and y
    dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_with_country.Rds")
    dataset = dataset[None]
    X = dataset[['di_inc_gdp', 'country']]
    X['di_inc_gdp'] = round(X['di_inc_gdp'], 1)
    X = X.groupby(['country'])['di_inc_gdp'].value_counts().unstack("country",
                                                               fill_value=0)
    return X

def drawDigHist(X, figure_name):
    color_array = [
        '#2E91E5', '#E15F99', '#1CA71C', '#FB0D0D', '#DA16FF', '#222A2A',
        '#B68100', '#750D86', '#EB663B', '#511CFB', '#00A08B', '#FB00D1',
        '#FC0080', '#B2828D', '#6C7C32', '#778AAE', '#862A16', '#A777F1',
        '#620042', '#1616A7', '#DA60CA', '#6C4516', '#0D2A63', '#AF0038',
        '#FD3216', '#00FE35', '#6A76FC', '#FED4C4', '#FE00CE', '#0DF9FF',
        '#F6F926', '#FF9616', '#479B55', '#EEA6FB', '#DC587D', '#D626FF',
        '#6E899C'
        ]
    plt.rcParams["figure.dpi"] = 1000
    ax = X.plot.bar(stacked=True, figsize=(21, 14), color = color_array)
    #ax.bar(X.index, X['Japan'], label='Japan', bottom=X['Australia'])
    ax.grid(True)
    ax.set_ylabel("Counts", fontsize=25)
    ax.text(25, 5200, "N = 89,273", fontsize=25)
    ax.text(25, 4800, "Mean = -0.3165", fontsize=25)
    ax.text(25, 4400, "Standard Deviation = 0.7195", fontsize=25)
    ax.text(25, 4000, "Median = -0.5299", fontsize=25)
    ax.legend(fontsize=20, ncol=3)
    ax.set_xlabel("DIG", fontsize=25)
    ax.tick_params(axis='both', which='major', labelsize=20)
    plt.savefig(DP02_FIGURE_LOCATION + figure_name)

def getImportance():
    DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
    dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
    dataset = dataset[None]
    y = np.array(dataset.iloc[:, 0:1].values.flatten(), dtype='float64')
    X = np.array(dataset.iloc[:, 1:50], dtype='float64')
    model = RandomForestRegressor(n_estimators=1000, oob_score=True, 
                                   random_state=1, max_features = 9, n_jobs=-1)
    model.fit(X, y)
    result = permutation_importance(model, X, y, n_repeats=10, random_state=1)
    return result

def drawImportanceBar(X, figure_name):
    fig, axs = plt.subplots(figsize=(30, 20), dpi=1000)
    feature_name = ["DIG", "Social Class", "Student", "Worker", "Company Owner", 
                    "Government Officer", "Self-Employed", "Professional Job",
                    "Housewife", "Unemployed", "Pleasure", "Anger", "Sadness", 
                    "Enjoyment", "Smile", "Enthusiastic", "Critical", "Dependable",
                    "Anxious", "Open to New Experience", "Reserved", "Sympathetic",
                    "Careless", "Calm", "Uncreative", "Urban Center Dummy", 
                    "Urban Area Dummy", "Rural Area Dummy", "Income Group", 
                    "Female", "Age", "Self-reported Health", "Bachelor",
                    "Master", "PhD", "Community Livable", "Community Attachment",
                    "Community Safety", "Children Number", "Cropland (%)", "Forest (%)",
                    "Grassland (%)", "Shrubland (%)", "Wetland (%)", "Water (%)", 
                    "Urban Land (%)", "Bare Land (%)", "Longitude", "Latitude"]
    y_pos = np.arange(len(feature_name))
    axs.barh(y_pos, X, align='center')
    axs.set_yticks(y_pos, labels=feature_name)
    axs.invert_yaxis() 
    axs.set_xlabel('Gini Importance', fontsize=25)
    axs.set_title('Feuture Importance', fontsize=25)
    axs.grid(True)
    axs.tick_params(axis='both', which='major', labelsize=20)
    axs.set_ylim([49, -1])
    plt.savefig(DP02_FIGURE_LOCATION + figure_name)
    

y, y_pred = getYandY_pred()    
drawYandY_pred(y, y_pred, "y_yhat.jpg")

X = getYwithCountry()
drawGhqHist(X, "GHQhist.jpg")

X = getIncWithCountry()
drawDigHist(X, "DIGhist.jpg")

featureImportance = getImportance()
drawImportanceBar(featureImportance, "FeatureImportance.jpg")
