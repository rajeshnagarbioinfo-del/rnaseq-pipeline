#!/bin/bash

# RNA-Seq PIPELINE 

set -e

echo "Starting RNA-Seq Analysis..."
mkdir -p qc aligned reference results 
# Step 1: SRA Download
echo "Downloading SRA..."
prefetch SRR37232210
fasterq-dump SRR37232210 -e 8 --split-files

# Step 2: QC
echo "Running FastQC..."
fastqc SRR37232210_1.fastq SRR37232210_2.fastq -o qc/

multiqc qc/ -o qc/

# Step 3: Trimming
echo "Trimming reads..."
trimmomatic PE -threads 8 \
SRR37232210_1.fastq SRR37232210_2.fastq \
R1_paired.fq R1_unpaired.fq \
R2_paired.fq R2_unpaired.fq \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 \
SLIDINGWINDOW:4:20 MINLEN:50

# Step 4: Post QC
fastqc R1_paired.fq R2_paired.fq -o qc/
multiqc qc/ -o qc/

# Step 5: STAR Index 
STAR --runThreadN 8 \
--runMode genomeGenerate \
--genomeDir star_index \
--genomeFastaFiles reference/genome.fa \
--sjdbGTFfile reference/annotation.gtf \
--sjdbOverhang 100

# Step 6: Alignment
STAR --runThreadN 8 \
--genomeDir star_index \
--readFilesIn R1_paired.fq R2_paired.fq \
--outFileNamePrefix aligned/sample_ \
--outSAMtype BAM SortedByCoordinate \
--quantMode GeneCounts

# step 7: BAM Indexing 
mv aligned/sample_Aligned.sortedByCoord.out.bam aligned.bam
samtools index aligned.bam


# step 8: Alignment QC
samtools flagstat aligned > qc/flagstat.txt
samtools stats aligned.bam > qc/stats.txt


# step 9: gene counting
featureCounts -T 8 \
-a annotation.gtf \
-o counts.txt \
aligned.bam


echo "Pipeline Completed Successfully!"
/