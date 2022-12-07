
#!/bin/bash
#
	echo
	echo " +++ Starting script to create file grid_rho.nc for CDO remap function +++"
	echo

        domain='brz0.05r'
        version='01a'

	romsdir="$HOME/operational/roms"
	grdfile="grid_${domain}_${version}.nc"

	if [ ! -e $grdfile ]; then
		cp $romsdir/grids/$grdfile .
	fi

	cdo -selvar,lon_rho,lat_rho,h $grdfile grid_rho.nc
	ncrename -h -v lat_rho,lat -v lon_rho,lon grid_rho.nc
        ncatted -O -a coordinates,h,o,c,"lon lat" grid_rho.nc
	echo
	echo " +++ End of script: +++"
	echo
