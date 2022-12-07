#!/bin/bash
#
############################################################################################
#
#      Script to create input files that are used when interpolating OGCM to sigma coord
#
#      sub01: generates gridfiles
#
#      sub02: generates depth files
#
#             subsub02a: creates empty files: depth_z.nc & depth_sig.nc
#             subsub02b: write depth values in files depth_z.nc & depth_sig.nc
#
#      sub03: generates a mask for OGCM 
#
#################################################################################

	echo
	echo " ==> STARTING script to create input files for make_clim.sh <=="
	echo

	today=$1
	ndays=$2

	ddir="$HOME/scripts/operational"

	#### set grid dimension, sigma params and file names
	source params.txt

	#### create new files  !!!!!
	#### will need sigma params to compute sigma levels

	# create grdfiles.txt for rho, u, v & psi
	source $operdir/create_clim_inputfiles_sub01.sh

	# create depth files for rho, u, v & psi
	# will use scripts subsub02a & subsub02b
	source $operdir/create_clim_inputfiles_sub02.sh

	# create a mask for OGCM file 
	# will use ogcm file named ogcm01, named in params.txt
	source $operdir/create_clim_inputfiles_sub03.sh

	rm spheri vtrans vstret thetas thetab tcline hc
	rm nsig ndep dh ndat ndays ntimes today
	rm grdfile clmfile bryfile

	echo
	echo " ==> END of script to create input files <=="
	echo

#
######  the end
#
