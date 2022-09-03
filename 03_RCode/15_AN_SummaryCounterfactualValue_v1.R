# Author: M.L.


# end

library(tidyverse)
library(dplyr)
library(sp)

load("04_Results/97_temp_bareCounterfactualValue.Rdata")
load("04_Results/97_temp_cropCounterfactualValue.Rdata")
load("04_Results/97_temp_foreCounterfactualValue.Rdata")
load("04_Results/97_temp_grasCounterfactualValue.Rdata")
load("04_Results/97_temp_impeCounterfactualValue.Rdata")
load("04_Results/97_temp_shruCounterfactualValue.Rdata")
load("04_Results/97_temp_wateCounterfactualValue.Rdata")
load("04_Results/97_temp_wetlCounterfactualValue.Rdata")

load("02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")

dataWithCounterfactual <- cbind(data_49, counterfactualValueOfBareChange1, counterfactualValueOfCropChange1,
                                counterfactualValueOfForeChange1, counterfactualValueOfGrasChange1,
                                counterfactualValueOfImpeChange1, counterfactualValueOfShruChange1,
                                counterfactualValueOfWateChange1, counterfactualValueOfWetlChange1)

counterValueWithLocation <- dataWithCounterfactual %>% 
  dplyr::select(X, Y, counterfactualValueOfBareChange1:counterfactualValueOfWetlChange1)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- counterValueWithLocation %>% dplyr::select(X, Y)
counterValueWithLocation <- SpatialPointsDataFrame(coords = xy, data = counterValueWithLocation,
                                                   proj4string = CRS(proj))

#### Test Figure
library(tmap)
sf_use_s2(FALSE)
library("rnaturalearth")

# tm set
title_size = .0001
legend_title_size = 1
margin = 0
brks = c(-1, -0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1)
tmap_mode('plot')

world <- ne_countries(scale = "medium", returnclass = "sp")

pal <- colorRampPalette(c("blue","green", "white","yellow","red"))
(globalFore <- 
    tm_shape(world) +
    tm_borders(col = 'black', lwd = 0.5, alpha = 0.8) +
    tm_grid(alpha = .25) + 
    tm_shape(counterValueWithLocation) +
    tm_dots("counterfactualValueOfForeChange1", palette = pal(11), breaks = brks, size = 0.15, 
            legend.show = F, shape = 21, border.lwd = 0, midpoint = 0) +
    tm_layout(
      inner.margins = c(margin, margin, margin, margin),
      title.size = title_size, 
      legend.position = c("left", "bottom"),
      legend.title.size = legend_title_size,
      legend.text.size = legend_title_size * 0.75
    ) + 
    tm_scale_bar())

