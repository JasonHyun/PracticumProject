#!/bin/bash

###########################################################
# Script to perform motif analysis on regulatory elements
# This script:
# 1. Converts BED files to FASTA using reference genome
# 2. Runs MEME-ChIP to identify enriched motifs
###########################################################

# Create output directories
mkdir -p $PROJECT/results/motif_analysis/fasta
mkdir -p $PROJECT/results/motif_analysis/meme_chip

# Load necessary modules
module load bedtools/2.30.0
module load meme/5.4.1

# Define reference genomes and motif database
HUMAN_GENOME="/ocean/projects/bio230007p/shared/genomes/human_GRCh38/GRCh38.primary_assembly.genome.fa"
MOTIF_DB="/ocean/projects/bio230007p/ikaplow/motif_database/JASPAR2022_CORE_non-redundant_pfms_meme.txt"

# Verify files exist
if [ ! -f "$HUMAN_GENOME" ]; then
    echo "ERROR: Human reference genome not found: $HUMAN_GENOME"
    exit 1
fi

if [ ! -f "$MOTIF_DB" ]; then
    echo "ERROR: Motif database not found: $MOTIF_DB"
    exit 1
fi

# Function to process each regulatory element file
process_reg_element() {
    local input_bed=$1
    local element_type=$2    # promoter or enhancer
    local context=$3         # e.g., human_tissues_conserved
    
    echo "Processing $context $element_type..."
    
    # Extract basename for output naming
    local basename="${context}_${element_type}"
    
    # Create FASTA file from BED
    local fasta_out="$PROJECT/results/motif_analysis/fasta/${basename}.fa"
    bedtools getfasta -fi "$HUMAN_GENOME" -bed "$input_bed" -fo "$fasta_out" -name
    
    echo "  Created FASTA file: $fasta_out"
    
    # Run MEME-ChIP
    local meme_out="$PROJECT/results/motif_analysis/meme_chip/${basename}"
    
    echo "  Running MEME-ChIP analysis..."
    meme-chip -oc "$meme_out" \
              -db "$MOTIF_DB" \
              -meme-p 4 \
              -meme-minw 6 \
              -meme-maxw 15 \
              -meme-nmotifs 5 \
              -dreme-e 0.05 \
              -centrimo-score 5 \
              -centrimo-ethresh 10 \
              "$fasta_out"
    
    echo "  MEME-ChIP analysis complete for $basename"
    echo "  Results saved to: $meme_out"
}

###########################################################
# Process conserved regions
###########################################################

echo "=== Running motif analysis on conserved regions ==="

# Tissues conserved in human
process_reg_element "$PROJECT/results/regulatory_classification/conserved/human_tissues_conserved_promoters.bed" "promoters" "human_tissues_conserved"
process_reg_element "$PROJECT/results/regulatory_classification/conserved/human_tissues_conserved_enhancers.bed" "enhancers" "human_tissues_conserved"

# Tissues conserved in mouse
process_reg_element "$PROJECT/results/regulatory_classification/conserved/mouse_tissues_conserved_promoters.bed" "promoters" "mouse_tissues_conserved"
process_reg_element "$PROJECT/results/regulatory_classification/conserved/mouse_tissues_conserved_enhancers.bed" "enhancers" "mouse_tissues_conserved"

# Species conserved in liver
process_reg_element "$PROJECT/results/regulatory_classification/conserved/species_liver_conserved_promoters.bed" "promoters" "species_liver_conserved"
process_reg_element "$PROJECT/results/regulatory_classification/conserved/species_liver_conserved_enhancers.bed" "enhancers" "species_liver_conserved"

# Species conserved in pancreas
process_reg_element "$PROJECT/results/regulatory_classification/conserved/species_pancreas_conserved_promoters.bed" "promoters" "species_pancreas_conserved"
process_reg_element "$PROJECT/results/regulatory_classification/conserved/species_pancreas_conserved_enhancers.bed" "enhancers" "species_pancreas_conserved"

###########################################################
# Process unique regions
###########################################################

echo "=== Running motif analysis on unique regions ==="

# Human liver unique
process_reg_element "$PROJECT/results/regulatory_classification/unique/human_liver_unique_promoters.bed" "promoters" "human_liver_unique"
process_reg_element "$PROJECT/results/regulatory_classification/unique/human_liver_unique_enhancers.bed" "enhancers" "human_liver_unique"

# Human pancreas unique
process_reg_element "$PROJECT/results/regulatory_classification/unique/human_pancreas_unique_promoters.bed" "promoters" "human_pancreas_unique"
process_reg_element "$PROJECT/results/regulatory_classification/unique/human_pancreas_unique_enhancers.bed" "enhancers" "human_pancreas_unique"

echo "Motif analysis complete."
echo "Results saved to $PROJECT/results/motif_analysis/"