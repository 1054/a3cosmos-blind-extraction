# a3cosmos-blind-extraction

a3cosmos blind source extraction scripts using the source finding and photometry software [PyBDSF](https://github.com/lofar-astron/PyBDSF).

Our script "bin/almacosmos-blind-extraction-photometry" can be run in Terminal to process a number of input images and output a source photometry catalog. 

It includes several steps: 
1. It first runs "bin/AlmaCosmos_Photometry_Blind_Extraction_PyBDSM.py" which calls PyBDSF functions to process each input image and output source catalog, fitted model and residual images. Our script also outputs a DS9 script in each output subfolder to easily plot the input, fitted model and residual images. 
2. It then runs "bin/AlmaCosmos_Photometry_Blind_Extraction_combine_each_image_catalogs.py" to combine all fitting to a big catalog named "Output_Blind_Extraction_Photometry_PyBDSM_Catalog.fits".
3. Finally it runs "bin/AlmaCosmos_Photometry_Blind_Extraction_get_primary_beam_attenuation.py" to read primary beam attenuation values from "*.cont.I.pb.fits" (the filename follows a3cosmos style). It might not run on your machine as there are some specific paths in the script. It outputs the catalog "Output_Blind_Extraction_Photometry_PyBDSM_Catalog_with_Pbcor.fits" with a column "Pbcor", which contains the primary beam attenuation values. 

See examples in the "example" folder.

See the installation of PyBDSF in "README_PyBDSF_Installation_in_Linux.md" or "README_PyBDSF_Installation_in_MacOS.md".  







