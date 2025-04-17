#!/bin/bash

cd /ocean/projects/bio230007p/jqu1/bedtools_closest

input="/ocean/projects/bio230007p/jqu1/bedtools_closest/seqs/liver_species_enhancers_seq.fa"

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
' $input > liver_species_enhancers_seq_unique_headers_v2.fa
