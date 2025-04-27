#!/bin/bash

#SBATCH --job-name=intersect
#SBATCH -p RM-shared
#SBATCH -t 4:00:00
#SBATCH -n 16
#SBATCH --account bio230007p
#SBATCH --mail-type=ALL

#SBATCH --mail-user=juneq@andrew.cmu.edu
#SBATCH --output slurm_out/intersect.out
#SBATCH --error slurm_out/intersect.err

#echo commands to stdout
set -x

module load bedtools/2.30.0 

output="/ocean/projects/bio230007p/jqu1/bedtools_subset/results/tissues_mouse.bed"

bedtools intersect \
-a /ocean/projects/bio230007p/jqu1/MouseAtac/Liver/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz \
-b /ocean/projects/bio230007p/jqu1/MouseAtac/Pancreas/peak/idr_reproducibility/idr.conservative_peak.narrowPeak.gz \
-u > $output

