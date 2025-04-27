#!/bin/bash

#SBATCH --job-name=bedtools_test
#SBATCH -p RM-shared
#SBATCH -t 4:00:00
#SBATCH -n 16
#SBATCH --account bio230007p
#SBATCH --mail-type=ALL
#SBATCH --mail-user=juneq@andrew.cmu.edu
#SBATCH --output slurm_out/bedtools_test.out
#SBATCH --error slurm_out/bedtools_test.err

module load bedtools

cd /Users/junequ/PracticumProject/regulatory_elements/mouse_full_peak

# input: .gz file (or .bed file directly) of genomic regions to separate out enhancer and promoters
input1="/ocean/projects/bio230007p/jqu1/MouseAtac/Pancreas/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz"
input="/ocean/projects/bio230007p/jqu1/MouseAtac/Pancreas/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.bed"

# Decompress file
gunzip -c "$input1" > "$input"

TSS="/ocean/projects/bio230007p/jqu1/mouse_genome/gencode.vM15.annotation.protTranscript.geneNames_TSSWithStrand_sorted.bed"

sortedInput="mouse_pancreas_full_peak_unique_sorted.bed"
bedtools sort -i "$input" > "$sortedInput"

# Promoters (within 1kb)
bedtools window -a "$sortedInput" -b "$TSS" -w 1000 > mouse_pancreas_full_peak_promoters_1kb.bed

# Enhancers (within 5kb-200kb)
bedtools closest -a "$sortedInput" -b "$TSS" -D a > mouse_pancreas_tss_distance.bed

awk '($NF <= -5000 && $NF >= -200000) || ($NF >= 5000 && $NF <= 200000)' \
  mouse_pancreas_tss_distance.bed > mouse_pancreas_full_peak_enhancers_5kb_200kb.bed
