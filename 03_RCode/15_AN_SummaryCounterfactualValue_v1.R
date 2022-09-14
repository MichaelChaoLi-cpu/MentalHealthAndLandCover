# Author: M.L.


# end

library(tidyverse)
library(dplyr)
library(sp)

source("03_RCode/16_AF_LocalMeanBasedonRF_v1.R")

load("04_Results/97_temp_bareCounterfactualValue.Rdata")
load("04_Results/97_temp_cropCounterfactualValue.Rdata")
load("04_Results/97_temp_foreCounterfactualValue.Rdata")
load("04_Results/97_temp_grasCounterfactualValue.Rdata")
load("04_Results/97_temp_impeCounterfactualValue.Rdata")
load("04_Results/97_temp_shruCounterfactualValue.Rdata")
load("04_Results/97_temp_wateCounterfactualValue.Rdata")
load("04_Results/97_temp_wetlCounterfactualValue.Rdata")

load("04_Results/99_temp_neighborOrderListTibble.Rdata")

bare.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfBareChange1",
                                      neighborOrderListTibble, 18)
saveRDS(bare.table, file = "DP02/04_Results/97_temp_counterfactualValueOfBareChange1.rds")
cat("bare.table\n\n\n")
crop.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfCropChange1",
                                      neighborOrderListTibble, 18)
saveRDS(crop.table, file = "DP02/04_Results/97_temp_counterfactualValueOfCropChange1.rds")
cat("crop.table\n\n\n")
fore.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfForeChange1",
                                      neighborOrderListTibble, 18)
saveRDS(fore.table, file = "DP02/04_Results/97_temp_counterfactualValueOfForeChange1.rds")
cat("fore.table\n\n\n")
gras.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfGrasChange1",
                                      neighborOrderListTibble, 18)
saveRDS(gras.table, file = "DP02/04_Results/97_temp_counterfactualValueOfGrasChange1.rds")
cat("gras.table\n\n\n")
impe.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfImpeChange1",
                                      neighborOrderListTibble, 18)
saveRDS(impe.table, file = "DP02/04_Results/97_temp_counterfactualValueOfImpeChange1.rds")
cat("impe.table\n\n\n")
shru.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfShruChange1",
                                      neighborOrderListTibble, 18)
saveRDS(shru.table, file = "DP02/04_Results/97_temp_counterfactualValueOfShruChange1.rds")
cat("shru.table\n\n\n")
wate.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfWateChange1",
                                      neighborOrderListTibble, 18)
saveRDS(wate.table, file = "DP02/04_Results/97_temp_counterfactualValueOfWateChange1.rds")
cat("wate.table\n\n\n")
wetl.table <- localNeighborMeanSePval(dataWithCounterfactual, "counterfactualValueOfWetlChange1",
                                      neighborOrderListTibble, 18)
saveRDS(wetl.table, file = "DP02/04_Results/97_temp_counterfactualValueOfWetlChange1.rds")
cat("wetl.table\n\n\n")

bare.table <- readRDS("04_Results/97_temp_counterfactualValueOfBareChange1.rds")
crop.table <- readRDS("04_Results/97_temp_counterfactualValueOfCropChange1.rds")
fore.table <- readRDS("04_Results/97_temp_counterfactualValueOfForeChange1.rds")
gras.table <- readRDS("04_Results/97_temp_counterfactualValueOfGrasChange1.rds")
impe.table <- readRDS("04_Results/97_temp_counterfactualValueOfImpeChange1.rds")
shru.table <- readRDS("04_Results/97_temp_counterfactualValueOfShruChange1.rds")
wate.table <- readRDS("04_Results/97_temp_counterfactualValueOfWateChange1.rds")
wetl.table <- readRDS("04_Results/97_temp_counterfactualValueOfWetlChange1.rds")

#### drop non-significant values 10%
bare.table.d <- bare.table %>% 
  mutate(meanVal = ifelse(pValue > 0.1, 0, meanVal),
         meanVal = ifelse(is.na(pValue), 0, meanVal))
crop.table.d <- crop.table %>% 
  mutate(meanVal = ifelse(pValue > 0.1, 0, meanVal),
         meanVal = ifelse(is.na(pValue), 0, meanVal))
fore.table.d <- fore.table %>% 
  mutate(meanVal = ifelse(pValue > 0.1, 0, meanVal),
         meanVal = ifelse(is.na(pValue), 0, meanVal))
gras.table.d <- gras.table %>% 
  mutate(meanVal = ifelse(pValue > 0.1, 0, meanVal),
         meanVal = ifelse(is.na(pValue), 0, meanVal))
