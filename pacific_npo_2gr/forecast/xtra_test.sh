#!/bin/bash
#

        ###### issues to solve:

        ###### Nothing for now !!!

        ### export PATHs is necessary for the crontab
        ### which will not source .bashrc because it doesnt run in a terminal

        scriptsdir=${HOME}/scripts/bash

        export PATH=${PATH}:${scriptsdir}
        export PATH=${PATH}:${scriptsdir}/find_fncts
        export PATH=${PATH}:${scriptsdir}/wget
        export PATH=${PATH}:${scriptsdir}/check

        #### the next is necessary when downloading GFS
        export PATH=${PATH}:$HOME/apps/wgrib2/

        #### path to ncdump
	export PATH=${PATH}:$HOME/apps/netcdf-c-4.8.0/bin

	romsgrd="$HOME/roms/cases/toc/npo0.08+0.0267/grid/grid_npo0.08_07e.nc"

	if [ -e  lonlat1.nc ]; then rm  lonlat1.nc; fi
        if [ -e  lonlat2.nc ]; then rm  lonlat2.nc; fi
        ncks -v lon_rho,lat_rho -d eta_rho,0 -d xi_rho,0   $romsgrd lonlat1.nc
        ncks -v lon_rho,lat_rho -d eta_rho,-1 -d xi_rho,-1 $romsgrd lonlat2.nc


	nx=`ncdump -h $romsgrd | grep "xi_rho = " | awk '{print $3}'`
        ny=`ncdump -h $romsgrd | grep "eta_rho = " | awk '{print $3}'`

	echo; echo " ... nx/ny = ${nx}/${ny}"; echo

#   the end
