#homeDirectory = getwd()
#setwd('/DSSATtrials')

source("runSensitivityTests.R")
library(foreach)
library(doMC) # - FOR MAC
#library(doSNOW) # - FOR WINDOWS

waterFreq = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 18, 21)
waterAmt  = seq(300, 400, 10)
fertNFreq = c(0, 1, 2, 3)
fertNAmt  = c(seq(0, 100, 50), seq(150, 290, 10), seq(300, 400, 50))
fertPFreq = c(0, 1, 2)
fertPAmt  = seq(0, 100, 20)

input = rbind(waterFreq, fertNFreq, fertPFreq, waterAmt, fertNAmt, fertPAmt)
inputLengths = c(length(waterFreq), length(fertNFreq), length(fertPFreq), length(waterAmt), length(fertNAmt), length(fertPAmt))

#Specify the number of cores you will be using - MAC
registerDoMC(12)

#specify the number of cores you will be using - WINDOWS
# cl <- makeCluster(2)
# registerDoSNOW(cl)

#run the tests
timeA = proc.time()
timeA

timeElapsed = runSensitivityTests(input, inputLengths)
timeElapsed

timeB = (proc.time() - timeA)[3]
timeB

timeSaved = timeElapsed - timeB
timeSaved

#stopCluster(cl) #terminate the cluster - FOR WINDOWS