install.packages('ontologyIndex')
install.packages("BiocManager")
BiocManager::install(version = "3.16")

BiocManager::install(c("Biobase", "affy", "hgu95av2.db", "hgu95av2cdf", "vsn"))

BiocManager::install(c("estrogen", "genefilter"))

BiocManager::install("coexnet")
BiocManager::install("DCGL")
BiocManager::install("GEOquery")


