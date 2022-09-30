library(bgx)
bgxOutput <- readOutput.bgx("run.4")
exprs(bgxOutput)

plotExpressionDensity(bgxOutput, gene=4027)

rankedGeneList <- rankByDE(bgxOutput)
rankedGeneList

plotDEHistogram(bgxOutput, df=6)

plotDiffRank(bgxOutput)