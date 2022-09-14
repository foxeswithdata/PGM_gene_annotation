BiocManager::install(c("AnnotationHub"))

library(AnnotationHub)
ah <- AnnotationHub()

ah
#query(ah, "OrgDb")

dp = unique(ah$dataprovider)
sp = (unique(ah$species))
dp

match('NCBI', dp)

match(c("homo sapiens", "mus musculus"),sp)

species = query(ah, c("NCBI", "homo sapiens"))

species = query(ah, "", taxonomyid = "9606")
(unique(species$species))



species$title
species