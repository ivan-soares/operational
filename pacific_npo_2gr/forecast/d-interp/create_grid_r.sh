#!/bin/bash
#

        domain='npo0.08'
        version='07e'
        grdfile="$HOME/roms/cases/npo0.08+0.0267/grid/grid_${domain}_${version}.nc"
	grdfile="grid_${domain}_${version}.nc"

        echo
        echo " ... script to create file grid_r.nc from $grdfile"
        echo

	if [ -e grid_r_$domain.nc ]; then rm -rf grid_r_$domain.nc; fi

        ncks -v h,mask_rho,lat_rho,lon_rho $grdfile grid_r_$domain.nc

        ncrename -h -O -d xi_rho,x    grid_r_$domain.nc
        ncrename -h -O -d eta_rho,y   grid_r_$domain.nc
        ncrename -h -O -v lat_rho,lat grid_r_$domain.nc
        ncrename -h -O -v lon_rho,lon grid_r_$domain.nc
        ncrename -h -O -v mask_rho,mask grid_r_$domain.nc

        ncatted -O -a coordinates,h,c,c,"lon lat"  grid_r_$domain.nc

        echo
        echo " ... the end !"
        echo

### the end



