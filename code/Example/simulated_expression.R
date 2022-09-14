BiocManager::install("coexnet")
BiocManager::install("DCGL")

library(coexnet)
library(DCGL)

# Simulated expression data
n <- 200
m <- 20
# The vector with treatment samples and control samples
t <- c(rep(0,10),rep(1,10))
#  Calculating the expression values normalized
mat <- as.matrix(rexp(n, rate = 1))
norm <- t(apply(mat, 1, function(nm) rnorm(m, mean=nm, sd=1)))
# Calculating the coefficient of variation to case samples
case <- cofVar(expData = norm,complete = FALSE,treatment = t,type = "case")
head(case)
exprs()