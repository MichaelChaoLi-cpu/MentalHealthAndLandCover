# Author: M.L.

# end

library(dplyr)
library(tidyverse)
library(moments)
library(ggplot2)
library(grid)

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