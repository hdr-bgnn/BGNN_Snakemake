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

# 6- Quick with OSC
   
   Requirement have an acount at OSC. If you need one, contact Hilmar Lapp (Hilmar.Lapp@duke.edu) or Steve Chang (chang.136@osu.edu)
   
   1- ssh <username>@pitzer.osc.edu # you are now on login node... Be gentle with them, they don't like to work too hard!
   
   2- git clone git@github.com:hdr-bgnn/BGNN_Snakemake.git # only the first time
   
   3- module load miniconda3 # only the first
   
   4- conda init | source ~/.bashrc # only the first time but if you go on a computing node or owens you do it again and reactivate bashrc
   
   5- conda create -n local
   
   6- conda info -e # you should see environment named "local" if not check [here](https://www.osc.edu/resources/getting_started/howto/howto_add_python_packages_using_the_conda_package_manager) for more info
   
   7- conda activate local
   
   8- pip install snakemake
   
   9- sinteractive  -N 1 -n 4  -t 00:10:00  -A <PROJECT_NAME> -J test -p debug squeue -u $USER # your now on a computing node
   
   10- module load miniconda # Agian! yes it is a different node (understand different machine)
   
   11- conda init | source ~/.bashrc # Again! Same
   
   12- conda activate local # Again! By now, you should know, ;)

   13- snakemake --cores 4 --use-singularity --config list=List/list_lepomis_INHS.csv # the first time, it may take sometime to dwnload the container and some models
   
   14- exit # exit the computing node
   
   15- ls ~/BGNN_Snakemake # you shloud see folder Images/ Metadata/ Cropped/ Segmented/ populated with fish_file on some sort

