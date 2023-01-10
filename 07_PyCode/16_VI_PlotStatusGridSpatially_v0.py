# -*- coding: utf-8 -*-
"""
Created on Fri Nov 18 14:14:59 2022

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
    merged[merged.columns[0:9]] = merged[merged.columns[0:9]].astype(float)
    dissolve = merged.groupby(['index_right']).agg('mean')
    cell.loc[dissolve.index, dissolve.columns[0:9]] = dissolve[dissolve.columns[0:9]].values
    return cell

def changeIncomeScale(ShapGridDf):
    ShapGridDf['di_inc_gdp'] = ShapGridDf['di_inc_gdp'] * 100
    return ShapGridDf

def drawStatusGrid(X, figure_name, column_name, vmin, vmax):
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
    cbar.set_label('Spatially Average Current Status (%)',size=25)
    cbar.ax.tick_params(labelsize=20) 
    
    fig.savefig(DP02_FIGURE_LOCATION + figure_name)
    return None

def run():
    spatialStatusDf = makeSpatialStatusDf()
    ShapGridDf = makePointGpddf(spatialStatusDf)
    ShapGridDf = changeIncomeScale(ShapGridDf)
    
    drawStatusGrid(ShapGridDf, "Status_Cropland.jpg", 'crop2015', 0, 20)
    drawStatusGrid(ShapGridDf, "Status_Forest.jpg", 'fore2015', 0, 25)
    drawStatusGrid(ShapGridDf, "Status_Grassland.jpg", 'gras2015', 0, 35)
    drawStatusGrid(ShapGridDf, "Status_Shrubland.jpg", 'shru2015', 0, 2)
    drawStatusGrid(ShapGridDf, "Status_Water.jpg", 'wate2015', 0, 10)
    drawStatusGrid(ShapGridDf, "Status_Wetland.jpg", 'wetl2015', 0, 0.1)
    drawStatusGrid(ShapGridDf, "Status_Urbanland.jpg", 'impe2015', 0, 50)
    drawStatusGrid(ShapGridDf, "Status_Bareland.jpg", 'bare2015', 0, 1)
    drawStatusGrid(ShapGridDf, "Status_Income.jpg", 'di_inc_gdp', 0, 150)
    return None

if __name__ == '__main__':
    REPO_LOCATION, REPO_RESULT_LOCATION = runLocallyOrRemotely('y')
    WORLD_MAP = gpd.read_file(REPO_LOCATION + "02_Data/country.shp")
    run()

"""
for name in ShapGridDf.columns:
    print(ShapGridDf[name].describe())
"""