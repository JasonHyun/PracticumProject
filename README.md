# Open Chromatin Region Study of Liver and Pancreas

## Introduction
This is a project for the course 03713: Bioinformatics Data Integration Practicum from Carnegie Mellon University, with purpose of analyzing open chromatin regions across species of human and mouse. The project aims to evaluate the extent of conservation of involved regulatory elements across species and tissues, and to understand how these conserved regions may influence tissue-specific gene regulation. 

## Workflow

Mapping mouse open chromatin regions to human:
The narrowpeak files containing mouse open chromatin regions were loaded into HALPER to map to human genome. At this step, HALPER tasks were submitted to and run on an RM-Shared node in PSC (Pittsburgh Supercomputing Center). For better computating efficiency, 16 cores and 32GB memory were requested. The open chromatin regions in mouse liver and pancreas were mapped into human genome.

Functional Enrichment Analysis:
An online tool, GREAT, was used to apply functional enrichment analysis. The open chromatin regions that were, respectively, unique to organs or organisms, conservative across organs or organisms, were put into GREAT for obtaining GO terms where the peaks enriched in.

## Tools
- HALPER (https://github.com/pfenninglab/halLiftover-postprocessing)
- bedtools (https://bedtools.readthedocs.io/en/latest/)
- GREAT (https://great.stanford.edu/great/public/html/)
- MEME Suite (https://meme-suite.org/meme/)

## Datasets
The original narrowpeak datasets for alternate adrenal gland, liver, and pancreas tissues were provided as results of ATAC-Seq, along with their QC reports, from the project pathway of bridges2. These are also available under the data folder in the repository, along with respective QC reports that helped us conclude to leave out the alternative adrenal gland data in aim of using the two tissue data with best integrity and quality for the project.

## Contributors
Jason Hyun, Jessica Vu, Deyuan Xu, June Qu
