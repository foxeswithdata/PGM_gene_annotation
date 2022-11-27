install.packages("remotes") #if remotes is not already installed
remotes::install_github("lvaudor/glitter")

library("glitter")

#example from glitter repo
query <- spq_init() %>%
  spq_add("?item wdt:P31 wd:Q13442814") %>%
  spq_add("?item rdfs:label ?itemTitle") %>%
  spq_filter(str_detect(str_to_lower(itemTitle), 'wikidata')) %>%
  spq_filter(lang(itemTitle) == "en") %>%
  spq_head(n = 5)
query
# PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
# SELECT ?item ?itemTitle
# WHERE{
#
# ?item wdt:P31 wd:Q13442814.
# ?item rdfs:label ?itemTitle.
# FILTER(REGEX(LCASE(?itemTitle),"wikidata"))
# FILTER(lang(?itemTitle)="en")
# SERVICE wikibase:label { bd:serviceParam wikibase:language "en".}
# }
#
# LIMIT 5
spq_perform(query)

# target Query
# PREFIX up: <http://purl.uniprot.org/core/>
# SELECT ?taxon
# FROM <http://sparql.uniprot.org/taxonomy>
# WHERE
# {
#     ?taxon a up:Taxon .
# }

query2 <- spq_init() %>%
  spq_prefix(prefixes = c(up="http://purl.uniprot.org/core/")) %>%
  spq_add(.triple_pattern = "?taxon a up:Taxon") %>%
  spq_head(n = 5)
query2
query <- spq_perform(endpoint = "https://sparql.uniprot.org/")
