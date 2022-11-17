# -*- coding: utf-8 -*-
"""
Created on Wed Nov 16 13:20:45 2022

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
WORLD_MAP = gpd.read_file("D:/01_Article/06_PublicFile/country.shp")

def makeSpatialMvDf():
    DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
    DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"
    spatialCoefficientDfWithMv = load(DP02_result_location + 
                                      "spatialCoefficientDfWithMv.joblib")
    spatialCoefficientDfWithMv = spatialCoefficientDfWithMv.fillna(0)
    spatialCoefficientDfWithMv = spatialCoefficientDfWithMv.replace(np.inf, 0)
    spatialCoefficientDfWithMv = spatialCoefficientDfWithMv[[
        'crop2015_MV', 'fore2015_MV', 'gras2015_MV', 'shru2015_MV',
        'wetl2015_MV', 'wate2015_MV', 'impe2015_MV', 'bare2015_MV'
        ]]
    dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
    dataset = dataset[None]
    datasetLocation = dataset[['X', 'Y']] 
    MvDfWithLocation = pd.concat([spatialCoefficientDfWithMv, datasetLocation], axis=1)
    return MvDfWithLocation

def drawMvCropland(X, figure_name):
    X = X[['crop2015_MV', 'X', 'Y']]
    XMvOver0 = X[X['crop2015_MV']!=0]
    XMvOver0Ave = pd.DataFrame(XMvOver0.groupby(['X', 'Y'])['crop2015_MV'].mean())
    XMvOver0Ave.reset_index(inplace=True)
    XMvOver0Ave.loc[XMvOver0Ave['crop2015_MV']>0.05, 'crop2015_MV'] = 0.05
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].scatter(XMvOver0Ave.X, XMvOver0Ave.Y, c = XMvOver0Ave.crop2015_MV, 
                   cmap = CMAP, s = 40, alpha = 0.5, marker = '.', 
                   linewidths=0)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin=0, vmax=0.05)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Monetary Value (DIG/%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)

def drawMvForest(X, figure_name):
    X = X[['fore2015_MV', 'X', 'Y']]
    XMvOver0 = X[X['fore2015_MV']!=0]
    XMvOver0Ave = pd.DataFrame(XMvOver0.groupby(['X', 'Y'])['fore2015_MV'].mean())
    XMvOver0Ave.reset_index(inplace=True)
    XMvOver0Ave.loc[XMvOver0Ave['fore2015_MV']>0.3, 'fore2015_MV'] = 0.3
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].scatter(XMvOver0Ave.X, XMvOver0Ave.Y, c = XMvOver0Ave.fore2015_MV, 
                   cmap = CMAP, s = 40, alpha = 0.5, marker = '.', 
                   linewidths=0)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin=0, vmax=0.3)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Monetary Value (DIG/%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)

def drawMvGrassland(X, figure_name):
    X = X[['gras2015_MV', 'X', 'Y']]
    XMvOver0 = X[X['gras2015_MV']>0]
    XMvOver0Ave = pd.DataFrame(XMvOver0.groupby(['X', 'Y'])['gras2015_MV'].mean())
    XMvOver0Ave.reset_index(inplace=True)
    XMvOver0Ave.loc[XMvOver0Ave['gras2015_MV']>0.05, 'gras2015_MV'] = 0.05
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].scatter(XMvOver0Ave.X, XMvOver0Ave.Y, c = XMvOver0Ave.gras2015_MV, 
                   cmap = CMAP, s = 40, alpha = 0.5, marker = '.', 
                   linewidths=0)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin=0, vmax=0.05)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Monetary Value (DIG/%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)

def drawMvShrubland(X, figure_name):
    X = X[['shru2015_MV', 'X', 'Y']]
    XMvOver0 = X[X['shru2015_MV']!=0]
    XMvOver0Ave = pd.DataFrame(XMvOver0.groupby(['X', 'Y'])['shru2015_MV'].mean())
    XMvOver0Ave.reset_index(inplace=True)
    XMvOver0Ave.loc[XMvOver0Ave['shru2015_MV']>10, 'shru2015_MV'] = 10
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].scatter(XMvOver0Ave.X, XMvOver0Ave.Y, c = XMvOver0Ave.shru2015_MV, 
                   cmap = CMAP, s = 40, alpha = 0.5, marker = '.', 
                   linewidths=0)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin=0, vmax=10)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Monetary Value (DIG/%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)
    
def drawMvWater(X, figure_name):
    X = X[['wate2015_MV', 'X', 'Y']]
    XMvOver0 = X[X['wate2015_MV']!=0]
    XMvOver0Ave = pd.DataFrame(XMvOver0.groupby(['X', 'Y'])['wate2015_MV'].mean())
    XMvOver0Ave.reset_index(inplace=True)
    XMvOver0Ave.loc[XMvOver0Ave['wate2015_MV']>0.6, 'wate2015_MV'] = 0.6
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].scatter(XMvOver0Ave.X, XMvOver0Ave.Y, c = XMvOver0Ave.wate2015_MV, 
                   cmap = CMAP, s = 40, alpha = 0.5, marker = '.', 
                   linewidths=0)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin=0, vmax=0.6)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Monetary Value (DIG/%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)

def drawMvWetland(X, figure_name):
    X = X[['wetl2015_MV', 'X', 'Y']]
    XMvOver0 = X[X['wetl2015_MV']!=0]
    XMvOver0Ave = pd.DataFrame(XMvOver0.groupby(['X', 'Y'])['wetl2015_MV'].mean())
    XMvOver0Ave.reset_index(inplace=True)
    XMvOver0Ave.loc[XMvOver0Ave['wetl2015_MV']>15, 'wetl2015_MV'] = 15
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].scatter(XMvOver0Ave.X, XMvOver0Ave.Y, c = XMvOver0Ave.wetl2015_MV, 
                   cmap = CMAP, s = 40, alpha = 0.5, marker = '.', 
                   linewidths=0)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin=0, vmax=15)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Monetary Value (DIG/%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)

def drawMvUrban(X, figure_name):
    X = X[['impe2015_MV', 'X', 'Y']]
    XMvOver0 = X[X['impe2015_MV']!=0]
    XMvOver0Ave = pd.DataFrame(XMvOver0.groupby(['X', 'Y'])['impe2015_MV'].mean())
    XMvOver0Ave.reset_index(inplace=True)
    XMvOver0Ave.loc[XMvOver0Ave['impe2015_MV']>0.1, 'impe2015_MV'] = 0.1
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].scatter(XMvOver0Ave.X, XMvOver0Ave.Y, c = XMvOver0Ave.impe2015_MV, 
                   cmap = CMAP, s = 40, alpha = 0.5, marker = '.', 
                   linewidths=0)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin=0, vmax=0.1)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Monetary Value (DIG/%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)

def drawMvBareland(X, figure_name):
    X = X[['bare2015_MV', 'X', 'Y']]
    XMvOver0 = X[X['bare2015_MV']!=0]
    XMvOver0Ave = pd.DataFrame(XMvOver0.groupby(['X', 'Y'])['bare2015_MV'].mean())
    XMvOver0Ave.reset_index(inplace=True)
    XMvOver0Ave.loc[XMvOver0Ave['bare2015_MV']>5, 'bare2015_MV'] = 5
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].scatter(XMvOver0Ave.X, XMvOver0Ave.Y, c = XMvOver0Ave.bare2015_MV, 
                   cmap = CMAP, s = 40, alpha = 0.5, marker = '.', 
                   linewidths=0)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin=0, vmax=5)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Monetary Value (DIG/%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)
    

MvDfWithLocation = makeSpatialMvDf()
drawMvCropland(MvDfWithLocation, "MV_Cropland.jpg")
drawMvForest(MvDfWithLocation, "MV_Forest.jpg")
drawMvGrassland(MvDfWithLocation, "MV_Grassland.jpg")
drawMvShrubland(MvDfWithLocation, "MV_Shrubland.jpg")
drawMvWater(MvDfWithLocation, "MV_Water.jpg")
drawMvWetland(MvDfWithLocation, "MV_Wetland.jpg")
drawMvUrban(MvDfWithLocation, "MV_Urban.jpg")
drawMvBareland(MvDfWithLocation, "MV_Bareland.jpg")



"""
X = MvDfWithLocation
XMvOver0Ave.describe()
"""
