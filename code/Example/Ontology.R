library("hgu95av2.db")
library(ontologyIndex)

keys(hgu95av2.db, keytype = "PROBEID")

probes = ls(hgu95av2cdf)[1:20]

quer = select(hgu95av2.db, keys=probes[1], columns=c("GO","GOALL", "GENENAME", "PFAM"), keytype="PROBEID")
quer = head(quer, n = 20)
quer
columns(hgu95av2.db)
ontology_index(quer, id = quer[,1],name = quer[,8])

obo = get_ontology("go.obo")
minimal_set(obo, quer$GO)


ontologyIndex::get_term_info_content(obo, quer$GO[1:2000], patch_missing = F)
data(hpo)
get_term_info_content(hpo, list("HP:0001873"))
