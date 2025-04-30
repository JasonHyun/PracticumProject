# Open Chromatin Region Study of Liver and Pancreas

## Introduction
This is a project for the course 03713: Bioinformatics Data Integration Practicum from Carnegie Mellon University, with purpose of analyzing open chromatin regions across species of human and mouse. The project aims to evaluate the extent of conservation of involved regulatory elements across species and tissues, and to understand how these conserved regions may influence tissue-specific gene regulation. 

## Workflow
<img width="452" alt="pipeline_design" src="https://github.com/user-attachments/assets/1ad958dc-a9ed-4cbf-944c-b763f1eae44a" />

### Step 1: Obtaining raw peak data and QC reports analyses:
The original datasets for liver and pancreas tissues were provided as conservative peak files of ATAC-Seq from the project pathway of bridges2. These are also available under the inputs folder in the repository, along with respective QC reports that contributed to data quality assessments of the three tissues. Because the criteria of the project suggests to work with data of two tissues of highest integrity, the data for adrenal gland has been discarded for the remainder of the pipeline. 

### Step 2: Mapping mouse open chromatin regions to human using HALPER:
The first part of the pipeline loads the narrowpeak files containing mouse open chromatin regions into HALPER to map them to the human genome. At this step, HALPER tasks were submitted to and run on an RM-Shared node in PSC (Pittsburgh Supercomputing Center). For better computating efficiency, 16 cores and 32GB memory were requested. The outputs are then saved under `results/mapping_mouse2human`. 

### Step 3: Intersection to derive overlapping and unique regions:
After step 1, the pipeline employs an intermediate script `intersection.sh` in order to analyze overlapping regions across species in tissues, as well as across tissues in each species; it also outputs regions that are unique to each tissue and species. This process is done by using both outputs from Step 2 and original peak files as inputs, where overlapping regions suggest conservation in regulatory elements. Similarly, unique regions indicates potentially species-specific regulation processes. These results are then sorted accordingly under `results/bedtools`.

### Step 4: Functional enrichment analysis:
An online tool, GREAT, was used to apply functional enrichment analysis and compute enhancer and promoter percentages for each given context. The open chromatin regions that were conserved across tissues or species, or unique to species or tissues, were put into GREAT for obtaining GO terms where the peaks enriched in; these files are the outputs from the previous step of running bedtools (Step 3). The corresponding outputs can be found under the `results/GREAT`, from which the percentage of regulatory elements local to each context (e.g., across tissues in same species) were calculated using the values from the absolute distance to TSS barplots. 

### Step 5: Regulatory elements analysis:
The pipeline then employs an intermediate script `reg_elements.sh` in order to derive the list of involved enhancers and promoters from each of conserved and unique regions across tissues and species using bedtools closest. The script specifically uses the outputs from Step 3 and the TSS reference files under `inputs/TSSRef` as inputs in order to find the list of regulatory elements for each context. In accordance from the previous step, we define the elements within 5 kb from TSS as promoters and the rest as enhancers. 

NOTE: Because the script relies on the bedtools module and updated outputs of Step 3 from the bridges2 server, we are currently unable to test the functional integrity of `reg_elements.sh`, as the server is not available (4/30/2025, 4:00 p.m.)

### Step 6: MEME Suite
The pipeline then finally uses MEME Suite to identify common motifs from regulatory elements, the list of enhancers and promoters derived from Step 5 are used as inputs for motif analysis.

FROM PRELIMINARY RESULTS:
To identify motifs in regulatory regions, OCRs were divided into potential enhancer and promoter genomic regions based on their distance from human TSS regions. Regions within 1kb were classified as potential promoter regions and regions between 5kb and 20kb were classified as potential enhancers. Resulting genomic regions were mapped to the human genome to obtain corresponding enhancer and promoter sequences and duplicated sequences were removed. MEME-ChIP analysis was performed using the results for each tissue-organism combination and the outputs can be found under the meme_chip_outputs directory. All MEME-ChIP analyses were run using `-meme-nmotifs 3`, `-minw 6 `, `-maxw 20` and `db JASPAR2022_CORE_non-redundant_pfms_meme.txt`.

NOTE: Because the script relies on the MEME Suite module from the bridges2 server and outputs of Step 4, we are currently unable to get results for motif analysis, as the server is not available (4/30/2025, 4:00 p.m.)

## Using the Pipeline
Before executing the pipeline, make sure that the `code` and `inputs` folders (along with the subdirectories and files inside) from the repository are properly uploaded to the $PROJECT pathway of the user on the bridges2 cluster. Also make sure that the main pipeline script, Pipeline_V2.sh, is under the $PROJECT pathway. 

From the $PROJECT path on bridges2, execute the pipeline with the following command:

`bash Pipeline_V2.sh inputs/narrowpeaks/mouse/liver/idr.conservative_peak.narrowPeak.gz inputs/narrowpeaks/mouse/pancreas/idr.conservative_peak.narrowPeak.gz`

All of the outputs will be placed into the results folder, which is also generated by the pipeline once it is finished executing. For further information on the subdirectories under results along with the actual output files, please check the results folder in our repository along with their corresponding README files. 

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
