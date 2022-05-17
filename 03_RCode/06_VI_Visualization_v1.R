# Author: M.L.

# end

library(dplyr)
library(tidyverse)
library(moments)
library(ggplot2)
library(grid)
library(DALEX)
library(randomForest)
library("viridisLite")
library("viridis") 
library(grid)
library(gridExtra)

get_density <- function(x, y, ...) {
    dens <- MASS::kde2d(x, y, ...)
    ix <- findInterval(x, dens$x)
    iy <- findInterval(y, dens$y)
    ii <- cbind(ix, iy)
    return(dens$z[ii])
}

getWeights <- function(input_data, aim_variable, division_num){
    input_data <- input_data[, aim_variable]
    half_step <- ((max(input_data) - min(input_data))/(division_num)/2)
    wetl.weights <- hist(input_data,
                         breaks = seq(min(input_data) - half_step, max(input_data) + half_step,
                                      length = (division_num + 1)),
                         plot = F)
    wetl.weights <- wetl.weights$counts
    return(wetl.weights)
}

load("02_Data/SP_Data_47Variable_Weights_changeRangeOfLandCover.RData")

#-------------descriptive statistics--------------
Mean <- round(mean(data_47$GHQ12), 2)
SD <- round(sd(data_47$GHQ12), 2)
N = nrow(data_47)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.75,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 18)))
grob_add <- grobTree(textGrob("a",
                              x = 0.02,  y = 0.95, hjust = 0,
                              gp = gpar(col = "black", fontsize = 18)))
(a <- ggplot(data_47) +
    aes(x = GHQ12) +
    xlim(-1, 37) +
    geom_histogram(colour = "black", fill = "white", bins = 37, binwidth = 1) +
    xlab("Mental Health Assessment") + 
    ylab("Frequency") +
    annotation_custom(grob))

jpeg(file="05_Figure\\descriptive_stat_GHQ.jpeg", 
     width = 297, height = 210, units = "mm", quality = 300, res = 300)
a
dev.off()

Mean <- round(mean(data_47$di_inc_gdp), 2)
SD <- round(sd(data_47$di_inc_gdp), 2)
N = nrow(data_47)
grob <- grobTree(textGrob(paste0("Mean = ", Mean, "\nStd.dev = ", SD,"\nN = ", N),
                          x = 0.75,  y = 0.90, hjust = 0,
                          gp = gpar(col = "black", fontsize = 18)))
(b <- ggplot(data_47) +
    aes(x = di_inc_gdp) +
    xlim(-1.1, 3.1) +
    geom_histogram(colour = "black", fill = "white", bins = 41, binwidth = 0.1) +
    xlab("Difference between Individual Income and GDP per Capita") + 
    ylab("Frequency") +
    annotation_custom(grob))

jpeg(file="05_Figure\\descriptive_stat_income.jpeg", 
     width = 297, height = 210, units = "mm", quality = 300, res = 300)
b
dev.off()

### residual
load("04_Results/06_explainer_data.rf.47.weighted.RData")
#explainer_data.rf.47.weighted$y
#explainer_data.rf.47.weighted$residuals
rf.y.yhat.resid <- cbind(explainer_data.rf.47.weighted$y, explainer_data.rf.47.weighted$y_hat,
                         explainer_data.rf.47.weighted$residuals) %>% as.data.frame()
colnames(rf.y.yhat.resid) <- c("y", "yhat", "residuals")
rf.y.yhat.resid$y.yhat.Density <- get_density(rf.y.yhat.resid$y, rf.y.yhat.resid$yhat, n = 1000)
grob.r2 <- grobTree(textGrob("R2 = 90.51%",
                             x = 0.05,  y = 0.90, hjust = 0,
                             gp = gpar(col = "black", fontsize = 12)))
grob.rmse <- grobTree(textGrob("RMSE = 1.94",
                               x = 0.05,  y = 0.87, hjust = 0,
                               gp = gpar(col = "black", fontsize = 12)))
grob.mse <- grobTree(textGrob("MSE = 3.77",
                               x = 0.05,  y = 0.84, hjust = 0,
                               gp = gpar(col = "black", fontsize = 12)))
grob.mae <- grobTree(textGrob("MAE = 1.08",
                              x = 0.05,  y = 0.81, hjust = 0,
                              gp = gpar(col = "black", fontsize = 12)))
grob.N <- grobTree(textGrob("N = 88730",
                              x = 0.05,  y = 0.78, hjust = 0,
                              gp = gpar(col = "black", fontsize = 12)))
