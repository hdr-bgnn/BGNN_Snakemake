######
import pandas as pd
import glob
import os
# pull in all files with .fastq on the end in the 'data' directory.

LIST = config['list']

print(f"your are using this list {LIST}")

#df = pd.read_csv(f'{LIST}', sep=',', decimal='.')
df = pd.read_csv(f'{LIST}')
split_df = df['original_file_name'].str.split('\\.', expand=True)
split_df.columns=['original_file_name','2']
samples_df = df.drop(columns=['original_file_name'])
df = pd.merge(split_df['original_file_name'],samples_df, how="left", left_index=True, right_index=True)
samples_df = df.set_index('original_file_name', drop=False)

NAMES = list(samples_df['original_file_name'])
NAMES = [os.path.splitext(name)[0] for name in NAMES]
IMAGES = expand("Images/{image}.jpg", image=NAMES)
METADATA = expand("Metadata/{image}.json", image=NAMES)
MASK = expand("Mask/{image}_mask.png", image=NAMES)
CROPPED = expand("Cropped/{image}_cropped.jpg", image=NAMES)
SEGMENTED = expand("Segmented/{image}_segmented.png", image=NAMES)

rule all:
    input:SEGMENTED

rule download_image:
    output:'Images/{image}.jpg'
    params: download_link = lambda wildcards: samples_df.loc[wildcards.image, "path"]
    shell: 'wget -O {output} {params.download_link}'

rule clean:
    shell:'rm -rf Images/* Metadata/* Cropped/*'
# here put a comment
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
        'library://thibaulttabarin/bgnn/crop_image:v1'
    shell: 'crop_image.py {input.image} {input.metadata} {output}'

rule Segmentation:
    input: 'Cropped/{image}_cropped.jpg'
    output: 'Segmented/{image}_segmented.png'
    singularity:
        'docker://ghcr.io/hdr-bgnn/bgnn-trait-segmentation:0.0.4'
    shell:
        'segmentation_main.py {input} {output}'
