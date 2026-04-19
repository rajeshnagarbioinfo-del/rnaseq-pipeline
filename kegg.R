library(clusterProfiler)
library(org.Hs.eg.db)

# Load significant genes
sig <- read.csv("significant_genes.csv")

# Convert ENSEMBL → ENTREZ
gene_list <- bitr(sig$row.names,
                  fromType="ENSEMBL",
                  toType="ENTREZID",
                  OrgDb=org.Hs.eg.db)

# KEGG enrichment
ekegg <- enrichKEGG(gene = gene_list$ENTREZID,
                    organism = "hsa",
                    pvalueCutoff = 0.05)

# Save results
write.csv(as.data.frame(ekegg), "kegg_results.csv")

# Plot
dotplot(ekegg)
