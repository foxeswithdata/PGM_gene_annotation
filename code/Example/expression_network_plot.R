library(affy)
library(estrogen)
library(vsn)
library(genefilter)

library(igraph)


datadir <- system.file("extdata", package="estrogen")
#dir(datadir)
#setwd(datadir)


# Read in phenotype data and the raw CEL files
pd <- read.AnnotatedDataFrame(paste0(datadir,"/estrogen.txt"), header=TRUE, sep="", row.names=1)
show(pd)

a <- ReadAffy(filenames=paste(datadir,rownames(pData(pd))[5:6],sep='/'), phenoData=pd, verbose=TRUE)
a2 <- ReadAffy(filenames=paste(datadir,rownames(pData(pd))[7:8],sep='/'), phenoData=pd, verbose=TRUE)
show(a$phenoData)
pData(a)

ls(hgu95av2cdf)[1:20]

a@assayData$exprs

a
a2

x = expresso(
  a, 
  bgcorrect.method = "rma",
  normalize.method = "constant",
  pmcorrect.method = "pmonly",
  summary.method = "avgdiff",
  summary.subset = ls(hgu95av2cdf)[1:20]
  )

x2 = expresso(
  a2, 
  bgcorrect.method = "rma",
  normalize.method = "constant",
  pmcorrect.method = "pmonly",
  summary.method = "avgdiff",
  summary.subset = ls(hgu95av2cdf)[1:20]
)

exprs(x)
exprs(x2)

# # Remove control probes
# controlProbeIdx <- grep("^AFFX", rownames(x2))
# x <- x[-controlProbeIdx,]
# controlProbeIdx
# 
# controlProbeIdx2 <- grep("^AFFX", rownames(x))
# x2 <- x2[-controlProbeIdx2,]

# Identify genes of significant effect
# lm.coef <- function(y) lm(y ~ estrogen * time.h)$coefficients
# eff <- esApply(x, 1, lm.coef)
# effectUp <- names(sort(eff[2,], decreasing=TRUE)[1:25])
# effectDown <- names(sort(eff[2,], decreasing=FALSE)[1:25])
# main.effects <- c(effectUp, effectDown)

# Make BGX ver.


# Filter the expression set object to include only genes of significant effect
# estrogenMainEffects <- exprs(x)[main.effects,]
# head(estrogenMainEffects)

# b@assayData$exprs

# bexpr <- b@assayData$exprs

# Create a graph adjacency based on correlation distances between genes in  pairwise fashion.
g <- graph.adjacency(
  as.matrix(as.dist(cor(t(exprs(x)), method="pearson"))),
  mode="undirected",
  weighted=TRUE,
  diag=FALSE
)

g

g2 <- graph.adjacency(
  as.matrix(as.dist(cor(t(exprs(x2)), method="pearson"))),
  mode="undirected",
  weighted=TRUE,
  diag=FALSE
)

g2

# Simplfy the adjacency object
g <- simplify(g, remove.multiple=TRUE, remove.loops=TRUE)

# Colour negative correlation edges as blue
E(g)[which(E(g)$weight<0)]$color <- "darkblue"

# Colour positive correlation edges as red
E(g)[which(E(g)$weight>0)]$color <- "darkred"

# Convert edge weights to absolute values
E(g)$weight <- abs(E(g)$weight)

E(g)$weight


g2 <- simplify(g2, remove.multiple=TRUE, remove.loops=TRUE)

# Colour negative correlation edges as blue
E(g2)[which(E(g2)$weight<0)]$color <- "darkblue"

# Colour positive correlation edges as red
E(g2)[which(E(g2)$weight>0)]$color <- "darkred"

# Convert edge weights to absolute values
E(g2)$weight <- abs(E(g2)$weight)

E(g2)$weight

# Change arrow size
# For directed graphs only
#E(g)$arrow.size <- 1.0

# Remove edges below absolute Pearson correlation 0.8
g <- delete_edges(g, E(g)[which(E(g)$weight<0.8)])
g2 <- delete_edges(g2, E(g2)[which(E(g2)$weight<0.8)])

g
g2

# Remove any vertices remaining that have no edges
g <- delete.vertices(g, degree(g)==0)
g2 <- delete.vertices(g2, degree(g2)==0)
g
# Assign names to the graph vertices (optional)
V(g)$name <- V(g)$name
V(g2)$name <- V(g2)$name


# Change shape of graph vertices
V(g)$shape <- "sphere"
V(g2)$shape <- "sphere"

# Change colour of graph vertices
V(g)$color <- "purple"
V(g2)$color <- "purple"

# Change colour of vertex frames
V(g)$vertex.frame.color <- "white"
V(g2)$vertex.frame.color <- "white"

# Scale the size of the vertices to be proportional to the level of expression of each gene represented by each vertex
# Multiply scaled vales by a factor of 10
scale01 <- function(x){(x-min(x))/(max(x)-min(x))}
vSizes <- (scale01(apply(exprs(x), 1, mean)) + 1.0) * 10
vSizes2 <- (scale01(apply(exprs(x2), 1, mean)) + 1.0) * 10

# Amplify or decrease the width of the edges
edgeweights <- E(g)$weight * 2.0
edgeweights2 <- E(g2)$weight * 2.0

edgeweights
edgeweights2

# Convert the graph adjacency object into a minimum spanning tree based on Prim's algorithm
mst <- mst(g, algorithm="prim")
mst2 <- mst(g2, algorithm="prim")

par(mfrow=c(2,1), bg = "#202020", col.main = "white")
# Plot the tree object
plot(
  mst,
  layout=layout.fruchterman.reingold,
  edge.curved=TRUE,
  vertex.size=vSizes,
  vertex.label.dist=-0.5,
  vertex.label.color="white",
  asp=FALSE,
  vertex.label.cex=0.6,
  edge.width=edgeweights,
  edge.arrow.mode=0,
  main="Graph Test 1")

plot(
  mst2,
  layout=layout.fruchterman.reingold,
  edge.curved=TRUE,
  vertex.size=vSizes2,
  vertex.label.dist=-0.5,
  vertex.label.color="white",
  asp=FALSE,
  vertex.label.cex=0.6,
  edge.width=edgeweights2,
  edge.arrow.mode=0,
  main="Graph Test 2")


V(g)

a <- V

?V




mst.communities <- edge.betweenness.community(mst, weights=NULL, directed=FALSE)
mst.clustering <- make_clusters(mst, membership=mst.communities$membership)
V(mst)$color <- mst.communities$membership + 1

par(mfrow=c(1,2))
plot(
  mst.clustering, mst,
  layout=layout.fruchterman.reingold,
  edge.curved=TRUE,
  vertex.size=vSizes,
  vertex.label.dist=-0.5,
  vertex.label.color="white",
  asp=FALSE,
  vertex.label.cex=0.6,
  edge.width=edgeweights,
  edge.arrow.mode=0,
  main="Com1")

plot(
  mst,
  layout=layout.fruchterman.reingold,
  edge.curved=TRUE,
  vertex.size=vSizes,
  vertex.label.dist=-0.5,
  vertex.label.color="white",
  asp=FALSE,
  vertex.label.cex=0.6,
  edge.width=edgeweights,
  edge.arrow.mode=0,
  main="Com2")