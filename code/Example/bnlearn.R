data("coronary")
library("bnlearn")

BayeNet_df <- data.frame(coronary)
result <- hc(BayeNet_df)
result$arcs <- result$arcs[-which((result$arcs[,'from'] == "M..Work" & result$arcs[, 'to'] == "Family")),]
plot(result)

fittedbn <- bn.fit(result, data = BayeNet_df)
print(fittedbn$Proteins)

a <- cpquery(fittedbn, event = (Pressure==">140"), evidence = (Proteins==">3"))
a