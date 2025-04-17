#!/bin/bash

#SBATCH --job-name=find_seq
#SBATCH -p RM-shared
#SBATCH -t 4:00:00
#SBATCH -n 16
#SBATCH --account bio230007p
#SBATCH --mail-type=ALL

#SBATCH --mail-user=juneq@andrew.cmu.edu
#SBATCH --output slurm_out/find_seq.out
#SBATCH --error slurm_out/find_seq.err

module load bedtools

cd /ocean/projects/bio230007p/jqu1/human_genome

# get enhancer/promoter sequences (mapped to human genome)
genome="/ocean/projects/bio230007p/jqu1/human_genome/hg38.fa"
regions="/ocean/projects/bio230007p/jqu1/bedtools_closest/pancreas_species_regions/pancreas_species_promoters_1kb.bed"
output1="/ocean/projects/bio230007p/jqu1/bedtools_closest/pancreas_species_seqs/pancreas_species_promoters_seq.fa"
output2="/ocean/projects/bio230007p/jqu1/bedtools_closest/pancreas_species_seqs/pancreas_species_promoters_uniq.fa"

bedtools getfasta -fi $genome \
 -bed $regions -fo $output1

 awk '
  /^>/ {
    if (++count[$0] == 1) {
      header = $0;
      getline seq;
      seqs[header] = seq;
    }
  }
  END {
    for (h in count) {
      if (count[h] == 1) {
        print h "\n" seqs[h];
      }
    }
  }
' $output1 > $output2






