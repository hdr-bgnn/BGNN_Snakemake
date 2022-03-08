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

   - To start with OSC system check instruction in Setup_Snakemake_OSC.txt

# 3- Download models

   *Models for segment trait* : located at https://drive.google.com/uc?id=1HBSGXbWw5Vorj82buF-gCi6S2DpF4mFL
   Follow instruction in BGNN_Snakemake/Containers/Singularity_def_segment_trait/Scripts/saved_models/load.txt
   or
   ```
   cd ~/BGNN_Snakemake/Containers/Singularity_def_segment_trait/Scripts
   gdown -O saved_models/ https://drive.google.com/uc?id=1HBSGXbWw5Vorj82buF-gCi6S2DpF4mFL
   ```
   
   *Models for generate metadata* : https://drive.google.com/file/d/1QWzmHdF1L_3hbjM85nOjfdHsm-iqQptG
   

# 4- Usage
   
   For explaination check instruction in Instruction_Snakemake.txt
   
   ```
   snakemake --cores 1 --use-singularity --config list=List/list_lepomis_INHS.csv
   ```

# 5- Containers location

The containers related to this project are located at https://cloud.sylabs.io/library/thibaulttabarin

there are 3 containers of interest:

* BGNN/segment_trait : 
   ```singularity pull --arch amd64 library://thibaulttabarin/bgnn/segment_trait:1```
* BGNN/Metadata_generator :
   ```singularity pull --arch amd64 library://thibaulttabarin/bgnn/metadata_generator:v2 ```
* BGNN/crop_image :
    ```singularity pull --arch amd64 library://thibaulttabarin/bgnn/crop_image:v1```

