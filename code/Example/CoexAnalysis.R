library(affy)
library(estrogen)
library(bgx)

# BiocManager::install("bgx")

datadir <- system.file("extdata", package="estrogen")
dir(datadir)
datadir
#setwd(datadir)

# https://www.biostars.org/p/447204/

# Read in phenotype data and the raw CEL files
pd <- read.AnnotatedDataFrame(paste0(datadir,"/estrogen.txt"), header=TRUE, sep="", row.names=1)
pd
# pd@data$condition <- c(1,1,2,2,1,1,3,3)
pData(pd)

pdnames <- rownames(pData(pd))
paths <- paste(datadir, pdnames, sep='/')
pData(pd)
paths

affyNet <- ReadAffy(filenames=paths, phenoData=pd, verbose=TRUE)
affyNet@assayData$exprs[c(1:10,20:30),]


affyNet@assayData$exprs
b <- bgx(affyNet, genes = 1:5000, burnin = 2048, iter = 2048)
b$condition
out <- bgx(affyNet, samplesets = c(2, 2, 2, 2), genes = 11:20, burnin = 1024, iter = 1024)
out2 <- bgx(affyNet, samplesets = c(1,1,2,2,1,1), genes = 11:20, burnin = 1024, iter = 1024)

head(rankByDE(bgxOutput))
diff(b@assayData$exprs[4027,])








