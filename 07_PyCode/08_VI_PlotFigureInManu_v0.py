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
    plt.rcParams["figure.dpi"] = 1000
    ax = X.plot.bar(stacked=True, figsize=(21, 14), color = px.colors.qualitative.Alphabet)
    #ax.bar(X.index, X['Japan'], label='Japan', bottom=X['Australia'])
    ax.grid(True)
    ax.set_ylabel("Counts", fontsize=25)
    ax.legend(fontsize=20, ncol=3)
    ax.set_xlabel("Mental Health Score (GHQ-12)", fontsize=25)
    ax.tick_params(axis='both', which='major', labelsize=20)
    plt.savefig(DP02_FIGURE_LOCATION + figure_name)
    

y, y_pred = getYandY_pred()    
drawYandY_pred(y, y_pred, "y_yhat.jpg")

X = getYwithCountry()
drawGhqHist(X, "GHQhist.jpg")
