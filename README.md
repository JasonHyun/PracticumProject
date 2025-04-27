# Open Chromatin Region Study of Liver and Pancreas

## Introduction
This is a project for the course 03713: Bioinformatics Data Integration Practicum from Carnegie Mellon University, with purpose of analyzing open chromatin regions across species of human and mouse. The project aims to evaluate the extent of conservation of involved regulatory elements across species and tissues, and to understand how these conserved regions may influence tissue-specific gene regulation. 

## Workflow
<img width="452" alt="pipeline_design" src="https://github.com/user-attachments/assets/1ad958dc-a9ed-4cbf-944c-b763f1eae44a" />

### Step 1: Obtaining raw peak data and QC reports analyses:
The original datasets for alternate adrenal gland, liver, and pancreas tissues were provided as conservative peak files of ATAC-Seq from the project pathway of bridges2. These are also available under the data folder in the repository, along with respective QC reports that contributed to data quality assessments of the three tissues. Because the criteria of the project suggests to work with data of two tissues of highest integrity, the data for adrenal gland has been discarded.

### Step 2: Mapping mouse open chromatin regions to human using HALPER:
The narrowpeak files containing mouse open chromatin regions were loaded into HALPER to map to human genome. At this step, HALPER tasks were submitted to and run on an RM-Shared node in PSC (Pittsburgh Supercomputing Center). For better computating efficiency, 16 cores and 32GB memory were requested. The open chromatin regions in mouse liver and pancreas were mapped into human genome. 
The input files for this step are the mouse narrowPeak files for pancrease and liver tissues, located in the `data/` directory. The outputs for this step are the human genome-aligned peak files that are stored in the  `HALPER_output/` directory. HALPER run logs, such as `pancreas_run.out`, were also outputted and they could be utilized to the track runtime details and verify completed tasks, allowing the mapping of mouse open chromatin regions to the human genome.

### Step 3: Intersection to derive overlapping and unique regions:
Each combination of mapped regions of mouse liver and pancreas are compared with their respective tissues in humans, specifically through use of bedtools. Two separate bins of batch of files yield results for overlapping regions and unique regions, respectively, between mouse and human. These outputs are then processed through Step 4. 
The inputs for this step were the HALPER-mapped mouse peak files in human genome coordinates from the `HALPER_output/` directory, and the human ATAC-seq narrowPeak files located in the `data/` directory. These datasets were also systematically compared using `bedtools intersect`. The outputs for each tissue were generated as overlapping regions or unique regions. Overlapping regions refer to where the mouse and human open chromatin regions intersect, which suggest conservation in regulatory elements. Unique regions are only present in one of the species, which indivates possible species-specific regulation. These outputs are presented as BED files and are located in the `bedtools/` directory. 

### Step 4: Functional enrichment analysis:
An online tool, GREAT, was used to apply functional enrichment analysis. The open chromatin regions that were, respectively, unique to organs or organisms, conservative across organs or organisms, were put into GREAT for obtaining GO terms where the peaks enriched in. The outputs can be found under the corresponding folder, which are utilized to distinguish promoters from enhancers based from TSS distance graphs.
The inputs are the BED files from Step 3. This includes unique regions of both mouse and human tissues. The BED files also includes the overlapping regions, or the conserved regions shared between species. The files for the conserved regions are distinguised by tissue type (liver or pancreas) and by region type (unique or overlapping), and they were submitted to GREAT using the huamn genome assembly `GRCh38`. The outputs from GREAT are the enriched GO terms for each dataset, graphs that depict the distribution of genomic regions relative to transcription start sites which allows for classifcation of promotor or enhancer regions, and region-to-gene association tables with the following rules: basal + extension: 5kb upstream and 1kb downstream, up to 1Mb max extension. These output files are located in the `GREAT_output/` directory. 

### Step 5: MEME Suite
To identify motifs in regulatory regions, OCRs were divided into potential enhancer and promoter genomic regions based on their distance from human TSS regions. Regions within 1kb were classified as potential promoter regions and regions between 5kb and 20kb were classified as potential enhancers. Resulting genomic regions were mapped to the human genome to obtain corresponding enhancer and promoter sequences and duplicated sequences were removed. MEME-ChIP analysis was performed using the results for each tissue-organism combination and the outputs can be found under the meme_chip_outputs directory. All MEME-ChIP analyses were run using `-meme-nmotifs 3`, `-minw 6 `, `-maxw 20` and `db JASPAR2022_CORE_non-redundant_pfms_meme.txt`.

## Tools
NOTE: the use of the packages as HALPER, bedtools, and MEME Suite are done through the modules of the cluster; we did not install dependencies to our local devices.
- HALPER (https://github.com/pfenninglab/halLiftover-postprocessing)
- bedtools (https://bedtools.readthedocs.io/en/latest/)
- GREAT (https://great.stanford.edu/great/public/html/)
- MEME Suite (https://meme-suite.org/meme/)

## References
1. MEME: Timothy L. Bailey, Mikael Boden, Fabian A. Buske, Martin Frith, Charles E. Grant, Luca Clementi, Jingyuan Ren, Wilfred W. Li, William S. Noble, MEME Suite: tools for motif discovery and searching, Nucleic Acids Research, Volume 37, Issue suppl_2, 1 July 2009, Pages W202–W208, https://doi.org/10.1093/nar/gkp335
2. Bedtools: Aaron R. Quinlan, Ira M. Hall, BEDTools: a flexible suite of utilities for comparing genomic features, Bioinformatics, Volume 26, Issue 6, March 2010, Pages 841–842, https://doi.org/10.1093/bioinformatics/btq033
3. Halper: Xiaoyu Zhang, Irene Kaplow, Morgan Wirthlin, Tyler Park, Andreas Pfenning. HALPER facilitates the identification of regulatory element orthologs across species. Bioinformatics, Volume 36, Issue 15, 1 August 2020, Pages 4339-4340.
4. GREAT: McLean, C., Bristor, D., Hiller, M. et al. GREAT improves functional interpretation of cis-regulatory regions. Nat Biotechnol 28, 495–501 (2010). https://doi.org/10.1038/nbt.1630



## Contributors
Jason Hyun, Jessica Vu, Deyuan Xu, June Qu