(plot.y.yhat <- ggplot(rf.y.yhat.resid) +
    geom_point(aes(x = y, y = yhat, color = y.yhat.Density)) +
    geom_smooth(aes(x = y, y = yhat), method = "lm") +
    scale_color_viridis(name = "Density") + 
    scale_x_continuous(name = "Measured Mental Health Score") +
    scale_y_continuous(name = "Predicted Mental Health Score") +
    geom_abline(intercept = 0, slope = 1, color="red", 
                linetype = "dashed", size = 0.5) +
    annotation_custom(grob.r2) + 
    annotation_custom(grob.rmse) +
    annotation_custom(grob.mse) +
    annotation_custom(grob.mae) +
    annotation_custom(grob.N) +
    theme_bw())
jpeg(file="05_Figure/y_yhat.jpeg", width = 210, height = 210, units = "mm", quality = 300, res = 300)
plot.y.yhat
dev.off()

#### PDP
load("04_Results/04_pdp_47weighted_resolution002.RData")
load("02_Data/SP_Data_47Variable_Weights_changeRangeOfLandCover.RData")

pdp.result.di_inc$weights <- getWeights(data_47, "di_inc_gdp",nrow(pdp.result.di_inc))
pdp.result.di_inc <- pdp.result.di_inc %>% as.matrix() %>% as.data.frame()
pdp.result.di_inc <- pdp.result.di_inc %>%
    mutate(weights = ifelse(weights > 100, 100, weights))
(plot.di_inc <- ggplot(pdp.result.di_inc) +
        geom_point(aes(x = di_inc_gdp, y = yhat, color = weights), size = 1, alpha = 0.5,
                   show.legend = F) +
        scale_color_viridis(name = "Counts", direction = -1) +
        scale_x_continuous(name = "The Respondent's DIG") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        annotate("text", x = -1, y = 24.375, label = 'bold("a")', parse = TRUE, size = 5)
)

pdp.result.bare2015$weights <- getWeights(data_47, "bare2015",nrow(pdp.result.bare2015))
pdp.result.bare2015 <- pdp.result.bare2015 %>% as.matrix() %>% as.data.frame()
pdp.result.bare2015 <- pdp.result.bare2015 %>%
    mutate(weights = ifelse(weights > 100, 100, weights))
(plot.bare <- ggplot(pdp.result.bare2015) +
    geom_point(aes(x = bare2015, y = yhat, color = weights), size = 1, alpha = 0.5,
               show.legend = F) +
    scale_color_viridis(name = "Counts", direction = -1) +
    scale_x_continuous(name = "Bare Land in Respondent's Living Environment (%)") +
    scale_y_continuous(name = "Predicted Mental Health Score") +
    theme_bw() +
    annotate("text", x = -0.5, y = 24.33, label = 'bold("b")', parse = TRUE, size = 5)
    )

pdp.result.crop2015$weights <- getWeights(data_47, "crop2015",nrow(pdp.result.crop2015))
pdp.result.crop2015 <- pdp.result.crop2015 %>% as.matrix() %>% as.data.frame()
pdp.result.crop2015 <- pdp.result.crop2015 %>%
    mutate(weights = ifelse(weights > 100, 100, weights))
