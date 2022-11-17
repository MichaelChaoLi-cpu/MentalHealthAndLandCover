# -*- coding: utf-8 -*-
"""
Created on Thu Nov 17 14:02:38 2022

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
    merged[merged.columns[0:8]] = merged[merged.columns[0:8]].astype(float)
    dissolve = merged.groupby(['index_right']).agg('mean')
    cell.loc[dissolve.index, dissolve.columns[0:8]] = dissolve[dissolve.columns[0:8]].values
    return cell

def drawMvGrid(X, figure_name, column_name, vmin, vmax):
    fig, axs = plt.subplots(nrows=1, ncols=2, figsize=(21, 10), dpi=1000,
                            gridspec_kw={'width_ratios': [10, 0.1]})
    X[column_name] = X[column_name] * 100
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
    cbar.set_label('Monetary Value (% GDP per Capita/ %)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)
    return None

MvDfWithLocation = makeSpatialMvDf()
ShapGridDf = makePointGpddf(MvDfWithLocation)

drawMvGrid(ShapGridDf, "MV_Grid_Cropland.jpg", 'crop2015_MV', 0, 2)
drawMvGrid(ShapGridDf, "MV_Grid_Forest.jpg", 'fore2015_MV', 0, 2)
drawMvGrid(ShapGridDf, "MV_Grid_Grassland.jpg", 'gras2015_MV', 0, 1)
drawMvGrid(ShapGridDf, "MV_Grid_Shrubland.jpg", 'shru2015_MV', 0, 20)
drawMvGrid(ShapGridDf, "MV_Grid_Water.jpg", 'wate2015_MV', 0, 20)
drawMvGrid(ShapGridDf, "MV_Grid_Wetland.jpg", 'wetl2015_MV', 0, 100)
drawMvGrid(ShapGridDf, "MV_Grid_Urbanland.jpg", 'impe2015_MV', 0, 1)
drawMvGrid(ShapGridDf, "MV_Grid_Bareland.jpg", 'bare2015_MV', 0, 100)