impe.table.d <- impe.table %>% 
  mutate(meanVal = ifelse(pValue > 0.1, 0, meanVal),
         meanVal = ifelse(is.na(pValue), 0, meanVal))
shru.table.d <- shru.table %>% 
  mutate(meanVal = ifelse(pValue > 0.1, 0, meanVal),
         meanVal = ifelse(is.na(pValue), 0, meanVal))
wate.table.d <- wate.table %>% 
  mutate(meanVal = ifelse(pValue > 0.1, 0, meanVal),
         meanVal = ifelse(is.na(pValue), 0, meanVal))
wetl.table.d <- wetl.table %>% 
  mutate(meanVal = ifelse(pValue > 0.1, 0, meanVal),
         meanVal = ifelse(is.na(pValue), 0, meanVal))

merge.value.table <- cbind(bare.table.d$meanVal, crop.table.d$meanVal,
                           fore.table.d$meanVal, gras.table.d$meanVal,
                           impe.table.d$meanVal, shru.table.d$meanVal,
                           wate.table.d$meanVal, wetl.table.d$meanVal)
colnames(merge.value.table) <- c("bare", "crop", "fore", "gras",
                                 "impe", "shru", "wate", "wetl")



##### build spatial point data frame
load("02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")

#### Test Figure
library(tmap)
sf_use_s2(FALSE)
library("rnaturalearth")

# tm set
title_size = .0001
legend_title_size = 1
margin = 0
brks = c(-0.5, -0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4, 0.5)
tmap_mode('plot')

world <- ne_countries(scale = "medium", returnclass = "sp")

### bare
dataWithCounterfactual.bare <- cbind(data_49, merge.value.table)

counterValueWithLocation.bare <- dataWithCounterfactual.bare %>% 
  dplyr::select(X, Y, bare:wetl) %>% 
  filter(bare != 0)

counterValueWithLocation.bare <- counterValueWithLocation.bare %>% distinct(X, Y, .keep_all = TRUE)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- counterValueWithLocation.bare %>% dplyr::select(X, Y)
counterValueWithLocation.bare <- SpatialPointsDataFrame(coords = xy, data = counterValueWithLocation.bare,
                                                   proj4string = CRS(proj))

pal <- colorRampPalette(c("blue","green", "white", "white", "yellow","red"))
(globalBare <- 
    tm_shape(world) +
    tm_borders(col = 'black', lwd = 0.5, alpha = 0.8) +
    tm_grid(alpha = .25) + 
    tm_shape(counterValueWithLocation.bare) +
    tm_dots("bare", palette = pal(11), breaks = brks, size = 0.1, 
            legend.show = F, shape = 16, midpoint = 0, alpha = 0.5) +
    tm_layout(
      inner.margins = c(margin, margin, margin, margin),
      title.size = title_size, 
      legend.position = c("left", "bottom"),
      legend.title.size = legend_title_size,
      legend.text.size = legend_title_size * 0.75
    ) + 
    tm_scale_bar())

### crop
dataWithCounterfactual.crop <- cbind(data_49, merge.value.table)

counterValueWithLocation.crop <- dataWithCounterfactual.crop %>% 
  dplyr::select(X, Y, bare:wetl) %>% 
  filter(crop != 0)

counterValueWithLocation.crop <- counterValueWithLocation.crop %>% distinct(X, Y, .keep_all = TRUE)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- counterValueWithLocation.crop %>% dplyr::select(X, Y)
counterValueWithLocation.crop <- SpatialPointsDataFrame(coords = xy, data = counterValueWithLocation.crop,
                                                        proj4string = CRS(proj))

pal <- colorRampPalette(c("blue","green", "white", "white", "yellow","red"))
(globalCrop <- 
    tm_shape(world) +
    tm_borders(col = 'black', lwd = 0.5, alpha = 0.8) +
    tm_grid(alpha = .25) + 
    tm_shape(counterValueWithLocation.crop) +
    tm_dots("crop", palette = pal(11), breaks = brks, size = 0.1, 
            legend.show = F, shape = 16, midpoint = 0, alpha = 0.5) +
    tm_layout(
      inner.margins = c(margin, margin, margin, margin),
      title.size = title_size, 
      legend.position = c("left", "bottom"),
      legend.title.size = legend_title_size,
      legend.text.size = legend_title_size * 0.75
    ) + 
    tm_scale_bar())

### fore
dataWithCounterfactual.fore <- cbind(data_49, merge.value.table)

counterValueWithLocation.fore <- dataWithCounterfactual.fore %>% 
  dplyr::select(X, Y, bare:wetl) %>% 
  filter(fore != 0)

