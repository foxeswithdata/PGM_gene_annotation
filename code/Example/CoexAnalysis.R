library(affy)
library(estrogen)
library(bgx)

# BiocManager::install("bgx")

datadir <- system.file("extdata", package="estrogen")
dir(datadir)
setwd(datadir)

# https://www.biostars.org/p/447204/

# Read in phenotype data and the raw CEL files
pd <- read.AnnotatedDataFrame("estrogen.txt", header=TRUE, sep="", row.names=1)
pd@data$condition <- c(1,1,2,2,1,1,3,3)
pData(pd)

affyNet <- ReadAffy(filenames=rownames(pData(pd)), phenoData=pd, verbose=TRUE)
affyNet@assayData$exprs[c(1:10,20:30),]

rownames(pData(pd))
pData(pd)

b <- bgx(affyNet, genes = 1:10, burnin = 1024, iter = 1024)
b$condition
out <- bgx(affyNet, samplesets = c(2, 2, 2, 2), genes = 11:20, burnin = 1024, iter = 1024)
out2 <- bgx(affyNet, samplesets = c(1,1,2,2,1,1), genes = 11:20, burnin = 1024, iter = 1024)




