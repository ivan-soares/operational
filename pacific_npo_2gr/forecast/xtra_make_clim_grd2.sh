#!/bin/bash
#

	echo
	echo " +++ Starting script to interp climatology to higher resolution +++"
	echo

	today=$1
	domain01="npo0.08_07e"
	domain02="npo0.0267_01c"
	ogcm="glby"

	ddir="$HOME/oper/pacific_npo_2gr/forecast"
	clim="$ddir/d-storage/$today/input_clm_${domain01}_${today}_${ogcm}.nc"
	clim2="input_clm_${domain02}_${today}_${ogcm}.nc"

	romsgrd="$ddir/d-interp/grid_${domain02}.nc"

	cdo="cdo -s --no_warnings"

	##### check for existence of clim file


	if [ -e $clim ]; then 
		echo " ... file $clim EXISTS, with interpolate it"; echo
	else
		echo " ... DIDNT find file $clim, exiting now "; echo
		exit
	fi


	##### check for existence of grid file


	if [ -e $romsgrd ]; then 
		echo " ... file $romsgrd EXISTS, with interpolate it"; echo
	else
		echo " ... DIDNT find file $romsgrd, exiting now "; echo
		exit
	fi


	#### select variables


	vars_1="ocean_time,spherical,Vtransform,Vstretching,theta_s,theta_b"
	vars_2="Tcline,hc,s_rho,s_w,Cs_r,Cs_w"
	vars_r="lon_rho,lat_rho,zeta,temp,salt"
	vars_u="lon_u,lat_u,ubar,u"
	vars_v="lon_v,lat_v,vbar,v"

	echo " ... compute interp weigths"; echo

	rm -rf grid_r.nc weights_r.nc
	ncks -v lon_rho,lat_rho $romsgrd grid_r.nc
	ncrename -h -O -v lon_rho,lon -v lat_rho,lat grid_r.nc
		
	rm -rf grid_u.nc weights_u.nc
	ncks -v lon_u,lat_u $romsgrd grid_u.nc
	ncrename -h -O -v lon_u,lon -v lat_u,lat grid_u.nc

	rm -rf grid_v.nc weights_v.nc
	ncks -v lon_v,lat_v $romsgrd grid_v.nc
	ncrename -h -O -v lon_v,lon -v lat_v,lat grid_v.nc

	ncks -v $vars_1,$vars_2,$vars_r $clim tmp_r.nc
	ncks -v $vars_1,$vars_2,$vars_u $clim tmp_u.nc
	ncks -v $vars_1,$vars_2,$vars_v $clim tmp_v.nc

	$cdo genbil,grid_r.nc tmp_r.nc weights_r.nc
	$cdo genbil,grid_u.nc tmp_u.nc weights_u.nc
	$cdo genbil,grid_v.nc tmp_v.nc weights_v.nc


	echo " ... interp vars at RHO points"; echo
	$cdo remap,grid_r.nc,weights_r.nc tmp_r.nc tmp_r_remaped.nc

	echo " ... interp vars at U points"; echo
	$cdo remap,grid_u.nc,weights_u.nc tmp_u.nc tmp_u_remaped.nc

	echo " ... interp vars at V points"; echo
	$cdo remap,grid_v.nc,weights_v.nc tmp_v.nc tmp_v_remaped.nc

	echo " ... write all variables in file $clim2"; echo; echo


cat > write_clim_file.py << EOF

import sys
import numpy as np
import netCDF4 as nc

f1 = nc.Dataset('tmp_r_remaped.nc','r')
f2 = nc.Dataset('tmp_u_remaped.nc','r')
f3 = nc.Dataset('tmp_v_remaped.nc','r')

out = nc.Dataset(str(sys.argv[1]),'r+')

out.variables['zeta'][:] = f1.variables['zeta'][:] 
out.variables['temp'][:] = f1.variables['temp'][:] 
out.variables['salt'][:] = f1.variables['salt'][:] 

out.variables['ubar'][:] = f2.variables['ubar'][:] 
out.variables['vbar'][:] = f3.variables['vbar'][:] 

out.variables['u'][:] = f2.variables['u'][:] 
out.variables['v'][:] = f3.variables['v'][:] 

f1.close()
f2.close()
f3.close()
out.close()

EOF


	cp $ddir/d-interp/clm_npo0.0267_01c.nc $clim2
	python write_clim_file.py $clim2

	mv $clim2 $ddir/d-storage/$today/

	###### remove unwanted files
	rm grid_*.nc weights_*.nc tmp*
	rm write_clim_file.py

	echo
	echo " +++ End of script +++"
	echo


################################# *** the end *** ################################################

