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

cd /ocean/projects/bio230007p/jqu1/bedtools_closest/pancreas_species_regions

input="/ocean/projects/bio230007p/jqu1/bedtools_subset/results/species_pancreas_parsed.bed"
TSS="/ocean/projects/bio230007p/jqu1/human_genome/gencode.v27.annotation.protTranscript.TSSsWithStrand_sorted.bed"

# promoters (within 1kb)
bedtools window -a $input -b $TSS -w 1000 > pancreas_species_promoters_1kb.bed

# enhancers (within 5kb-200kb)

bedtools closest -a $input -b $TSS -D a > pancreas_species_tss_distance.bed

# filter out regions between 5kb-200kb upstream and downstream (likely enhancers)
awk '($NF <= -5000 && $NF >= -200000) || ($NF >= 5000 && $NF <= 200000)' pancreas_species_tss_distance.bed > pancreas_species_enhancers_5kb_200kb.bed
