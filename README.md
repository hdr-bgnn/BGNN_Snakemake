# BGNN_Snakemake
First complete version of the BGNN image segmentation workflow managed using snakemake.

# 1- Introduction

The image segmentation workflow is managed using snakemake, a user-friendly python workflow manager. Snakemake uses a syntax based on python and can use python code in the definition of the workflow. 

The segmentation workflow consists of the following steps:
1. Download the image(s) using a simple bash script
2. Get metadata (container) using code develop by Drexel (Joel, Kevin and Jane) https://github.com/hdr-bgnn/drexel_metadata/tree/kevin
3. Crop the image using bounding box from metadata (container) using code developed by Thibault.
4. Segment traits (container) using code developed by Maruf and reorganize by Thibault https://github.com/hdr-bgnn/BGNN-trait-segmentation/tree/segment_mini

These 4 steps are represented in the following workflow diagram

![Workflow overview](https://github.com/hdr-bgnn/BGNN_Snakemake/blob/main/Snakemake_workflow.png)

## Different elements of the workflow

1. Snakemake package: installed and managed by conda or mamba (similar that conda but more optimize for snakemake), to access snakemake don't forget to bioconda channel or mamba conda channel.

2. Snakefile

3. Scripts for
   - Generating metadata (in particular bounding box, bbox)
   - cropping the fish using bbox and generating cropped image
   - traits segmentation
 
I believe the scripts should live on their respective repository. This part is still a bit comfusing... Need to work on that.
 
4. Containers
   - there are available at https://cloud.sylabs.io/library/thibaulttabarin

5. Data
   - Images/ : store the ouput from the Download step. Images downloaded from Tulane server
   - Metadata/ : store the output from generate_metadata.py code developped by Drexel. One file ".json" per image
   - Cropped/ : store the ouput from Crop image. 
   - Segmented/ : store the ouput from Segment traits. code developped by Maruf

# 2- Setup and Requirements

   - To start with OSC system check instruction in Setup_Snakemake_OSC.txt.
   - Todo opy paste the contain of Setup_Snakemake_OSC.txt here and format it nicely... Probably a lot of typo to fix

# 3- Download models

   Not sure if this is relevant here... Keep it for the moment. This should go with the documentation for indivdual code on ecah correponding repository
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

# 6- Quick start with OSC

## 1- Using interactive (command sinteractive)

   This is the best to start.  
   Requirement have an acount at OSC. If you need one, contact Hilmar Lapp (Hilmar.Lapp@duke.edu) or Steve Chang (chang.136@osu.edu).
   
   1- ssh <username>@pitzer.osc.edu # you are now on login node... Be gentle with them, they don't like to work too hard!
   
   2- git clone git@github.com:hdr-bgnn/BGNN_Snakemake.git # only the first time.
   
   3- module load miniconda3 # only the first.
   
   4- conda init | source ~/.bashrc # only the first time but if you go on a computing node or owens you do it again and reactivate bashrc.
   
   5- conda create -n local
   
   6- conda info -e # you should see environment named "local" if not check [here](https://www.osc.edu/resources/getting_started/howto/howto_add_python_packages_using_the_conda_package_manager) for more info
   
   7- conda activate local
   
   8- conda install -c bioconda -c conda-forge snakemake
   
   9- sinteractive  -N 1 -n 4  -t 00:10:00  -A <PROJECT_NAME> -J test -p debug squeue -u $USER # your now on a computing node.
   
   10- module load miniconda # Agian! yes it is a different node (understand different machine).
   
   11- conda init | source ~/.bashrc # Again! Same
   
   12- conda activate local # Again! By now, you should know, ;)

   13- snakemake --cores 4 --use-singularity --config list=List/list_lepomis_INHS.csv # the first time, it may take sometime to download the container and some models.
   
   14- exit # exit the computing node
   
   15- ls ~/BGNN_Snakemake # you shloud see folders Images/ Metadata/ Cropped/ Segmented/ populated with multiple fish_file on some sort.

## 2- sbatch and slurm (work in progress)
   
   To submit a job to OSC I use the script SLURM_snake
   
   Usage, connect to the login node
   
   ```ssh <username>@pitzer```
   
   Then
   
   ```
   cd BGNN_Snakemake
   sbatch SLURM_Snake
   ```
   
   To check the process
   
   ```squeue -u $USER```
   
   That's it!
   
   *Comment*: this script will create :
   * slurm-job_ID.out (, and directory job_ID)
   * directory job_ID which contain the results in the form of:
      - Images/
      - Cropped/
      - Metadata/
      - Segmented/
      - Snakemake/
      - list_test.csv
   
   Problem to solve : 
   * every job create a new folder
   * snakemake will lose tract of what has been processed. Need to figure out to a better manage the link between input data output and track.
   * I had to manullay for .snakemake (~/BGNN_Snakemake/.snakemake/singularity/) containing the singularity image in to the $TMPDIR
   * Same for ~/BGNN_Snakemake/.cache/torch/hub/checkpoints/se_resnext50_32x4d-a260b3a4.pth
