# Author: M.L.


# get each point mean, SE, p-value of the local neighbor dataset

# end

library(foreach)
library(doParallel)
library(doSNOW)


progress_fun <- function(n){
  cat(n, ' ')
  if (n%%100==0){
    cat('\n')
  }
}

localNeighborMeanSePval <- function(dataWithCounterfactual, landCoverCVname, 
                                    neighborOrderListTibble, clusterNumber){
  neighborOrderListTibble <- as.data.frame(neighborOrderListTibble)
  cl <- makeSOCKcluster(clusterNumber)
  registerDoSNOW(cl)
  opts <- list(progress=progress_fun)
  df.output <-
    foreach(i = seq(1, nrow(neighborOrderListTibble), 1), .combine = 'rbind',
             .options.snow = opts) %dopar% 
    {
      singleNeighborOrderListTibble <- neighborOrderListTibble[i,]
      singleNeighborOrderListTibble <- as.vector(as.matrix(singleNeighborOrderListTibble))
      singleNeighborOrderListTibble <- na.omit(singleNeighborOrderListTibble)
      if(length(singleNeighborOrderListTibble) > 2){
        aimDF <- dataWithCounterfactual[singleNeighborOrderListTibble,] 
        aimCol <- na.omit(aimDF[landCoverCVname])
        t <- t.test(aimCol)
        line <- c(t$estimate, t$stderr, t$statistic, t$p.value, t$parameter)
      } else {
        if(length(singleNeighborOrderListTibble) > 0){
          line <- c(mean(aimCol), NA, NA, NA, NA)
        }else{
          line <- c(NA, NA, NA, NA, NA)
        }
      }
    }
  stopCluster(cl)
  df.output <- as.data.frame(df.output)
  colnames(df.output) <- c("meanVal", "stderr", "tValue", "pValue", "df.para")
  return(df.output)
}

localNeighborMeanSePvalSingle <- 
  function(dataWithCounterfactual, landCoverCVname, neighborOrderListTibble){
  neighborOrderListTibble <- as.data.frame(neighborOrderListTibble)
  df.output <-data.frame(Doubles=double(),
                         Integers=integer(),
                         Factors=factor(),
                         Logicals=logical(),
                         Characters=character(),
                         stringsAsFactors=FALSE)
  for(i in seq(1, nrow(neighborOrderListTibble), 1)){
    #print(i)
    singleNeighborOrderListTibble <- neighborOrderListTibble[i,]
    singleNeighborOrderListTibble <- as.vector(as.matrix(singleNeighborOrderListTibble))
    singleNeighborOrderListTibble <- na.omit(singleNeighborOrderListTibble)
    if(length(singleNeighborOrderListTibble) > 2){
      aimDF <- dataWithCounterfactual[singleNeighborOrderListTibble,] 
      aimCol <- na.omit(aimDF[landCoverCVname])
      t <- t.test(aimCol)
      line <- c(t$estimate, t$stderr, t$statistic, t$p.value, t$parameter)
    } else {
      if(length(singleNeighborOrderListTibble) > 0){
        line <- c(mean(aimCol), NA, NA, NA, NA)
      }else{
        line <- c(NA, NA, NA, NA, NA)
      }
    }
    df.output <- rbind(df.output, line)
    #colnames(line) <- c("meanVal", "stderr", "tValue", "pValue", "df.para")
  }
  colnames(df.output) <- c("meanVal", "stderr", "tValue", "pValue", "df.para")
  return(df.output)
}