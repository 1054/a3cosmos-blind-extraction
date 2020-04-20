#!/usr/bin/env python
# 
# Aim: read primary beam response image (*.cont.I.pb.fits) and output primary beam attenuation correction factor for each source in the input catalog.
# 
# Last update: 2018-09-10
# 

from __future__ import print_function
import os, sys, re
import numpy as np
from astropy.table import Table
from astropy.io import fits
from astropy.wcs import WCS
from astropy.wcs.utils import proj_plane_pixel_scales



input_root = 'Output_Blind_Extraction_Photometry_PyBDSM'
if len(sys.argv) > 1:
    input_root = sys.argv[1]

input_catalog =input_root+ '_Catalog.fits'

pb_root_dir = './Input_Images/' # where the cont.I.pb.fits are stored

output_name =input_root+ '_Catalog_with_Pbcor.fits'

tb = Table.read(input_catalog, format='fits')

verbose = False

#tb.group_by

Pbcor = np.full(len(tb), np.nan)
for i in range(len(tb)):
    RA = tb['RA'][i]
    Dec = tb['DEC'][i]
    image_filename = tb['Image'][i]
    pb_filename = re.sub(r'cont.I.image.fits$', r'cont.I.pb.fits', image_filename)
    pb_filepath = os.path.join(pb_root_dir, pb_filename)
    if not os.path.isfile(pb_filepath):
        print('*'*32)
        print('Error! File not found: %r. Skipping it.'%(pb_filepath))
        print('*'*32)
        continue
    else:
        print('*'*32)
        print('Reading %r'%(pb_filepath))
        print('*'*32)
    with fits.open(pb_filepath) as hdulist:
        pb_data = hdulist[0].data
        pb_header = hdulist[0].header
        pb_wcs = WCS(pb_header, naxis=2)
        while len(pb_data.shape) > 2:
            pb_data = pb_data[0]
        px, py = pb_wcs.wcs_world2pix([RA], [Dec], 0)
        px, py = int(np.round(px[0])), int(np.round(py[0]))
        nx = pb_header['NAXIS1']
        ny = pb_header['NAXIS2']
        if px >= 0 and px < nx and py >= 0 and py < ny:
            Pbcor[i] = pb_data[py,px]
            if verbose:
                print('RA Dec %.7f %.7f, px py %d %d, Pbcor %s'%(RA, Dec, px, py, Pbcor[i]))
        else:
            for small_shift_y in [-1,0,1]:
                for small_shift_x in [-1,0,1]:
                    if px+small_shift_x >= 0 and px+small_shift_x < nx and py+small_shift_y >= 0 and py+small_shift_y < ny:
                        Pbcor[i] = pb_data[py+small_shift_y,px+small_shift_x]
                        if verbose:
                            print('RA Dec %s %s, px py %s%+1d %s%+1d, Pbcor %s'%(RA, Dec, px, small_shift_x, py, small_shift_y, Pbcor[i]))
                        break
                if not np.isnan(Pbcor[i]):
                    break
        

if 'E_Peak_flux' in tb.colnames:
    tb.add_column(Pbcor, name='Pbcor', index=tb.colnames.index('E_Peak_flux')+1)
else:
    tb.add_column(Pbcor, name='Pbcor')

tb.write(output_name, overwrite=True)
print('Output to "%s"!' % (output_name))













