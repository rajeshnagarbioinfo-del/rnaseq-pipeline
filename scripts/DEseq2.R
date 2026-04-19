library(DESeq2)

# Load count matrix
countData <- read.table("results/counts.txt",
                        header=TRUE,
                        row.names=1,
                        comment.char="#")

countData <- countData[,6:ncol(countData)]

# Sample information (IMPORTANT)
colData <- data.frame(
  condition = c("control","control","treated","treated")
)
rownames(colData) <- colnames(countData)

# DESeq2 object
dds <- DESeqDataSetFromMatrix(countData, colData, ~condition)

# Run DE analysis
dds <- DESeq(dds)

res <- results(dds)

# Save results
write.csv(as.data.frame(res), "deseq2_results.csv")

# Significant genes
sig <- subset(res, padj < 0.05 & abs(log2FoldChange) > 1)
write.csv(as.data.frame(sig), "significant_genes.csv")
