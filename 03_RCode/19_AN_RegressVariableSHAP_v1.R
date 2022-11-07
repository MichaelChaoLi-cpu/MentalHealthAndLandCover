# Author: M.L.


# Note: this script to change the range of some land cover variables

# end

library(dplyr)
library(tidyverse)
library(sp)
library(GWPR.light)

XSHAP = read.csv("08_PyResults/mergedXSHAP.csv")
XSHAP$X.2 <- 1

fore_SHAP <- lm('fore2015_SHAP ~ fore2015', data = XSHAP)
crop_SHAP <- lm('crop2015_SHAP ~ crop2015', data = XSHAP)
impe_SHAP <- lm('impe2015_SHAP ~ impe2015', data = XSHAP)
gras_SHAP <- lm('gras2015_SHAP ~ gras2015', data = XSHAP)
shru_SHAP <- lm('shru2015_SHAP ~ shru2015', data = XSHAP)
wetl_SHAP <- lm('wetl2015_SHAP ~ wetl2015', data = XSHAP)
wate_SHAP <- lm('wate2015_SHAP ~ wate2015', data = XSHAP)
bare_SHAP <- lm('bare2015_SHAP ~ bare2015', data = XSHAP)

income_SHAP <- lm('di_inc_gdp_SHAP ~ di_inc_gdp', data = XSHAP)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- XSHAP %>% dplyr::select(X, Y)
spatialPoint <- SpatialPointsDataFrame(coords = xy, data = XSHAP[c('X.1', 'X.2')],
                                       proj4string = CRS(proj))
rm(xy)

formula <- fore2015_SHAP ~ fore2015
GWPR.POLS.bandwidth <- # 
  bw.GWPR(formula = formula, data = XSHAP, index = c("X.1", "X.2"),
          SDF = spatialPoint, adaptive = T, p = 2, bigdata = F,
          upperratio = 0.10, effect = "individual", model = "pooling", approach = "CV",
          kernel = "bisquare",doParallel = T, cluster.number = 10, gradientIncrement = T,
          GI.step = 1, GI.upper = 400, GI.lower = 20)
