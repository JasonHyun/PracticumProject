#!/bin/bash

# Usage:
# ./find_percent_intersection.sh enhancer1.bed promoter1.bed conserved.bed output_dir/

# bash ./script/find_percent_conservation.sh \
# /Users/junequ/PracticumProject/regulatory_elements/human_full_peak/pancreas/human_pancreas_full_peak_enhancers_5kb_200kb.bed \
# /Users/junequ/PracticumProject/regulatory_elements/human_full_peak/pancreas/human_pancreas_full_peak_promoters_1kb.bed \
# /Users/junequ/PracticumProject/bedtools/conserved_subset/results/species_pancreas.bed \
# /Users/junequ/PracticumProject/conserved_reg_elements/across_species/

# Input files
ENHANCER1=$1    # Full set of enhancers
PROMOTER1=$2    # Full set of promoters
CONSERVED=$3    # Conserved OCR region file
OUTPUT_DIR=$4   # Output directory path (should end with /)

# Make output directory file if not present
mkdir -p "$OUTPUT_DIR"

# Output files (change file name according to tissue-species combination)
ENHANCER_SHARED="$OUTPUT_DIR/conserved_pancreas_enhancers.bed"
PROMOTER_SHARED="$OUTPUT_DIR/conserved_pancreas_promoters.bed"
SUMMARY_OUTPUT="$OUTPUT_DIR/pancreas_human2mouse"

# Intersect full set of enhancers with conserved regions
bedtools intersect -u -a "$ENHANCER1" -b "$CONSERVED" > "$ENHANCER_SHARED"
NUM_REFERENCE_ENHANCER=$(wc -l < "$ENHANCER1")
NUM_SHARED_ENHANCER=$(wc -l < "$ENHANCER_SHARED")

# Intersect full set of promoters with conserved regions
bedtools intersect -u -a "$PROMOTER1" -b "$CONSERVED" > "$PROMOTER_SHARED"
NUM_REFERENCE_PROMOTER=$(wc -l < "$PROMOTER1")
NUM_SHARED_PROMOTER=$(wc -l < "$PROMOTER_SHARED")

# Percent of enhancers conserved
if [ "$NUM_REFERENCE_ENHANCER" -gt 0 ]; then
    ENHANCER_PCT=$(echo "scale=2; 100 * $NUM_SHARED_ENHANCER / $NUM_REFERENCE_ENHANCER" | bc)
else
    ENHANCER_PCT=0
fi

# Percent of promoters conserved
if [ "$NUM_REFERENCE_PROMOTER" -gt 0 ]; then
    PROMOTER_PCT=$(echo "scale=2; 100 * $NUM_SHARED_PROMOTER / $NUM_REFERENCE_PROMOTER" | bc)
else
    PROMOTER_PCT=0
fi

# Output results
{
    echo "Enhancer shared %: $ENHANCER_PCT"
    echo "Promoter shared %: $PROMOTER_PCT"
} > "$SUMMARY_OUTPUT"

echo "Results saved to $SUMMARY_OUTPUT"
echo "Shared enhancer regions saved to $ENHANCER_SHARED"
echo "Shared promoter regions saved to $PROMOTER_SHARED"
