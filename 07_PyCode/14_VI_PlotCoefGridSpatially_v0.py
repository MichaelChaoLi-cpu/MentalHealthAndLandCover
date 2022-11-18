# -*- coding: utf-8 -*-
"""
Created on Thu Nov 17 13:06:50 2022

@author: li.chao.987@s.kyushu-u.ac.jp
"""

import os
import pandas as pd
import numpy as np
import geopandas as gpd
import shapely

from joblib import dump, load
import pyreadr

import matplotlib as mpl
import matplotlib.colors
import matplotlib.pyplot as plt

DP02_FIGURE_LOCATION = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/05_Figure/"
CMAP = matplotlib.colors.LinearSegmentedColormap.from_list("", ["blue","green","yellow","red"])
WORLD_MAP = gpd.read_file("D:/01_Article/06_PublicFile/country.shp")

def makeSpatialCoefDf():
    DP02_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/"
    DP02_result_location = "D:/OneDrive - Kyushu University/02_Article/03_RStudio/08_PyResults/"
    spatialCoefficientDfWithMv = load(DP02_result_location + "spatialCoefficientDfWithMv.joblib")
    spatialCoefficientDf = spatialCoefficientDfWithMv.iloc[:,0:18]
    spatialCoefficientDf[spatialCoefficientDf.columns] = spatialCoefficientDf[spatialCoefficientDf.columns].astype(float)
    dataset = pyreadr.read_r(DP02_location + "02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover_RdsVer.Rds")
    dataset = dataset[None]
    datasetLocation = dataset[['X', 'Y']] 
    CoefDfWithLocation = pd.concat([spatialCoefficientDf, datasetLocation], axis=1)
    return CoefDfWithLocation

def makePointGpddf(ShapDfWithLocation):
    ShapDfGpd = gpd.GeoDataFrame(ShapDfWithLocation, 
                                 geometry=gpd.points_from_xy(ShapDfWithLocation.X, 
                                                             ShapDfWithLocation.Y))
    ShapDfGpd = ShapDfGpd.set_crs(4326)
    xmin, ymin, xmax, ymax= -180, -90, 180, 90
    cell_size = 2.5
    # create the cells in a loop
    grid_cells = []
    for x0 in np.arange(xmin, xmax+cell_size, cell_size ):
        for y0 in np.arange(ymin, ymax+cell_size, cell_size):
            x1 = x0-cell_size
            y1 = y0+cell_size
            grid_cells.append(shapely.geometry.box(x0, y0, x1, y1))
    cell = gpd.GeoDataFrame(grid_cells, columns=['geometry'])
    cell = cell.set_crs(4326)
    merged = gpd.sjoin(ShapDfGpd, cell, how='left', op='within')
    merged[merged.columns[0:18]] = merged[merged.columns[0:18]].astype(float)
    dissolve = merged.groupby(['index_right']).agg('mean')
    cell.loc[dissolve.index, dissolve.columns[0:18]] = dissolve[dissolve.columns[0:18]].values
    return cell

def drawShapGrid(X, figure_name, column_name, vmin, vmax):
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    X.plot(ax=axs[0], column = column_name, cmap = CMAP, edgecolor = "grey",
           vmin = vmin, vmax = vmax)
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin = vmin, vmax = vmax)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Slope Between Land Status and Shapley Value',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)
    return None

CoefDfWithLocation = makeSpatialCoefDf()
ShapGridDf = makePointGpddf(CoefDfWithLocation)

drawShapGrid(ShapGridDf, "Coef_Cropland.jpg", 'crop2015_coef', 0, 0.003)
drawShapGrid(ShapGridDf, "Coef_Forest.jpg", 'fore2015_coef', 0, 0.0005)
drawShapGrid(ShapGridDf, "Coef_Grassland.jpg", 'gras2015_coef', 0, 0.0001)
drawShapGrid(ShapGridDf, "Coef_Shrubland.jpg", 'shru2015_coef', 0, 0.03)
drawShapGrid(ShapGridDf, "Coef_Water.jpg", 'wate2015_coef', 0, 0.03)
drawShapGrid(ShapGridDf, "Coef_Wetland.jpg", 'wetl2015_coef', 0, 0.5)
drawShapGrid(ShapGridDf, "Coef_Urbanland.jpg", 'impe2015_coef', 0, 0.001)
drawShapGrid(ShapGridDf, "Coef_Bareland.jpg", 'bare2015_coef', 0, 0.1)


def drawShapGrid(X, figure_name, column_name, vmin, vmax):
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    X.plot(ax=axs[0], column = column_name, cmap = CMAP, edgecolor = "grey",
           vmin = vmin, vmax = vmax)
    WORLD_MAP.boundary.plot(ax=axs[0], edgecolor='black', alpha = 0.5, linewidth=0.3)
    axs[0].grid(True)
    axs[0].set_xlabel("Longitude", fontsize=25)
    axs[0].set_ylabel("Latitude", fontsize=25)
    axs[0].tick_params(axis='both', which='major', labelsize=20)
    axs[0].set_xlim([-180, 180])
    axs[0].set_ylim([-90, 90])
    
    norm = mpl.colors.Normalize(vmin = vmin, vmax = vmax)
    cbar = fig.colorbar(mpl.cm.ScalarMappable(norm=norm, cmap=CMAP),
                        cax=axs[1])
    cbar.set_label('Slope Between Current Status and Shapley Value',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)
    return None
drawShapGrid(ShapGridDf, "Coef_Income.jpg", 'di_inc_gdp_coef', 0, 0.2)

