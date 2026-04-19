library(pheatmap)

# Normalize counts
vsd <- vst(dds, blind=FALSE)

# Select top variable genes
topVarGenes <- head(order(rowVars(assay(vsd)), decreasing=TRUE), 50)

mat <- assay(vsd)[topVarGenes, ]

# Heatmap
pheatmap(mat,
         scale="row",
         clustering_distance_rows="correlation",
         clustering_distance_cols="correlation")