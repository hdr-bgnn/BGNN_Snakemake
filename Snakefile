######
import pandas as pd
import glob
import os

LIST = config['list']

print(f"your are using this list {LIST}")

# Read images CSV file into a dataframe
df = pd.read_csv(LIST)
# Create 'name' column by removing the filename extension from 'original_file_name'
df['name'] = df['original_file_name'].apply(lambda x : os.path.splitext(x)[0])
# Create Series to lookup a URL for an image 'name'
df = df.set_index('name')
NAME_TO_URL = df['path']

NAMES = list(NAME_TO_URL.index)
NAMES = [os.path.splitext(name)[0] for name in NAMES]
IMAGES = expand("Images/{image}.jpg", image=NAMES)
METADATA = expand("Metadata/{image}.json", image=NAMES)
MASK = expand("Mask/{image}_mask.png", image=NAMES)
CROPPED = expand("Cropped/{image}_cropped.jpg", image=NAMES)
SEGMENTED = expand("Segmented/{image}_segmented.png", image=NAMES)
MORPHOLOGY = expand("Morphology/Measure/{image}_measure.json", image=NAMES)

rule all:
    input:MORPHOLOGY

rule download_image:
    output:'Images/{image}.jpg'
    params: download_link = lambda wildcards: NAME_TO_URL[wildcards.image]
    shell: 'wget -O {output} {params.download_link}'

rule clean:
    shell:'rm -rf Images/* Metadata/* Cropped/*'

rule generate_metadata:
    input:'Images/{image}.jpg'
    output:
        metadata = 'Metadata/{image}.json',
        mask = 'Mask/{image}_mask.png'
    singularity:
        'library://thibaulttabarin/bgnn/gen_metadata:v2'
    shell: 'gen_metadata.py {input} {output.metadata} {output.mask}'

rule Cropped_image:
    input:
        image = 'Images/{image}.jpg',
        metadata = 'Metadata/{image}.json'
    output:'Cropped/{image}_cropped.jpg'
    singularity:
        'docker://ghcr.io/hdr-bgnn/bgnn_snakemake/crop_morph:0.0.16'
    shell: 'Crop_image_main.py {input.image} {input.metadata} {output}'

rule Segmentation:
    input: 'Cropped/{image}_cropped.jpg'
    output: 'Segmented/{image}_segmented.png'
    singularity:
        'docker://ghcr.io/hdr-bgnn/bgnn-trait-segmentation:0.0.4'
    shell:
        'segmentation_main.py {input} {output}'

rule Morphological_analysis:
    input:
        image = 'Segmented/{image}_segmented.png',
	metadata = 'Metadata/{image}.json'
    output:
        measure = "Morphology/Measure/{image}_measure.json",
        landmark = "Morphology/Landmark/{image}_landmark.json",
        presence = "Morphology/Presence/{image}_presence.json",
        vis_landmarks = "Morphology/Vis_landmarks/{image}_landmark_image.png"
   
    singularity:
        "docker://ghcr.io/hdr-bgnn/morphology-analysis/morphology:0.0.1"
    shell:
        'Morphology_main.py {input.image} {input.metadata} {output.measure} {output.landmark} {output.presence} {output.vis_landmarks}'

# This is not executed in this version, it should be executed at the end when you want to collect the .csv with
# all the results
rule Merge_files:
    input : MORPHOLOGY
    output : 'Result_morphology/result.csv'
    params :
        input_file = 'Morphology/',
    singularity:
        "docker://ghcr.io/hdr-bgnn/bgnn_snakemake/crop_morph:0.0.16"
    shell:
        "Merge_files_main.py {params.input_file} {output}"