(plot.crop <- ggplot(pdp.result.crop2015) +
        geom_point(aes(x = crop2015, y = yhat, color = weights), size = 1, alpha = 0.5,
                   show.legend = F) +
        scale_color_viridis(name = "Counts", direction = -1) +
        scale_x_continuous(name = "Crop Land in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        annotate("text", x = -0.5, y = 24.33, label = 'bold("c")', parse = TRUE, size = 5)
)

pdp.result.fore2015$weights <- getWeights(data_47, "fore2015",nrow(pdp.result.fore2015))
pdp.result.fore2015 <- pdp.result.fore2015 %>% as.matrix() %>% as.data.frame()
pdp.result.fore2015 <- pdp.result.fore2015 %>%
    mutate(weights = ifelse(weights > 100, 100, weights))
(plot.fore <- ggplot(pdp.result.fore2015) +
        geom_point(aes(x = fore2015, y = yhat, color = weights), size = 1, alpha = 0.5,
                   show.legend = F) +
        scale_color_viridis(name = "Counts", direction = -1) +
        scale_x_continuous(name = "Forest Land in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        annotate("text", x = 100, y = 24.26, label = 'bold("d")', parse = TRUE, size = 5)
)

pdp.result.gras2015$weights <- getWeights(data_47, "gras2015",nrow(pdp.result.gras2015))
pdp.result.gras2015 <- pdp.result.gras2015 %>% as.matrix() %>% as.data.frame()
pdp.result.gras2015 <- pdp.result.gras2015 %>%
    mutate(weights = ifelse(weights > 100, 100, weights))
(plot.gras <- ggplot(pdp.result.gras2015) +
        geom_point(aes(x = gras2015, y = yhat, color = weights), size = 1, alpha = 0.5,
                   show.legend = F) +
        scale_color_viridis(name = "Counts", direction = -1) +
        scale_x_continuous(name = "Grass Land in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        annotate("text", x = -0.6, y = 24.5, label = 'bold("e")', parse = TRUE, size = 5)
)

pdp.result.impe2015$weights <- getWeights(data_47, "impe2015",nrow(pdp.result.impe2015))
pdp.result.impe2015 <- pdp.result.impe2015 %>% as.matrix() %>% as.data.frame()
pdp.result.impe2015 <- pdp.result.impe2015 %>%
    mutate(weights = ifelse(weights > 100, 100, weights))
(plot.impe <- ggplot(pdp.result.impe2015) +
        geom_point(aes(x = impe2015, y = yhat, color = weights), size = 1, alpha = 0.5,
                   show.legend = F) +
        scale_color_viridis(name = "Counts", direction = -1) +
        scale_x_continuous(name = "Urban Land in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        annotate("text", x = 100, y = 24.29, label = 'bold("f")', parse = TRUE, size = 5,
                 show.legend = F)
)

pdp.result.shru2015$weights <- getWeights(data_47, "shru2015",nrow(pdp.result.shru2015))
pdp.result.shru2015 <- pdp.result.shru2015 %>% as.matrix() %>% as.data.frame()
pdp.result.shru2015 <- pdp.result.shru2015 %>%
    mutate(weights = ifelse(weights > 100, 100, weights))
(plot.shru <- ggplot(pdp.result.shru2015) +
        geom_point(aes(x = shru2015, y = yhat, color = weights), size = 1, alpha = 0.5,
                   show.legend = F) +
        scale_color_viridis(name = "Counts", direction = -1) +
        scale_x_continuous(name = "Shrub Land in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        annotate("text", x = -0.6, y = 24.39, label = 'bold("g")', parse = TRUE, size = 5)
)

pdp.result.wate2015$weights <- getWeights(data_47, "wate2015",nrow(pdp.result.wate2015))
pdp.result.wate2015 <- pdp.result.wate2015 %>% as.matrix() %>% as.data.frame()
pdp.result.wate2015 <- pdp.result.wate2015 %>%
    mutate(weights = ifelse(weights > 100, 100, weights))
(plot.wate <- ggplot(pdp.result.wate2015) +
        geom_point(aes(x = wate2015, y = yhat, color = weights), size = 1, alpha = 0.5,
                   show.legend = F) +
        scale_color_viridis(name = "Counts", direction = -1) +
        scale_x_continuous(name = "Water in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        annotate("text", x = -0.6, y = 24.32, label = 'bold("h")', parse = TRUE, size = 5)
)

pdp.result.wetl2015$weights <- getWeights(data_47, "wetl2015",nrow(pdp.result.wetl2015))
pdp.result.wetl2015 <- pdp.result.wetl2015 %>% as.matrix() %>% as.data.frame()
pdp.result.wetl2015 <- pdp.result.wetl2015 %>%
    mutate(weights = ifelse(weights > 100, 100, weights))
(plot.wetl <- ggplot(pdp.result.wetl2015) +
        geom_point(aes(x = wetl2015, y = yhat, color = weights), size = 1, alpha = 0.5) +
        scale_color_viridis(name = "Counts", direction = -1) +
        scale_x_continuous(name = "Wetland in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        theme(legend.position = c(.9, .25),
              legend.key.size = unit(0.3, 'cm')) +
        annotate("text", x = -0, y = 24.52, label = 'bold("i")', parse = TRUE, size = 5)
)

jpeg(file="05_Figure/PDP.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
grid.arrange(plot.di_inc, plot.bare, plot.crop, 
             plot.fore, plot.gras, plot.impe, 
             plot.shru, plot.wate, plot.wetl, 
             nrow = 3)
dev.off()
#### PDP

#### PPDF
load("04_Results/03_pdp_refit_weights_rf47weighted.RData")
pred.line.di_inc[[2]] %>% summary()
(ppdf.di_inc <- ggplot() +
    geom_point(data = pdp.result.di_inc, aes(x = di_inc_gdp, y = yhat),
               color = "grey77", size = 1, alpha = 0.5, show.legend = F) +
    geom_point(data = pred.line.di_inc[[1]], aes(x = di_inc_gdp, y = yhat_pred, 
                                                 color = pred.line.di_inc[[2]]$weights),
               size = 1, alpha = 0.8, show.legend = T) +
    scale_color_viridis(name = "Weights", direction = -1) +
    scale_x_continuous(name = "The Respondent's DIG") +
    scale_y_continuous(name = "Predicted Mental Health Score") +
    theme_bw() +
    theme(legend.position = c(.85, .3),
          legend.key.size = unit(0.3, 'cm')) +
    annotate("text", x = -1, y = 24.375, label = 'bold("a")', parse = TRUE, size = 5) +
    annotate("text", x = 2.51, y = 23.52, label = 'bold("R2 = 99.79%")', parse = TRUE, size = 2.5)
)

pred.line.bare2015[[2]] %>% summary()
(ppdf.bare <- ggplot() +
    geom_point(data = pdp.result.bare2015,
               aes(x = bare2015, y = yhat), size = 1, alpha = 0.5, color = "grey77",
               show.legend = F) +
    geom_point(data = pred.line.bare2015[[1]], aes(x = bare2015, y = yhat_pred, 
                                                   color = pred.line.bare2015[[2]]$weights),
               size = 1, alpha = 0.8, show.legend = T) +
    scale_color_viridis(name = "Weights", direction = -1) +
    scale_x_continuous(name = "Bare Land in Respondent's Living Environment (%)") +
    scale_y_continuous(name = "Predicted Mental Health Score") +
    theme_bw() +
      theme(legend.position = c(.15, .3),
            legend.key.size = unit(0.3, 'cm')) +
    annotate("text", x = -0.5, y = 24.33, label = 'bold("b")', parse = TRUE, size = 5) +
    annotate("text", x = 2.4, y = 24.02, label = 'bold("R2 = 99.71%")', parse = TRUE, size = 2.5)
)

pred.line.crop2015[[2]] %>% summary()
(ppdf.crop <- ggplot() +
        geom_point(data = pdp.result.crop2015,
                   aes(x = crop2015, y = yhat), size = 1, alpha = 0.5, color = "grey77",
                   show.legend = F) +
        geom_point(data = pred.line.crop2015[[1]], aes(x = crop2015, y = yhat_pred, 
                                                       color = pred.line.crop2015[[2]]$weights),
                   size = 1, alpha = 0.8, show.legend = T) +
        scale_color_viridis(name = "Weights", direction = -1) +
        scale_x_continuous(name = "Crop Land in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        theme(legend.position = c(.25, .3),
              legend.key.size = unit(0.3, 'cm')) +
        annotate("text", x = -0.5, y = 24.30, label = 'bold("c")', parse = TRUE, size = 5) +
        annotate("text", x = 24, y = 24.05, label = 'bold("R2 = 99.68%")', parse = TRUE, size = 2.5)
)

pred.line.fore2015[[2]] %>% summary()
(ppdf.fore <- ggplot() +
        geom_point(data = pdp.result.fore2015,
                   aes(x = fore2015, y = yhat), size = 1, alpha = 0.5, color = "grey77",
                   show.legend = F) +
        geom_point(data = pred.line.fore2015[[1]], aes(x = fore2015, y = yhat_pred, 
                                                       color = pred.line.fore2015[[2]]$weights),
                   size = 1, alpha = 0.8, show.legend = T) +
        scale_color_viridis(name = "Weights", direction = -1) +
        scale_x_continuous(name = "Forest in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        theme(legend.position = c(.25, .3),
              legend.key.size = unit(0.3, 'cm')) +
        annotate("text", x = 100, y = 24.26, label = 'bold("d")', parse = TRUE, size = 5) +
        annotate("text", x = 25, y = 24, label = 'bold("R2 = 99.62%")', parse = TRUE, size = 2.5)
)

pred.line.gras2015[[2]] %>% summary()
(ppdf.gras <- ggplot() +
        geom_point(data = pdp.result.gras2015,
                   aes(x = gras2015, y = yhat), size = 1, alpha = 0.5, color = "grey77",
                   show.legend = F) +
        geom_point(data = pred.line.gras2015[[1]], aes(x = gras2015, y = yhat_pred, 
                                                       color = pred.line.gras2015[[2]]$weights),
                   size = 1, alpha = 0.8, show.legend = T) +
        scale_color_viridis(name = "Weights", direction = -1) +
        scale_x_continuous(name = "Grass Land in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        theme(legend.position = c(.85, .7),
              legend.key.size = unit(0.3, 'cm')) +
        annotate("text", x = 100, y = 24.5, label = 'bold("e")', parse = TRUE, size = 5) +
        annotate("text", x = 90, y = 24.2, label = 'bold("R2 = 99.60%")', parse = TRUE, size = 2.5)
)

pred.line.impe2015[[2]] %>% summary()
(ppdf.impe <- ggplot() +
        geom_point(data = pdp.result.impe2015,
                   aes(x = impe2015, y = yhat), size = 1, alpha = 0.5, color = "grey77",
                   show.legend = F) +
        geom_point(data = pred.line.impe2015[[1]], aes(x = impe2015, y = yhat_pred, 
                                                       color = pred.line.impe2015[[2]]$weights),
                   size = 1, alpha = 0.8, show.legend = T) +
        scale_color_viridis(name = "Weights", direction = -1) +
        scale_x_continuous(name = "Urban Land in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        theme(legend.position = c(.25, .3),
              legend.key.size = unit(0.3, 'cm')) +
        annotate("text", x = 100, y = 24.29, label = 'bold("f")', parse = TRUE, size = 5) +
        annotate("text", x = 23, y = 24.02, label = 'bold("R2 = 99.70%")', parse = TRUE, size = 2.5)
)

pred.line.shru2015[[2]] %>% summary()
(ppdf.shru <- ggplot() +
        geom_point(data = pdp.result.shru2015,
                   aes(x = shru2015, y = yhat), size = 1, alpha = 0.5, color = "grey77",
                   show.legend = F) +
        geom_point(data = pred.line.shru2015[[1]], aes(x = shru2015, y = yhat_pred, 
                                                       color = pred.line.shru2015[[2]]$weights),
                   size = 1, alpha = 0.8, show.legend = T) +
        scale_color_viridis(name = "Weights", direction = -1) +
        scale_x_continuous(name = "Shrub Land in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        theme(legend.position = c(.25, .3),
              legend.key.size = unit(0.3, 'cm')) +
        annotate("text", x = 40, y = 24.38, label = 'bold("g")', parse = TRUE, size = 5) +
        annotate("text", x = 8.7, y = 24.12, label = 'bold("R2 = 98.92%")', parse = TRUE, size = 2.5)
)

pred.line.wate2015[[2]] %>% summary()
(ppdf.wate <- ggplot() +
        geom_point(data = pdp.result.wate2015,
                   aes(x = wate2015, y = yhat), size = 1, alpha = 0.5, color = "grey77",
                   show.legend = F) +
        geom_point(data = pred.line.wate2015[[1]], aes(x = wate2015, y = yhat_pred, 
                                                       color = pred.line.wate2015[[2]]$weights),
                   size = 1, alpha = 0.8, show.legend = T) +
        scale_color_viridis(name = "Weights", direction = -1) +
        scale_x_continuous(name = "Water in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        theme(legend.position = c(.25, .3),
              legend.key.size = unit(0.3, 'cm')) +
        annotate("text", x = 50, y = 24.33, label = 'bold("h")', parse = TRUE, size = 5) +
        annotate("text", x = 11, y = 23.92, label = 'bold("R2 = 99.88%")', parse = TRUE, size = 2.5)
)

pred.line.wetl2015[[2]] %>% summary()
(ppdf.wetl <- ggplot() +
        geom_point(data = pdp.result.wetl2015,
                   aes(x = wetl2015, y = yhat), size = 1, alpha = 0.5, color = "grey77",
                   show.legend = F) +
        geom_point(data = pred.line.wetl2015[[1]], aes(x = wetl2015, y = yhat_pred, 
                                                       color = pred.line.wetl2015[[2]]$weights),
                   size = 1, alpha = 0.8, show.legend = T) +
        scale_color_viridis(name = "Weights", direction = -1) +
        scale_x_continuous(name = "Wetland in Respondent's Living Environment (%)") +
        scale_y_continuous(name = "Predicted Mental Health Score") +
        theme_bw() +
        theme(legend.position = c(.85, .3),
              legend.key.size = unit(0.3, 'cm')) +
        annotate("text", x = -0, y = 24.52, label = 'bold("i")', parse = TRUE, size = 5) +
        annotate("text", x = 2.73, y = 24.20, label = 'bold("R2 = 97.75%")', parse = TRUE, size = 2.5)
)

jpeg(file="05_Figure/PPDF.jpeg", width = 297, height = 210, units = "mm", quality = 300, res = 300)
grid.arrange(ppdf.di_inc, ppdf.bare, ppdf.crop, 
             ppdf.fore, ppdf.gras, ppdf.impe, 
             ppdf.shru, ppdf.wate, ppdf.wetl, 
             nrow = 3)
dev.off()
#### PPDF
