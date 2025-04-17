# Open Chromatin Region Study of Liver and Pancreas

## Introduction
This is a project for the course 03713: Bioinformatics Data Integration Practicum from Carnegie Mellon University, with purpose of analyzing open chromatin regions across species of human and mouse. The project aims to evaluate the extent of conservation of involved regulatory elements across species and tissues, and to understand how these conserved regions may influence tissue-specific gene regulation. 

## Workflow
<img width="452" alt="pipeline_design" src="https://github.com/user-attachments/assets/1ad958dc-a9ed-4cbf-944c-b763f1eae44a" />

### Step 1: Obtaining raw peak data and QC reports analyses:
The original datasets for alternate adrenal gland, liver, and pancreas tissues were provided as conservative peak files of ATAC-Seq from the project pathway of bridges2. These are also available under the data folder in the repository, along with respective QC reports that contributed to data quality assessments of the three tissues. Because the criteria of the project suggests to work with data of two tissues of highest integrity, the data for adrenal gland has been discarded.

### Step 2: Mapping mouse open chromatin regions to human using HALPER:
The narrowpeak files containing mouse open chromatin regions were loaded into HALPER to map to human genome. At this step, HALPER tasks were submitted to and run on an RM-Shared node in PSC (Pittsburgh Supercomputing Center). For better computating efficiency, 16 cores and 32GB memory were requested. The open chromatin regions in mouse liver and pancreas were mapped into human genome.

### Step 3: Intersection to derive overlapping and unique regions:
Each combination of mapped regions of mouse liver and pancreas are compared with their respective tissues in humans, specifically through use of bedtools. Two separate bins of batch of files yield results for overlapping regions and unique regions, respectively, between mouse and human. These outputs are then processed through Step 4. 

### Step 4: Functional enrichment analysis:
An online tool, GREAT, was used to apply functional enrichment analysis. The open chromatin regions that were, respectively, unique to organs or organisms, conservative across organs or organisms, were put into GREAT for obtaining GO terms where the peaks enriched in. The outputs can be found under the corresponding folder, which are utilized to distinguish promoters from enhancers based from TSS distance graphs.

### Step 5: MEME Suite
To identify motifs in regulatory regions, OCRs were divided into potential enhancer and promoter genomic regions based on their distance from human TSS regions. Regions within 1kb were classified as potential promoter regions and regions between 5kb and 20kb were classified as potential enhancers. Resulting genomic regions were mapped to the human genome to obtain corresponding enhancer and promoter sequences and duplicated sequences were removed. MEME-ChIP analysis was performed using the results for each tissue-organism combination and the outputs can be found under the meme_chip_outputs directory. All MEME-ChIP analyses were run using `-meme-nmotifs 3`, `-minw 6 `, `-maxw 20` and `db JASPAR2022_CORE_non-redundant_pfms_meme.txt`.

## Tools
NOTE: the use of the packages as HALPER, bedtools, and MEME Suite are done through the modules of the cluster; we did not install dependencies to our local devices.
- HALPER (https://github.com/pfenninglab/halLiftover-postprocessing)
- bedtools (https://bedtools.readthedocs.io/en/latest/)
- GREAT (https://great.stanford.edu/great/public/html/)
- MEME Suite (https://meme-suite.org/meme/)

  


## Contributors
Jason Hyun, Jessica Vu, Deyuan Xu, June Qu
