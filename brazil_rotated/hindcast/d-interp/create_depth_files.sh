#!/bin/bash
#
	echo
	echo " +++ Starting script to create files depths_sig.nc & depths_lev.nc for ROMS +++"
	echo

        region='brz'
        domain='brz0.05r'
        version='01a'
        ogcm='nemo'

	ddir="$HOME/scripts/4roms"

	################# load grid params and files names

	source params_${domain}_${version}.txt

	################# create empty netcdf files: depths_sig.nc & depths_ogcm.nc

	source $ddir/create_depth_files_sub01_ncgen_empty_files.sh

	################# fill in values in files: depths_sig.nc & depths_ogcm.nc

	infiles="$grdfile depths_sig.nc depths_${ogcm}.nc"
	echo $ogcm_depths | sed 's/,/ /g' >& ogcm_depths
	python $ddir/create_depth_files_sub02_fillin_files.py $sig_params $infiles                    
	rm ogcm_depths

	#################  the end

	echo
	echo " +++ End of script +++"
	echo


########################################################################################################


