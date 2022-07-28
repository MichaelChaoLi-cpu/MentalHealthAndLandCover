# Author: M.L.

# end

library(rgdal)
library(sp)
library(tidyverse)
library(stringr)

substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

setwd("D:\\01_Article\\07_SurveyPoint\\")

fileList <- list.files()
#substrRight(fileList[1], 3)
fileList.shp = c()
for (filename in fileList){
  if (substrRight(filename, 3) == "shp"){
    fileList.shp <- append(fileList.shp, str_sub(filename, 1, -5))
  }
}

coordDF <- data.frame(Date=as.Date(character()),
                           File=character(), 
                           User=character(), 
                           stringsAsFactors=FALSE) 

i = 1 
while (i < length(fileList.shp) + 1) {
  spfile <-
    readOGR(dsn='.', layer = fileList.shp[i])
  spfile@data <- spfile@data %>% dplyr::select("StandardID")
  coord <- coordinates(spfile)
  spfile@data$X <- coord[,1]
  spfile@data$Y <- coord[,2]
  print(i)
  print(nrow(spfile@data))
  coordDF <- rbind(coordDF, spfile@data)
  i = i + 1
}

coordDF <- coordDF %>% distinct()
coordDF$StandardID <- coordDF$StandardID %>% as.numeric()
coordDF <- coordDF %>% filter(X > -200)

setwd("C:/Users/li.chao.987@s.kyushu-u.ac.jp/OneDrive - Kyushu University/02_Article/03_RStudio")
save(coordDF, file = "01_PrivateData/02_coordOfSID.RData")
