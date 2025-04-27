#!/bin/bash

#SBATCH --job-name=meme_chip
#SBATCH -p RM-shared
#SBATCH -t 4:00:00
#SBATCH -n 16
#SBATCH --account bio230007p
#SBATCH --mail-type=ALL

#SBATCH --mail-user=juneq@andrew.cmu.edu
#SBATCH --output slurm_out/meme_chip.out
#SBATCH --error slurm_out/meme_chip.err

module load MEME-suite

cd /ocean/projects/bio230007p/jqu1/meme_chip/

# Input FASTA 
input="/ocean/projects/bio230007p/jqu1/bedtools_closest/seqs/liver_species_enhancers_seq_unique.fa"

# background model generated with fasta-get-markov
# background="/ocean/projects/bio230007p/jqu1/background_models/human_enhancer_background_model.txt"

# Output directory
output_dir="meme_chip_out"
mkdir -p $output_dir

# Run meme-chip
meme-chip -oc $output_dir \
  -dna \
  -meme-mod zoops \
  -meme-nmotifs 3 \
  -minw 6 \
  -maxw 20 \
  -db /ocean/projects/bio230007p/jqu1/motif_database/JASPAR2022_CORE_non-redundant_pfms_meme.txt \
  $input
