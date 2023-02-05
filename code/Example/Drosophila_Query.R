if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("biomaRt")
library(GEOquery)
#library(ExiMiR)
library(affy)

query = getGEO("GSE5489")
query

query2 = getGEOSuppFiles("GSE5489")

data = fData(query[[1]])
colnames(data)
# Get geneOntology for each gene from these columns

#pair them with each gene, save the data as csv table (gene, ontologyies \n gene, ontologies)
#load that into Java program, then use this data as labels for each gene
cols = c('ID', 'Gene Ontology Biological Process', 'Gene Ontology Cellular Component', 'Gene Ontology Molecular Function')
sub = data[cols]
rownames(sub) = NULL
colnames(sub) = c("gene","bio","cell","mole")
sub$bio = substr(sub$bio, 1 ,7)
sub$cell = substr(sub$cell, 1 ,7)
sub$mole = substr(sub$mole, 1 ,7)
sub$bio = paste0("GO:",sub$bio)
sub$cell = paste0("GO:",sub$cell)
sub$mole = paste0("GO:",sub$mole)
write.csv(sub, "genes.csv", row.names = FALSE)