counterValueWithLocation.fore <- counterValueWithLocation.fore %>% distinct(X, Y, .keep_all = TRUE)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- counterValueWithLocation.fore %>% dplyr::select(X, Y)
counterValueWithLocation.fore <- SpatialPointsDataFrame(coords = xy, data = counterValueWithLocation.fore,
                                                        proj4string = CRS(proj))

pal <- colorRampPalette(c("blue","green", "white", "white", "yellow","red"))
(globalFore <- 
    tm_shape(world) +
    tm_borders(col = 'black', lwd = 0.5, alpha = 0.8) +
    tm_grid(alpha = .25) + 
    tm_shape(counterValueWithLocation.fore) +
    tm_dots("fore", palette = pal(11), breaks = brks, size = 0.1, 
            legend.show = F, shape = 16, midpoint = 0, alpha = 0.5) +
    tm_layout(
      inner.margins = c(margin, margin, margin, margin),
      title.size = title_size, 
      legend.position = c("left", "bottom"),
      legend.title.size = legend_title_size,
      legend.text.size = legend_title_size * 0.75
    ) + 
    tm_scale_bar())

### gras
dataWithCounterfactual.gras <- cbind(data_49, merge.value.table)

counterValueWithLocation.gras <- dataWithCounterfactual.gras %>% 
  dplyr::select(X, Y, bare:wetl) %>% 
  filter(gras != 0)

counterValueWithLocation.gras <- counterValueWithLocation.gras %>% distinct(X, Y, .keep_all = TRUE)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- counterValueWithLocation.gras %>% dplyr::select(X, Y)
counterValueWithLocation.gras <- SpatialPointsDataFrame(coords = xy, data = counterValueWithLocation.gras,
                                                        proj4string = CRS(proj))

pal <- colorRampPalette(c("blue","green", "white", "white", "yellow","red"))
(globalGras <- 
    tm_shape(world) +
    tm_borders(col = 'black', lwd = 0.5, alpha = 0.8) +
    tm_grid(alpha = .25) + 
    tm_shape(counterValueWithLocation.gras) +
    tm_dots("gras", palette = pal(11), breaks = brks, size = 0.1, 
            legend.show = F, shape = 16, midpoint = 0, alpha = 0.5) +
    tm_layout(
      inner.margins = c(margin, margin, margin, margin),
      title.size = title_size, 
      legend.position = c("left", "bottom"),
      legend.title.size = legend_title_size,
      legend.text.size = legend_title_size * 0.75
    ) + 
    tm_scale_bar())

### impe
dataWithCounterfactual.impe <- cbind(data_49, merge.value.table)

counterValueWithLocation.impe <- dataWithCounterfactual.impe %>% 
  dplyr::select(X, Y, bare:wetl) %>% 
  filter(impe != 0)

counterValueWithLocation.impe <- counterValueWithLocation.impe %>% distinct(X, Y, .keep_all = TRUE)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- counterValueWithLocation.impe %>% dplyr::select(X, Y)
counterValueWithLocation.impe <- SpatialPointsDataFrame(coords = xy, data = counterValueWithLocation.impe,
                                                        proj4string = CRS(proj))

pal <- colorRampPalette(c("blue","green", "white", "white", "yellow","red"))
(globalImpe <- 
    tm_shape(world) +
    tm_borders(col = 'black', lwd = 0.5, alpha = 0.8) +
    tm_grid(alpha = .25) + 
    tm_shape(counterValueWithLocation.impe) +
    tm_dots("impe", palette = pal(11), breaks = brks, size = 0.1, 
            legend.show = F, shape = 16, midpoint = 0, alpha = 0.5) +
    tm_layout(
      inner.margins = c(margin, margin, margin, margin),
      title.size = title_size, 
      legend.position = c("left", "bottom"),
      legend.title.size = legend_title_size,
      legend.text.size = legend_title_size * 0.75
    ) + 
    tm_scale_bar())

### wate
dataWithCounterfactual.wate <- cbind(data_49, merge.value.table)

counterValueWithLocation.wate <- dataWithCounterfactual.wate %>% 
  dplyr::select(X, Y, bare:wetl) %>% 
  filter(wate != 0)

counterValueWithLocation.wate <- counterValueWithLocation.wate %>% distinct(X, Y, .keep_all = TRUE)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- counterValueWithLocation.wate %>% dplyr::select(X, Y)
counterValueWithLocation.wate <- SpatialPointsDataFrame(coords = xy, data = counterValueWithLocation.wate,
                                                        proj4string = CRS(proj))

