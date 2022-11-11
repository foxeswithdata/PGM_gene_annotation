library(GraphAlignment)
library(vsn)
library(igraph)


options(width = 40)
options(digits = 3);

# Generate example network pair from 2 seperate simulated species with 10 orthologs
ex<-GenerateExample(dimA=11, dimB=11, filling=.5, 
                    covariance=.6, symmetric=TRUE, numOrths=3, correlated=seq(1,2))
ex


# Do initial alignment and provide dummy pairs to orphan nodes
pinitial<-InitialAlignment(psize=34, r=ex$r, mode="reciprocal")
pinitial

# -2, -1.5,...,2
lookupLink<-seq(-2,2,.5)
lookupLink


# Compute link parameters -- 
linkParams<-ComputeLinkParameters(ex$a, ex$b, pinitial, lookupLink)
linkParams


# Compute node parameters --
lookupNode<-c(-.5,.5,1.5)
nodeParams<-ComputeNodeParameters(dimA=22, dimB=22, ex$r,
                                  pinitial, lookupNode)
nodeParams


# align networks, paring values between species based on Value and corresponding Index
al<-AlignNetworks(A=ex$a, B=ex$b, R=ex$r, P=pinitial, 
                  linkScore=linkParams$ls,
                  selfLinkScore=linkParams$ls,
                  nodeScore1=nodeParams$s1, nodeScore0=nodeParams$s0,
                  lookupLink=lookupLink, lookupNode=lookupNode,
                  bStart=.1, bEnd=30,
                  maxNumSteps=50)
al
length(al)


# Computes overall likeness(?) scores between links and nodes (unknown value range)
ComputeScores(A=ex$a, B=ex$b, R=ex$r, P=al, 
              linkScore=linkParams$ls,
              selfLinkScore=linkParams$ls,
              nodeScore1=nodeParams$s1, nodeScore0=nodeParams$s0,
              lookupLink=lookupLink, lookupNode=lookupNode,
              symmetric=TRUE)


# Returns $na [aligned nodes], $nb [unaligned nodes], and $nc ['misaligned' nodes] 
AnalyzeAlignment(A=ex$a, B=ex$b, R=ex$r, P=al, lookupNode,
                 epsilon=.5)

ex$a

ex$b

####
# Code for graphing network..
####

aUnaligned = which(al > 22)
aUnaligned = aUnaligned[which(aUnaligned < 23)]
length(aUnaligned)
aUnaligned
aAligned = ex$a[-aUnaligned,-aUnaligned]

bUnaligned = al[23:34]

bUnaligned = bUnaligned[which(bUnaligned < 23)]
bUnaligned

bAligned = ex$b[-bUnaligned,-bUnaligned]
bAligned

#as.matrix(as.dist(cor(t(ex$a), method="pearson")))
g <- graph.adjacency(
  aAligned,
  mode="undirected",
  weighted=TRUE,
  diag=FALSE
)

g

g2 <- graph.adjacency(
  bAligned,
  mode="undirected",
  weighted=TRUE,
  diag=FALSE
)

g2

# Simplfy the adjacency object
#g <- simplify(g, remove.multiple=TRUE, remove.loops=TRUE)

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
#V(g)$name <- V(g)$name
#V(g2)$name <- V(g2)$name


# Change shape of graph vertices
V(g)$shape <- "sphere"
V(g2)$shape <- "sphere"

# Change colour of graph vertices
V(g)$color <- "purple"
V(g)[1:10]$color <- rgb(0.5+0.05 * 1:10,0.2,0.2)
V(g)
V(g2)$color <- "purple"
V(g2)[1:10]$color <- rgb(0.5+0.05 * 1:10,0.2,0.2)

# Change colour of vertex frames
V(g)$vertex.frame.color <- "white"
V(g2)$vertex.frame.color <- "white"

# Scale the size of the vertices to be proportional to the level of expression of each gene represented by each vertex
# Multiply scaled vales by a factor of 10
scale01 <- function(x){(x-min(x))/(max(x)-min(x))}
vSizes <- (scale01(apply(aAligned, 1, mean)) + 1.0) * 10
vSizes2 <- (scale01(apply(bAligned, 1, mean)) + 1.0) * 10

# Amplify or decrease the width of the edges
edgeweights <- E(g)$weight * 2.0
edgeweights2 <- E(g2)$weight * 2.0
E(g)$weight
edgeweights
edgeweights2

# Convert the graph adjacency object into a minimum spanning tree based on Prim's algorithm
mst <- mst(g, algorithm="prim")
mst
mst2 <- mst(g2, algorithm="prim")

par(mfrow=c(2,1), bg = "#202020", col.main = "white")
# Plot the tree object
plot(
  mst,
  layout=layout.circle,
#  edge.label.color="white",
 # edge.label= E(g)$weight,
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
  layout=layout.circle,
 # edge.label= E(g2)$weight,
 # edge.label.color="white",
  edge.curved=TRUE,
  vertex.size=vSizes2,
  vertex.label.dist=-0.5,
  vertex.label.color="white",
  asp=FALSE,
  vertex.label.cex=0.6,
  edge.width=edgeweights2,
  edge.arrow.mode=0,
  main="Graph Test 2")