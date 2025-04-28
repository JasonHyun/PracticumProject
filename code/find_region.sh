#!/bin/bash

###########################################################
# This script identifies enhancer and promoter regions from
# narrowPeak files for human and mouse liver and pancreas.
# It classifies regions based on distance to TSS:
# - Promoters: within 1kb of TSS
# - Enhancers: between 5kb and 200kb from TSS
###########################################################

# Create output directories
mkdir -p $PROJECT/results/regulatory_elements/mouse/liver
mkdir -p $PROJECT/results/regulatory_elements/mouse/pancreas
mkdir -p $PROJECT/results/regulatory_elements/human/liver
mkdir -p $PROJECT/results/regulatory_elements/human/pancreas

# Load bedtools module
module load bedtools/2.30.0

# Define reference files
MOUSE_TSS="$PROJECT/inputs/TSSRef/gencode.vM15.annotation.protTranscript.geneNames_TSSWithStrand_sorted.bed"
HUMAN_TSS="$PROJECT/inputs/TSSRef/gencode.v27.annotation.protTranscript.geneNames_TSSWithStrand_sorted.bed"

# Define input peak files
MOUSE_LIVER_PEAKS="$PROJECT/inputs/narrowpeaks/mouse/liver/idr.conservative_peak.narrowPeak.gz"
MOUSE_PANCREAS_PEAKS="$PROJECT/inputs/narrowpeaks/mouse/pancreas/idr.conservative_peak.narrowPeak.gz"
HUMAN_LIVER_PEAKS="$PROJECT/inputs/narrowpeaks/human/liver/idr.conservative_peak.narrowPeak.gz"
HUMAN_PANCREAS_PEAKS="$PROJECT/inputs/narrowpeaks/human/pancreas/idr.conservative_peak.narrowPeak.gz"

###########################################################
# Function to process each species-tissue combination
###########################################################
process_peaks() {
    local species=$1
    local tissue=$2
    local peak_file=$3
    local tss_file=$4
    local output_dir="$PROJECT/results/regulatory_elements/${species}/${tissue}"
    
    echo "Processing ${species} ${tissue}..."
    
    # Create temporary decompressed file if input is gzipped
    if [[ $peak_file == *.gz ]]; then
        local temp_file="${output_dir}/temp_peaks.bed"
        gunzip -c "$peak_file" > "$temp_file"
        peak_file="$temp_file"
    fi
    
    # Sort the input file
    local sorted_file="${output_dir}/${species}_${tissue}_sorted.bed"
    bedtools sort -i "$peak_file" > "$sorted_file"
    
    # Find promoters (within 1kb of TSS)
    local promoter_file="${output_dir}/${species}_${tissue}_promoters_1kb.bed"
    bedtools window -a "$sorted_file" -b "$tss_file" -w 1000 > "$promoter_file"
    
    # Find distance to nearest TSS
    local distance_file="${output_dir}/${species}_${tissue}_tss_distance.bed"
    bedtools closest -a "$sorted_file" -b "$tss_file" -D a > "$distance_file"
    
    # Extract enhancers (5kb-200kb from TSS)
    local enhancer_file="${output_dir}/${species}_${tissue}_enhancers_5kb_200kb.bed"
    awk '($NF <= -5000 && $NF >= -200000) || ($NF >= 5000 && $NF <= 200000)' \
        "$distance_file" > "$enhancer_file"
    
    # Remove temporary file if created
    if [[ -f "${output_dir}/temp_peaks.bed" ]]; then
        rm "${output_dir}/temp_peaks.bed"
    fi
    
    echo "  Promoters saved to: $promoter_file"
    echo "  Enhancers saved to: $enhancer_file"
    
    # Count regions
    local promoter_count=$(wc -l < "$promoter_file")
    local enhancer_count=$(wc -l < "$enhancer_file")
    echo "  Found $promoter_count promoters and $enhancer_count enhancers"
}

###########################################################
# Process all species and tissues
###########################################################

# Process mouse liver
process_peaks "mouse" "liver" "$MOUSE_LIVER_PEAKS" "$MOUSE_TSS"

# Process mouse pancreas
process_peaks "mouse" "pancreas" "$MOUSE_PANCREAS_PEAKS" "$MOUSE_TSS"

# Process human liver
process_peaks "human" "liver" "$HUMAN_LIVER_PEAKS" "$HUMAN_TSS"

# Process human pancreas
process_peaks "human" "pancreas" "$HUMAN_PANCREAS_PEAKS" "$HUMAN_TSS"

echo "All regulatory element identification complete."

# For conserved and unique regions, we would also run the following:
# (commented out as these would depend on bedtools results from previous step)

# Process conserved regions for each species-tissue combination
# These would use the conserved BED files from the intersection.sh as input
# process_peaks "mouse" "liver_conserved" "$PROJECT/results/bedtools/conserved/species_liver.bed" "$MOUSE_TSS"
# process_peaks "mouse" "pancreas_conserved" "$PROJECT/results/bedtools/conserved/species_pancreas.bed" "$MOUSE_TSS"
# process_peaks "human" "liver_unique" "$PROJECT/results/bedtools/unique/human_liver_unique.bed" "$HUMAN_TSS"
# process_peaks "human" "pancreas_unique" "$PROJECT/results/bedtools/unique/human_pancreas_unique.bed" "$HUMAN_TSS"