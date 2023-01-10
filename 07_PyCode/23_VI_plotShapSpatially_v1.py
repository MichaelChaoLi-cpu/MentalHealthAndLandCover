# -*- coding: utf-8 -*-
"""
Created on Tue Jan 10 14:52:18 2023

@author: li.chao.987@s.kyushu-u.ac.jp
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

def makeSpatialShapDf():
    shap_df = pd.read_csv(REPO_RESULT_LOCATION + "mergedXSHAP.csv", index_col=0)
    shap_df = shap_df[[
        'di_inc_gdp_shap', 'crop2015_shap', 'fore2015_shap',
        'gras2015_shap', 'shru2015_shap', 'wetl2015_shap', 'wate2015_shap',
        'impe2015_shap', 'bare2015_shap', 'X', 'Y'
        ]]
    return shap_df

def drawShap(X, figure_name, variable_name, vmin, vmax):
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
    cbar.set_label('SHAP Value',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)
    return None

def run():    
    DfWithLocation = makeSpatialShapDf()
    drawShap(DfWithLocation, "SHAP_Cropland.jpg", 'crop2015_shap', -0.03, 0.03)
    drawShap(DfWithLocation, "SHAP_Forest.jpg", 'fore2015_shap', -0.02, 0.02)
    drawShap(DfWithLocation, "SHAP_Grassland.jpg", 'gras2015_shap', -0.05, 0.05)
    drawShap(DfWithLocation, "SHAP_Shrubland.jpg", 'shru2015_shap', -0.05, 0.05)
    drawShap(DfWithLocation, "SHAP_Water.jpg", 'wate2015_shap', -0.03, 0.03)
    drawShap(DfWithLocation, "SHAP_Wetland.jpg", 'wetl2015_shap', -0.05, 0.05)
    drawShap(DfWithLocation, "SHAP_Urban.jpg", 'impe2015_shap', -0.02, 0.02)
    drawShap(DfWithLocation, "SHAP_Bareland.jpg", 'bare2015_shap', -0.02, 0.02)
    drawShap(DfWithLocation, "SHAP_Income.jpg", 'di_inc_gdp_shap', -0.02, 0.02)
    return None

if __name__ == '__main__':
    REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('y')
    WORLD_MAP = gpd.read_file(REPO_LOCATION + "02_Data/country.shp")
    run()


