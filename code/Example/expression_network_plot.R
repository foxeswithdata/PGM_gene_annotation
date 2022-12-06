library(affy)
library(estrogen)
library(vsn)
library(genefilter)
library(igraph)
library("hgu95av2.db")

ls("package:hgu95av2.db")


datadir <- system.file("extdata", package="estrogen")
#dir(datadir)
#setwd(datadir)


# Read in phenotype data and the raw CEL files
pd <- read.AnnotatedDataFrame(paste0(datadir,"/estrogen.txt"), header=TRUE, sep="", row.names=1)
show(pd)

a <- ReadAffy(filenames=paste(datadir,rownames(pData(pd))[5:6],sep='/'), phenoData=pd, verbose=TRUE)
a2 <- ReadAffy(filenames=paste(datadir,rownames(pData(pd))[7:8],sep='/'), phenoData=pd, verbose=TRUE)
pData(pd)

espresso = function(a){
  return(expresso(
    a, 
    bgcorrect.method = "rma",
    normalize.method = "constant",
    pmcorrect.method = "pmonly",
    summary.method = "avgdiff",
    summary.subset = ls(hgu95av2cdf)[1:20]
  ))
}

x = espresso(a)

x2 = espresso(a2)

head(a2@assayData$exprs, n = 20)




buildAdjecency = function(x){
  return(graph.adjacency(
    as.matrix(as.dist(cor(t(exprs(x)), method="pearson"))),
    mode="undirected",
    weighted=TRUE,
    diag=FALSE
  ))
}

g <- buildAdjecency(x)

g2 <- buildAdjecency(x2)

processGraph = function(g){
  # Simplfy the adjacency object
  g <- simplify(g, remove.multiple=TRUE, remove.loops=TRUE)
  
  # Colour negative correlation edges as blue
  E(g)[which(E(g)$weight<0)]$color <- "darkblue"
  
  # Colour positive correlation edges as red
  E(g)[which(E(g)$weight>0)]$color <- "darkred"
  
  # Convert edge weights to absolute values
  E(g)$weight <- abs(E(g)$weight)
  
  # Delete weakly correlated edges
  g <- delete_edges(g, E(g)[which(E(g)$weight<0.8)])
  
  # Remove any vertices remaining that have no edges
  g <- delete.vertices(g, degree(g)==0)
  
  # Assign names to the graph vertices (optional)
  V(g)$name <- V(g)$name
  
  # Change shape of graph vertices
  V(g)$shape <- "sphere"
  
  # Change colour of graph vertices
  V(g)$color <- "purple"
  
  # Change colour of vertex frames
  V(g)$vertex.frame.color <- "white"

  return(g)
}

g = processGraph(g)
g2 = processGraph(g2)

# Amplify or decrease the width of the edges
  edgeweights <- E(g)$weight * 2.0

# Amplify or decrease the width of the edges
  edgeweights2 <- E(g)$weight * 2.0

# Scale the size of the vertices to be proportional to the level of expression of each gene represented by each vertex
# Multiply scaled vales by a factor of 10
scale01 <- function(x){(x-min(x))/(max(x)-min(x))}
vSizes <- (scale01(apply(exprs(x), 1, mean)) + 1.0) * 10
vSizes2 <- (scale01(apply(exprs(x2), 1, mean)) + 1.0) * 10

# Convert the graph adjacency object into a minimum spanning tree based on Prim's algorithm
buildCommunity = function(g){
  mst1 <- mst(g, algorithm="prim")
  mst1.communities <- edge.betweenness.community(mst1, weights=NULL, directed=FALSE)
  mst1.clustering <- make_clusters(mst1, membership=mst1.communities$membership)
  V(mst1)$color <- mst1.communities$membership + 1
  return (list(mst1,mst1.communities,mst1.clustering))
}

mstabuild = buildCommunity(g)
msta = mstabuild[[1]]
msta.communities = mstabuild[[2]]
msta.clustering = mstabuild[[3]]

mstabuild = buildCommunity(g2)
mstb = mstabuild[[1]]
mstb.communities = mstabuild[[2]]
mstb.clustering = mstabuild[[3]]

rbind(msta.communities$names,msta.communities$membership)
rbind(mstb.communities$names,mstb.communities$membership)

com = msta.communities$membership
com2 = mstb.communities$membership

sum(com==com2)/length(com)*100

hgu95av2_dbconn()
quer = select(hgu95av2.db, keys=probes[1], columns=c("GO","GOALL", "GENENAME", "PFAM"), keytype="PROBEID")
#quer = head(quer, n = 2000)
#unique("100_g_at" %l% quer[,1:2])

names = V(g)$name
names
unique(names[3] %l% quer[,1:2])
for(i in 1:length(names)){
  names[i] = unique(names[i] %l% quer[,1:2])
}
names

par(mfrow=c(1,2))
plot(
  msta.clustering, msta,
  layout=layout.fruchterman.reingold,
  edge.curved=TRUE,
  vertex.size=vSizes,
  vertex.label.dist=-0.5,
  vertex.label.color="black",
  asp=FALSE,
  vertex.label.cex=1,
  edge.width=edgeweights,
  edge.arrow.mode=0,
  main="Estrogen Absent")

plot(
  mstb.clustering, mstb,
  layout=layout.fruchterman.reingold,
  edge.curved=TRUE,
  vertex.size=vSizes2,
  vertex.label.dist=-0.5,
  vertex.label.color="black",
  asp=FALSE,
  vertex.label.cex=1,
  edge.width=edgeweights2,
  edge.arrow.mode=0,
  main="Estrogen Present")