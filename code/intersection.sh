#!/bin/bash

###########################################################
# Intersection script to find conserved and unique regions 
# between human and mouse liver and pancreas OCRs
# This script uses bedtools to identify:
# 1. Species-conserved regions (human vs mouse)
# 2. Tissue-conserved regions (liver vs pancreas)
# 3. Species-unique regions
# All columns are preserved in primary outputs
# Simplified versions (chr,start,end) are created for GREAT
###########################################################

# Create output directories
mkdir -p $PROJECT/results/bedtools/conserved
mkdir -p $PROJECT/results/bedtools/unique
mkdir -p $PROJECT/results/bedtools/simplified

# Load bedtools module
module load bedtools/2.30.0

###########################################################
# Define direct paths to input files
###########################################################

# Original narrowPeak files
MOUSE_LIVER_PEAK="$PROJECT/inputs/narrowpeaks/mouse/liver/idr.conservative_peak.narrowPeak.gz"
MOUSE_PANCREAS_PEAK="$PROJECT/inputs/narrowpeaks/mouse/pancreas/idr.conservative_peak.narrowPeak.gz"
HUMAN_LIVER_PEAK="$PROJECT/inputs/narrowpeaks/human/liver/idr.conservative_peak.narrowPeak.gz"
HUMAN_PANCREAS_PEAK="$PROJECT/inputs/narrowpeaks/human/pancreas/idr.conservative_peak.narrowPeak.gz"

# HALPER output files with their correct filenames
MOUSE_LIVER_HALPER="$PROJECT/results/mapping_mouse2human/liver/idr.conservative_peak.MouseToHuman.HALPER.narrowPeak.gz"
MOUSE_PANCREAS_HALPER="$PROJECT/results/mapping_mouse2human/pancreas/idr.conservative_peak.MouseToHuman.HALPER.narrowPeak.gz"

# Verify files exist
echo "Checking input files..."
for file in "$MOUSE_LIVER_PEAK" "$MOUSE_PANCREAS_PEAK" "$HUMAN_LIVER_PEAK" "$HUMAN_PANCREAS_PEAK" "$MOUSE_LIVER_HALPER" "$MOUSE_PANCREAS_HALPER"; do
    if [ ! -f "$file" ]; then
        echo "ERROR: File not found: $file"
        exit 1
    fi
    echo "Found: $file"
done

###########################################################
# PART 1: CONSERVED REGIONS BETWEEN SPECIES
###########################################################

echo "Finding conserved OCRs between mouse and human liver..."
# Mouse liver OCRs mapped to human genome vs. Human liver OCRs
bedtools intersect \
-a "$MOUSE_LIVER_HALPER" \
-b "$HUMAN_LIVER_PEAK" \
-u > $PROJECT/results/bedtools/conserved/species_liver.bed

echo "Finding conserved OCRs between mouse and human pancreas..."
# Mouse pancreas OCRs mapped to human genome vs. Human pancreas OCRs
bedtools intersect \
-a "$MOUSE_PANCREAS_HALPER" \
-b "$HUMAN_PANCREAS_PEAK" \
-u > $PROJECT/results/bedtools/conserved/species_pancreas.bed

###########################################################
# PART 2: CONSERVED REGIONS BETWEEN TISSUES
###########################################################

echo "Finding conserved OCRs between liver and pancreas in mouse..."
# Mouse liver OCRs vs. Mouse pancreas OCRs
bedtools intersect \
-a "$MOUSE_LIVER_PEAK" \
-b "$MOUSE_PANCREAS_PEAK" \
-u > $PROJECT/results/bedtools/conserved/tissues_mouse.bed

echo "Finding conserved OCRs between liver and pancreas in human..."
# Human liver OCRs vs. Human pancreas OCRs
bedtools intersect \
-a "$HUMAN_LIVER_PEAK" \
-b "$HUMAN_PANCREAS_PEAK" \
-u > $PROJECT/results/bedtools/conserved/tissues_human.bed

###########################################################
# PART 3: UNIQUE REGIONS (NOT CONSERVED BETWEEN SPECIES)
###########################################################

echo "Finding unique OCRs in human liver (not conserved with mouse)..."
# Human liver OCRs that don't intersect with mouse-to-human mapped OCRs
bedtools intersect -v \
-a "$HUMAN_LIVER_PEAK" \
-b $PROJECT/results/bedtools/conserved/species_liver.bed \
> $PROJECT/results/bedtools/unique/human_liver_unique.bed

echo "Finding unique OCRs in human pancreas (not conserved with mouse)..."
# Human pancreas OCRs that don't intersect with mouse-to-human mapped OCRs
bedtools intersect -v \
-a "$HUMAN_PANCREAS_PEAK" \
-b $PROJECT/results/bedtools/conserved/species_pancreas.bed \
> $PROJECT/results/bedtools/unique/human_pancreas_unique.bed

echo "Finding unique OCRs in mouse liver mapped to human (not conserved with human)..."
# Mouse liver OCRs mapped to human that don't intersect with human OCRs
bedtools intersect -v \
-a "$MOUSE_LIVER_HALPER" \
-b $PROJECT/results/bedtools/conserved/species_liver.bed \
> $PROJECT/results/bedtools/unique/mouse_liver_unique.bed

echo "Finding unique OCRs in mouse pancreas mapped to human (not conserved with human)..."
# Mouse pancreas OCRs mapped to human that don't intersect with human OCRs
bedtools intersect -v \
-a "$MOUSE_PANCREAS_HALPER" \
-b $PROJECT/results/bedtools/conserved/species_pancreas.bed \
> $PROJECT/results/bedtools/unique/mouse_pancreas_unique.bed

###########################################################
# PART 4: CREATE SIMPLIFIED BED FILES FOR GREAT ANALYSIS
###########################################################

echo "Creating simplified BED files (chr, start, end only) for GREAT analysis..."

# Process conserved files
for file in $PROJECT/results/bedtools/conserved/*.bed; do
    filename=$(basename "$file")
    cut -f1-3 "$file" > "$PROJECT/results/bedtools/simplified/${filename%.bed}_simplified.bed"
    echo "Created simplified version of $(basename "$file")"
done

# Process unique files
for file in $PROJECT/results/bedtools/unique/*.bed; do
    filename=$(basename "$file")
    cut -f1-3 "$file" > "$PROJECT/results/bedtools/simplified/${filename%.bed}_simplified.bed"
    echo "Created simplified version of $(basename "$file")"
done

# Count regions in each file and report
echo "Counting regions in result files..."
echo "Full files (with all columns):"
for file in $PROJECT/results/bedtools/conserved/*.bed $PROJECT/results/bedtools/unique/*.bed; do
    count=$(wc -l < "$file")
    echo "$(basename "$file"): $count regions"
done

echo "Simplified files (for GREAT):"
for file in $PROJECT/results/bedtools/simplified/*.bed; do
    count=$(wc -l < "$file")
    echo "$(basename "$file"): $count regions"
done

echo "Bedtools intersection analysis complete."