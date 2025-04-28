#!/bin/bash

###########################################################
# Intersection script to find conserved and unique regions 
# between human and mouse liver and pancreas OCRs
# This script uses bedtools to identify:
# 1. Species-conserved regions (human vs mouse)
# 2. Tissue-conserved regions (liver vs pancreas)
# 3. Species-unique regions
###########################################################

# Create output directories
mkdir -p $PROJECT/results/bedtools/conserved
mkdir -p $PROJECT/results/bedtools/unique

# Load bedtools module
module load bedtools/2.30.0

###########################################################
# PART 1: CONSERVED REGIONS BETWEEN SPECIES
###########################################################

echo "Finding conserved OCRs between mouse and human liver..."
# Mouse liver OCRs mapped to human genome vs. Human liver OCRs
bedtools intersect \
-a $PROJECT/results/mapping_mouse2human/liver/Mouse_peaks_mapped_to_Human.bed \
-b $human_liver_peak \
-u | cut -f1-3 > $PROJECT/results/bedtools/conserved/species_liver.bed

echo "Finding conserved OCRs between mouse and human pancreas..."
# Mouse pancreas OCRs mapped to human genome vs. Human pancreas OCRs
bedtools intersect \
-a $PROJECT/results/mapping_mouse2human/pancreas/Mouse_peaks_mapped_to_Human.bed \
-b $human_pancreas_peak \
-u | cut -f1-3 > $PROJECT/results/bedtools/conserved/species_pancreas.bed

###########################################################
# PART 2: CONSERVED REGIONS BETWEEN TISSUES
###########################################################

echo "Finding conserved OCRs between liver and pancreas in mouse..."
# Mouse liver OCRs vs. Mouse pancreas OCRs
bedtools intersect \
-a $mouse_liver_peak \
-b $mouse_pancreas_peak \
-u | cut -f1-3 > $PROJECT/results/bedtools/conserved/tissues_mouse.bed

echo "Finding conserved OCRs between liver and pancreas in human..."
# Human liver OCRs vs. Human pancreas OCRs
bedtools intersect \
-a $human_liver_peak \
-b $human_pancreas_peak \
-u | cut -f1-3 > $PROJECT/results/bedtools/conserved/tissues_human.bed

###########################################################
# PART 3: UNIQUE REGIONS (NOT CONSERVED BETWEEN SPECIES)
###########################################################

echo "Finding unique OCRs in human liver (not conserved with mouse)..."
# Human liver OCRs that don't intersect with mouse-to-human mapped OCRs
bedtools intersect -v \
-a $human_liver_peak \
-b $PROJECT/results/bedtools/conserved/species_liver.bed \
| cut -f1-3 > $PROJECT/results/bedtools/unique/human_liver_unique.bed

echo "Finding unique OCRs in human pancreas (not conserved with mouse)..."
# Human pancreas OCRs that don't intersect with mouse-to-human mapped OCRs
bedtools intersect -v \
-a $human_pancreas_peak \
-b $PROJECT/results/bedtools/conserved/species_pancreas.bed \
| cut -f1-3 > $PROJECT/results/bedtools/unique/human_pancreas_unique.bed

echo "Finding unique OCRs in mouse liver mapped to human (not conserved with human)..."
# Mouse liver OCRs mapped to human that don't intersect with human OCRs
bedtools intersect -v \
-a $PROJECT/results/mapping_mouse2human/liver/Mouse_peaks_mapped_to_Human.bed \
-b $PROJECT/results/bedtools/conserved/species_liver.bed \
| cut -f1-3 > $PROJECT/results/bedtools/unique/mouse_liver_unique.bed

echo "Finding unique OCRs in mouse pancreas mapped to human (not conserved with human)..."
# Mouse pancreas OCRs mapped to human that don't intersect with human OCRs
bedtools intersect -v \
-a $PROJECT/results/mapping_mouse2human/pancreas/Mouse_peaks_mapped_to_Human.bed \
-b $PROJECT/results/bedtools/conserved/species_pancreas.bed \
| cut -f1-3 > $PROJECT/results/bedtools/unique/mouse_pancreas_unique.bed

echo "Bedtools intersection analysis complete."