#BiocManager::install("GEOquery")
#BiocManager::install("")

BiocManager::install("ExiMiR")

#library(coexnet)
library(GEOquery)
library(ExiMiR)
library(affy)


gds <- getGEO("GDS596")
show(gds)

Meta(gds)$platform
gpl <- getGEO("GPL96")
ma = GDS2MA(gds, GPL=gpl)
ma

createAB(ma, verbose = T)

gse <- getGEOSuppFiles("GSE1133")
gse2 <- getGEO("GSE1133", FALSE)