pal <- colorRampPalette(c("blue","green", "white", "white", "yellow","red"))
(globalWate <- 
    tm_shape(world) +
    tm_borders(col = 'black', lwd = 0.5, alpha = 0.8) +
    tm_grid(alpha = .25) + 
    tm_shape(counterValueWithLocation.wate) +
    tm_dots("wate", palette = pal(11), breaks = brks, size = 0.1, 
            legend.show = F, shape = 16, midpoint = 0, alpha = 0.5) +
    tm_layout(
      inner.margins = c(margin, margin, margin, margin),
      title.size = title_size, 
      legend.position = c("left", "bottom"),
      legend.title.size = legend_title_size,
      legend.text.size = legend_title_size * 0.75
    ) + 
    tm_scale_bar())

### wetl
dataWithCounterfactual.wetl <- cbind(data_49, merge.value.table)

counterValueWithLocation.wetl <- dataWithCounterfactual.wetl %>% 
  dplyr::select(X, Y, bare:wetl) %>% 
  filter(wetl != 0)

counterValueWithLocation.wate <- counterValueWithLocation.wetl %>% distinct(X, Y, .keep_all = TRUE)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- counterValueWithLocation.wetl %>% dplyr::select(X, Y)
counterValueWithLocation.wetl <- SpatialPointsDataFrame(coords = xy, data = counterValueWithLocation.wetl,
                                                        proj4string = CRS(proj))

pal <- colorRampPalette(c("blue","green", "white", "white", "yellow","red"))
(globalWetl <- 
    tm_shape(world) +
    tm_borders(col = 'black', lwd = 0.5, alpha = 0.8) +
    tm_grid(alpha = .25) + 
    tm_shape(counterValueWithLocation.wetl) +
    tm_dots("wetl", palette = pal(11), breaks = brks, size = 0.1, 
            legend.show = F, shape = 16, midpoint = 0, alpha = 0.5) +
    tm_layout(
      inner.margins = c(margin, margin, margin, margin),
      title.size = title_size, 
      legend.position = c("left", "bottom"),
      legend.title.size = legend_title_size,
      legend.text.size = legend_title_size * 0.75
    ) + 
    tm_scale_bar())

##### build spatial point data frame directly
load("02_Data/SP_Data_49Variable_Weights_changeRangeOfLandCover.RData")

#### Test Figure
library(tmap)
sf_use_s2(FALSE)
library("rnaturalearth")

# tm set
title_size = .0001
legend_title_size = 1
margin = 0
brks = c(-0.5, -0.4, -0.3, -0.2, -0.1, 0, 0.1, 0.2, 0.3, 0.4, 0.5)
tmap_mode('plot')

world <- ne_countries(scale = "medium", returnclass = "sp")

merge.value.table <- cbind(
  counterfactualValueOfBareChange1, counterfactualValueOfCropChange1,
  counterfactualValueOfForeChange1, counterfactualValueOfGrasChange1,
  counterfactualValueOfImpeChange1, counterfactualValueOfShruChange1,
  counterfactualValueOfWateChange1, counterfactualValueOfWetlChange1
  ) %>% as.data.frame()
colnames(merge.value.table) <- c("bare", "crop", "fore", "gras",
                                 "impe", "shru", "wate", "wetl")

### bare
dataWithCounterfactual.bare <- cbind(data_49, merge.value.table)

counterValueWithLocation.bare <- dataWithCounterfactual.bare %>% 
  dplyr::select(X, Y, bare:wetl) %>% 
  filter(bare != 0)

proj <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" 
xy <- counterValueWithLocation.bare %>% dplyr::select(X, Y)
counterValueWithLocation.bare <- SpatialPointsDataFrame(coords = xy, data = counterValueWithLocation.bare,
                                                        proj4string = CRS(proj))

pal <- colorRampPalette(c("blue","green", "white", "white", "yellow","red"))
(globalBare <- 
    tm_shape(world) +
    tm_borders(col = 'black', lwd = 0.5, alpha = 0.8) +
    tm_grid(alpha = .25) + 
    tm_shape(counterValueWithLocation.bare) +
    tm_dots("bare", palette = pal(11), breaks = brks, size = 0.1, 
            legend.show = F, shape = 16, midpoint = 0, alpha = 0.5) +
    tm_layout(
      inner.margins = c(margin, margin, margin, margin),
      title.size = title_size, 
      legend.position = c("left", "bottom"),
      legend.title.size = legend_title_size,
      legend.text.size = legend_title_size * 0.75
    ) + 
    tm_scale_bar())