# -*- coding: utf-8 -*-
"""
Created on Tue Jan 10 14:02:23 2023

@author: li.chao.987@s.kyushu-u.ac.jp

NOTE: 
    GLOBAL_VARIABLE
    local_variable
    functionToRun
    Function_Input_Or_Ouput_Variable
"""

import os
import pandas as pd
import numpy as np
import geopandas as gpd

from joblib import dump, load
import pyreadr

import matplotlib as mpl
import matplotlib.colors
import matplotlib.pyplot as plt

DP02_FIGURE_LOCATION = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/05_Figure/"
CMAP = matplotlib.colors.LinearSegmentedColormap.from_list("", ["blue","green","yellow","red"])

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

def makeSpatialStatusDf():
    dataset = pd.read_csv(REPO_RESULT_LOCATION + "mergedXSHAP.csv", index_col=0)
    datasetLocation = dataset[['crop2015', 'fore2015', 'gras2015', 'shru2015', 
                               'wetl2015', 'wate2015', 'impe2015', 'bare2015',
                               'di_inc_gdp', 'X', 'Y']] 
    return datasetLocation

def changeIncomeScale(ShapGridDf):
    ShapGridDf['di_inc_gdp'] = ShapGridDf['di_inc_gdp'] * 100
    return ShapGridDf

def drawCurrentStatus(X, figure_name, variable_name, vmin, vmax):
    X = X[[variable_name, 'X', 'Y']]
    #XMvOver0 = X[X[variable_name]!=0]
    XMvOver0 = X
    XMvOver0Ave = pd.DataFrame(XMvOver0.groupby(['X', 'Y'])[variable_name].mean())
    XMvOver0Ave.reset_index(inplace=True)
    print(XMvOver0Ave.describe())
    XMvOver0Ave.loc[XMvOver0Ave[variable_name] > vmax, variable_name] = vmax
    XMvOver0Ave.loc[XMvOver0Ave[variable_name] < vmin, variable_name] = vmin
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].scatter(XMvOver0Ave.X, XMvOver0Ave.Y, c = XMvOver0Ave[variable_name], 
                   cmap = CMAP, s = 30, alpha = 0.3, marker = '.', 
                   linewidths=0, vmin = vmin, vmax = vmax)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin=vmin, vmax=vmax)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Spatially Average Current Status (%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(REPO_LOCATION + '05_Figure/' + figure_name)
    return None

def makeShapValueDf():
    dataset = pd.read_csv(REPO_RESULT_LOCATION + "mergedXSHAP.csv", index_col=0)
    datasetLocation = dataset[['crop2015', 'fore2015', 'gras2015', 'shru2015', 
                               'wetl2015', 'wate2015', 'impe2015', 'bare2015',
                               'di_inc_gdp', 'crop2015_shap', 'fore2015_shap',
                               'gras2015_shap', 'shru2015_shap', 'wetl2015_shap', 'wate2015_shap',
                               'impe2015_shap', 'bare2015_shap', 'di_inc_gdp_shap']] 
    return datasetLocation

def run():    
    DfWithLocation = makeSpatialStatusDf()
    DfWithLocation = changeIncomeScale(DfWithLocation)
    drawCurrentStatus(DfWithLocation, "Status_Cropland.jpg", 'crop2015', 0, 25)
    drawCurrentStatus(DfWithLocation, "Status_Forest.jpg", 'fore2015', 0, 25)
    drawCurrentStatus(DfWithLocation, "Status_Grassland.jpg", 'gras2015', 0, 35)
    drawCurrentStatus(DfWithLocation, "Status_Shrubland.jpg", 'shru2015', 0, 2)
    drawCurrentStatus(DfWithLocation, "Status_Water.jpg", 'wate2015', 0, 10)
    drawCurrentStatus(DfWithLocation, "Status_Wetland.jpg", 'wetl2015', 0, 0.1)
    drawCurrentStatus(DfWithLocation, "Status_Urban.jpg", 'impe2015', 0, 80)
    drawCurrentStatus(DfWithLocation, "Status_Bareland.jpg", 'bare2015', 0, 5)
    drawCurrentStatus(DfWithLocation, "Status_Income.jpg", 'di_inc_gdp', 0, 75)
    return None

def runScatterPlot():
    df = makeShapValueDf()
    variables = ['Cropland', 'Forest', 'Grassland', 'Shrubland',
                 'Wetland', 'Water', 'Urban Land', 'Bare Land',
                 'RI']
    indices = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i']
    fig, axes = plt.subplots(3, 3, figsize=(15, 15), dpi=1000)
    for i, ax in enumerate(axes.ravel()):
        ax.scatter(df.iloc[:,i], df.iloc[:,i+9], alpha=0.2)
        ax.set_ylabel("SHAP" + variables[i])
        ax.set_xlabel(variables[i])
        
        x = df.iloc[:, i]
        y = df.iloc[:, i+9]
        m, b = np.polyfit(df.iloc[:,i], df.iloc[:,i+9], 1)
        ax.plot(x, m*x + b, color='orange')
        
        ax.axhline(0, color='red', linestyle='--', linewidth=0.8)
        
        ax.text(0.05, 0.95, indices[i], transform=ax.transAxes, 
                fontweight='bold', va='top', fontsize=20)
        if i == 0:
            ax.set_ylim([-0.3, 0.3])
        if i == 1:
            ax.set_ylim([-0.3, 0.3])
        if i == 2:
            ax.set_ylim([-0.5, 0.5])
        if i == 3:
            ax.set_ylim([-0.5, 0.5])
        if i == 4:
            ax.set_xlim([0, 15])
        if i == 6:
            ax.set_ylim([-0.2, 0.2])
    plt.tight_layout()
    fig.savefig(REPO_LOCATION + '05_Figure/' + '98_shap_value.jpg')
    plt.show()
    
    

if __name__ == '__main__':
    REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('mac')
    WORLD_MAP = gpd.read_file(REPO_LOCATION + "02_Data/country.shp")
    #run()