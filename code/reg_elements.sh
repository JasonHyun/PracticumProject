#!/bin/bash

###########################################################
# Script to classify conserved and unique regions as either
# promoters or enhancers based on distance to nearest TSS
# - Promoters: regions within 5kb of a TSS
# - Enhancers: regions further than 5kb from a TSS
###########################################################

# Create output directories
mkdir -p $PROJECT/results/regulatory_classification/conserved
mkdir -p $PROJECT/results/regulatory_classification/unique

# Load bedtools module
module load bedtools/2.30.0

# Define TSS reference files
HUMAN_TSS="$PROJECT/inputs/TSSRef/gencode.v27.annotation.protTranscript.geneNames_TSSWithStrand_sorted.bed"
MOUSE_TSS="$PROJECT/inputs/TSSRef/gencode.vM15.annotation.protTranscript.geneNames_TSSWithStrand_sorted.bed"

# Verify TSS files exist
if [ ! -f "$HUMAN_TSS" ]; then
    echo "ERROR: Human TSS reference file not found: $HUMAN_TSS"
    exit 1
fi

if [ ! -f "$MOUSE_TSS" ]; then
    echo "ERROR: Mouse TSS reference file not found: $MOUSE_TSS"
    exit 1
fi

###########################################################
# Function to classify regions as promoters or enhancers
###########################################################
classify_regions() {
    local input_file=$1
    local tss_file=$2
    local output_prefix=$3
    local category=$4  # conserved or unique
    
    echo "Processing $(basename "$input_file")..."
    
    # Create directory if it doesn't exist
    mkdir -p "$PROJECT/results/regulatory_classification/$category"
    
    # Find distance to nearest TSS
    local distance_file="$PROJECT/results/regulatory_classification/$category/${output_prefix}_tss_distance.bed"
    bedtools closest -a "$input_file" -b "$tss_file" -d > "$distance_file"
    
    # Extract promoters (within 5kb of TSS)
    local promoter_file="$PROJECT/results/regulatory_classification/$category/${output_prefix}_promoters.bed"
    awk '$NF != -1 && $NF <= 5000' "$distance_file" > "$promoter_file"
    
    # Extract enhancers (>5kb from TSS)
    local enhancer_file="$PROJECT/results/regulatory_classification/$category/${output_prefix}_enhancers.bed"
    awk '$NF == -1 || $NF > 5000' "$distance_file" > "$enhancer_file"
    
    # Count regions
    local total_count=$(wc -l < "$input_file")
    local promoter_count=$(wc -l < "$promoter_file")
    local enhancer_count=$(wc -l < "$enhancer_file")
    local promoter_pct=$(awk -v p=$promoter_count -v t=$total_count 'BEGIN{printf "%.2f", (p/t)*100}')
    
    echo "  Total regions: $total_count"
    echo "  Promoters: $promoter_count ($promoter_pct%)"
    echo "  Enhancers: $enhancer_count ($(awk -v p=$promoter_pct 'BEGIN{printf "%.2f", 100-p}')%)"
    
    # Create a summary file
    local summary_file="$PROJECT/results/regulatory_classification/$category/${output_prefix}_summary.txt"
    {
        echo "Classification summary for $(basename "$input_file")"
        echo "Total regions: $total_count"
        echo "Promoters: $promoter_count ($promoter_pct%)"
        echo "Enhancers: $enhancer_count ($(awk -v p=$promoter_pct 'BEGIN{printf "%.2f", 100-p}')%)"
    } > "$summary_file"
}

###########################################################
# Process conserved regions across tissues
###########################################################

echo "=== Classifying regions conserved across tissues ==="

# Human tissues conserved regions (use human TSS)
classify_regions \
    "$PROJECT/results/bedtools/conserved/tissues_human.bed" \
    "$HUMAN_TSS" \
    "human_tissues_conserved" \
    "conserved"

# Mouse tissues conserved regions (use mouse TSS)
classify_regions \
    "$PROJECT/results/bedtools/conserved/tissues_mouse.bed" \
    "$MOUSE_TSS" \
    "mouse_tissues_conserved" \
    "conserved"

###########################################################
# Process conserved regions across species
###########################################################

echo "=== Classifying regions conserved across species ==="

# Liver regions conserved across species (use human TSS since mapped to human)
classify_regions \
    "$PROJECT/results/bedtools/conserved/species_liver.bed" \
    "$HUMAN_TSS" \
    "species_liver_conserved" \
    "conserved"

# Pancreas regions conserved across species (use human TSS since mapped to human)
classify_regions \
    "$PROJECT/results/bedtools/conserved/species_pancreas.bed" \
    "$HUMAN_TSS" \
    "species_pancreas_conserved" \
    "conserved"

###########################################################
# Process unique regions
###########################################################

echo "=== Classifying unique regions ==="

# Human liver unique regions (use human TSS)
classify_regions \
    "$PROJECT/results/bedtools/unique/human_liver_unique.bed" \
    "$HUMAN_TSS" \
    "human_liver_unique" \
    "unique"

# Human pancreas unique regions (use human TSS)
classify_regions \
    "$PROJECT/results/bedtools/unique/human_pancreas_unique.bed" \
    "$HUMAN_TSS" \
    "human_pancreas_unique" \
    "unique"

echo "Regulatory element classification complete."
echo "Results saved to $PROJECT/results/regulatory_classification/"