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
![Workflw_stage_1](https://user-images.githubusercontent.com/50921014/174411467-687a8b63-1fd3-4d00-8b29-944bfc99ac2f.png)

![Workflow overview 1](https://github.com/hdr-bgnn/BGNN_Snakemake/blob/main/Workflw_stage_1.png)

![Workflow overview 2](https://github.com/hdr-bgnn/BGNN_Snakemake/tree/main/Workflw_stage_2.png)

## Workflow components

1. Snakemake package: installed and managed by conda or mamba, which is similar to conda but optimized for snakemake. To access snakemake, use the bioconda channel or mamba conda channel.

2. Snakefile

3. Scripts for
   - Generating metadata (in particular bounding box, bbox)
   - cropping the fish using bbox and generating cropped image
   - traits segmentation
 
I believe the scripts should live on their respective repository. This part is still a bit comfusing... Need to work on that.
 
4. Containers
   - these are available at https://cloud.sylabs.io/library/thibaulttabarin

5. Data
   - Images/ : store the ouput from the Download step. Images downloaded from Tulane server
   - Metadata/ : store the output from generate_metadata.py code developed by Drexel team. One file ".json" per image
   - Cropped/ : store the ouput from Crop image. 
   - Segmented/ : store the ouput from Segment trait using code developed by M. Maruf (Virginia Tech)

# 2- Setup and Requirements

   - To start with OSC system check instructions in Setup_Snakemake_OSC.txt.
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
   
   For explanation check instruction in Instruction_Snakemake.txt
   
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

   This is the best way to start.  
   Requirement: have an acount at OSC. If you need one, contact Hilmar Lapp (Hilmar.Lapp@duke.edu) or Steve Chang (chang.136@osu.edu).
   
   1- ssh <username>@pitzer.osc.edu # you are now on login node... Be gentle with them, they don't like to work too hard!
   
   2- git clone git@github.com:hdr-bgnn/BGNN_Snakemake.git # only the first time.
   
   3- module load miniconda3 # only the first.
   
   4- conda create -n snakemake -c bioconda -c conda-forge snakemake -y # Create an environment named snakemake 
   
   5- source activate snakemake # Activate the environment, so now you have access to the package snakemake
   
   6- conda info -e # you should see environment named "snakmake" if not check [here](https://www.osc.edu/resources/getting_started/howto/howto_add_python_packages_using_the_conda_package_manager) for more info
   
   9- sinteractive  -N 1 -n 4  -t 00:10:00  -A <PROJECT_NAME> -J test -p debug squeue -u $USER # your now on a computing node.
   
   10- module load miniconda3 # Again! yes it is a different node (understand different machine).
   
   11- source activate snakemake # Again! Same as before

   12- snakemake --cores 4 --use-singularity --config list=List/list_lepomis_INHS.csv # the first time, it may take sometime to download the container and some models.
   
   13- exit # exit the computing node
   
   14- ls ~/BGNN_Snakemake # you shloud see folders Images/ Metadata/ Cropped/ Segmented/ populated with multiple fish_file on some sort.

## 2- sbatch and slurm (work in progress)
   
   To submit a job to OSC I use the script [SLURM_Snake](SLURM_Snake).
   
   Usage, connect to the login node
   
   ```ssh <username>@pitzer```
   
   Clone this BGNN_Snakemake repo (if necessary) and cd into the repo.
   ```
   git clone git@github.com:hdr-bgnn/BGNN_Snakemake.git
   cd BGNN_Snakemake
   ```
   
   The SLURM_snake script requires a `snakemake` conda environment. 
   If you have followed the __Using interactive__ instructions this environment will already exist.
   If not, run the following to load miniconda, create the environment, and unload miniconda.
   ```
   module load miniconda3/4.10.3-py37
   conda create -n snakemake -c bioconda -c conda-forge snakemake -y
   module purge
   ```
   
   The SLURM_snake script has the following positional arguments:
   - a data directory to hold all data for a single run - **required**
   - a CSV file that contains details about the image files to process - **required**
   - the number of jobs for Snakemake to run at once - **optional defaults to 4**   
 
   The `SLURM_Snake` script should be run with arguments like so:
   ```
   sbatch SLURM_Snake <data_directory> <path_to_csv> [number_of_jobs]
   ```
   For example if you want to store the data files at the relative path of `data/list_test` and processs `List/list_test.csv` run the following:
   
   ```
   sbatch SLURM_Snake data/list_test List/list_test.csv
   ```

   To run the example with up to 8 parallel jobs run the command like so:
   ```
   sbatch SLURM_Snake data/list_test List/list_test.csv 8
   ```
   
   To check the process
   
   ```squeue -u $USER```
   
   That's it!
   
   *Comment*: this script will create a slurm-job_ID.out log file.
   
   The `data_directory` will contain the following directory structure:
   ```
   Images/
   Cropped/
   Metadata/
   Segmented/
   ```
   
   ---
   
   The `SLURM_Snake` script configures Snakemake to submit separate sbatch jobs for each step run.
   Details about individual steps can be seen by running the `sacct` command.
   
   For example:
   ```
   sacct --format JobID,JobName%40,State,Elapsed,ReqMem,MaxRSS
   ```
   Keep in mind that `sacct` defaults to showing jobs from the current day. See [sacct docs](https://slurm.schedmd.com/sacct.html#SECTION_DEFAULT-TIME-WINDOW) for options to specify a different time range.

