# BGNN_Snakemake
First complete version of the workflow with snakemake

# 1- Introduction

The workflow is managed using snakemake. 

Snakemake use a syntax based on python and use python code in the defintiion of the workflow. Snakemake is very friendly python user workflow manage.

## Different part of the workflow

1. Snakemake package: installed and managed conda or mamba (similar that conda but more optimize for snakemake

2. Snakefile

3. Scripts for
   - Generating metadata (in particular bounding box, bbox)
   - cropping the fish using bbox and generating cropped image
   - traits segmentation
 
4. Containers

5. Data

# 2- Setup requirements

# 3- Download model

# 4- Usage

# 5- Containers location

The containers related to this project are located at https://cloud.sylabs.io/library/thibaulttabarin

there are 3 containers of interest:

* BGNN/segment_trait
* BGNN/Metadata_generator
* BGNN/crop_image

