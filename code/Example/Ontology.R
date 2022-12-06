library("hgu95av2.db")
library(hgu95av2cdf)
library(ontologyIndex)
library(qdapTools)

keys(hgu95av2.db, keytype = "PROBEID")

probes = ls(hgu95av2cdf)[1:2000]

quer = select(hgu95av2.db, keys=probes[1], columns=c("GO","GOALL", "GENENAME", "PFAM"), keytype="PROBEID")
quer = head(quer, n = 2000)
unique("100_g_at" %l% quer[,1:2])


columns(hgu95av2.db)
ontology_index(quer, id = quer[,1],name = quer[,8])

obo = get_ontology("go.obo")
minimal_set(obo, quer$GO)


ontologyIndex::get_term_info_content(obo, quer$GO[1:2000], patch_missing = F)
data(hpo)
get_term_info_content(hpo, list("HP:0001873"))



getGoFromProbe = function (probe){
  select(ghu95av2.db, keys = probe, columns = "GO", keytype = "PROBEID")
}