#!/bin/bash
#

#    script to interpolate ROMS data
#     from sigma to z levels
#

	today=$1

        yr=${today:0:4}
        mm=${today:4:2}
        dd=${today:6:2}

	domain="brz0.05"
	version="01d"

	grdfile="$HOME/operational/roms/input_files/grid_${domain}_${version}.nc"

        echo
        echo " ==> STARTING BASH script to interp ROMS from sigma to z coord <=="
        echo
        echo " ... starting date is $today"
        echo

	aki=`pwd`
	source $HOME/operational/forecast/step00_forecast_setup.sh
	cd $aki

	echo " ... params $params"
	echo

	#  here we decide the sub-region of interest

	lon1='-47.'
	lon2='-41.'
	lat1='-4.'
	lat2='1.'

	dlon='0.05'
	dlat='0.05'

	nlon=121
	nlat=101
	nsig=30
	ndep=50

	grid_info=" $nlon $nlat $nsig $ndep $lon1 $lat1 $dlon $dlat"

	# extract a cut of topography creating file grid.nc which is needed in sr02
	# the values for xi_rho and eta_rhos were previously choosen to match
	# lon1,lon2 lat1,lat2
	ncks -d xi_rho,100,220 -d eta_rho,520,620 $grdfile grid.nc

	echo " ... create gridfile.txt and empty netcdf files profs.nc & depths.nc"; echo
	./make_sig2z_inputfiles_sr01_createfiles.sh $today $grid_info

	# write values on newly created files
	# will need the gridfile grid.nc
	echo " ... write standard depths on file depths.nc and roms depths on profs.nc"; echo
	python make_sig2z_inputfiles_sr02_writevalues.py $params $lon1 $lon2 $lat1 $lat2 $dlon

#    the end
