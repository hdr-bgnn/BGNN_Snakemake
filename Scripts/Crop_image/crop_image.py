#!/usr/local/bin/python
# -*- coding: utf-8 -*-
"""
Created on Wed Jan 12 13:00:22 2022

@author: thibault
Contain functions to get the bounding box (bbox) from the metadata file
and crop the fish out of the image from the bbox
everything is wrap into a main function executable via 
python crop_main.py <image> <metadatafile> <output_crop>
"""

import os
import sys
import json
import numpy as np
from PIL import Image
import pandas as pd
from pathlib import Path


def get_bbox(metadata_file):

    f = open(metadata_file)
    data = json.load(f)
    first_value = list(data.values())[0]

    if first_value['has_fish']==True:

        bbox = first_value['fish'][0]['bbox']
    else: bbox =[]
    return bbox

def main(image_file, metadata_file, output_file):

    im = Image.open(image_file)

    bbox = get_bbox(metadata_file)

    if bbox:
        im1 = im.crop(bbox) # bbox [left,top,right,bottom]

    else:
        # if no bounding box detected
        print ("no bounding box available for {}, will return empty cropped image".format(image_file))
        im1 = Image.fromarray(np.zeros(im.size))

    im1.save(output_file)

if __name__ == '__main__':

    main(sys.argv[1],sys.argv[2],sys.argv[3])
