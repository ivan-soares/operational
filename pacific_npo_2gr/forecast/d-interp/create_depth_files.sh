#!/bin/bash
#
########################################################################################
#
#      Script to make depth files to be used in vertical interpolations fo OGCM files
#
########################################################################################

	echo
	echo " ==> STARTING script to create input files for make_clim.sh <=="
	echo

        region='toc'
        domain='npo0.08'   #'npo0.08'
        version='07e'        #'07e'
        ogcm='glby'

	#### set grid dimension, sigma params and file names
	source params_depth.txt # depth_setup.txt
	echo $ogcm_depths | sed -e 's/,//g' >& ogcm_depths	

	operdir="$HOME/scripts/4roms"

	#### create new files  !!!!!
	#### will need sigma params to compute sigma levels
	#### and NX,NY,ndep,nsig

	
	# create empty netcdf files: depths_sig.nc & depths_z.nc
	source $operdir/create_depth_files_sub01_ncgen_empty_files.sh

	# write values on newly created files
	python $operdir/create_depth_files_sub02_fillin_files.py $sig_params $grdfile \
		depths_sig.nc depths_z.nc
	mv depths_sig.nc depths_sig_${domain}.nc
	mv depths_z.nc depths_${ogcm}_${domain}.nc
	rm ogcm_depths

	echo
	echo " ==> END of script to create input files <=="
	echo

#########################################################################################
#
#                                 the end
#
#########################################################################################
