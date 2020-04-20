#!/usr/bin/env python
# 
# Aim: concatenate each image PyBDSM catalogs
# 
# Last update: 2018-09-10
# 

from __future__ import print_function
import os, sys, re
import numpy as np
from astropy.table import Table, vstack
from datetime import datetime



input_root = 'Output_Blind_Extraction_Photometry_PyBDSM'
if len(sys.argv) > 1:
    input_root = sys.argv[1]
input_list_of_catalog = input_root + os.sep + 'output_list_of_catalog.txt'
output_name = input_root+'_Catalog.fits' # 'Output_Blind_Extraction_Photometry_PyBDSM_%s.fits'%(datetime.today().strftime('%Y%m%d_%Hh%Mm%Ss'))

maxlength = 255
with open(input_list_of_catalog, 'r') as fp:
    for line in fp:
        tbfile = input_root+os.sep+line.rstrip('\n')
        imagefile = os.path.basename(os.path.dirname(tbfile))+'.fits'
        if len(imagefile) > maxlength:
            maxlength = len(imagefile)

tb = None
with open(input_list_of_catalog, 'r') as fp:
    for line in fp:
        tbfile = input_root+os.sep+line.rstrip('\n')
        if os.path.isfile(tbfile):
            tb1 = Table.read(tbfile)
            if len(tb1) > 0:
                col1 = np.empty(len(tb1), dtype='|S%d'%(maxlength))
                col1[:] = os.path.basename(os.path.dirname(tbfile))+'.fits'
                tb1['Image'] = col1
                if tb is None:
                    tb = tb1
                else:
                    tb = vstack([tb,tb1])
    if tb is not None:
        tb.write(output_name, overwrite=True)
        print('Output to "%s"!' % (output_name))















