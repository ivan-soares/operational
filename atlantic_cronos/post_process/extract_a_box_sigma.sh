#!/bin/bash
#
	today=$1

	echo
	echo " +++ Starting script to extract a cross shelf snapshot +++"
	echo

	ddir="$HOME/operational/atlantic/forecast/d-storage"

	lon1=196
	lon2=460

	lat1=129
	lat2=196

	romsglby="$ddir/$today/roms_avg_brz0.05_01g_${today}_glby.nc"
	romsnemo="$ddir/$today/roms_avg_brz0.05_01g_${today}_nemo.nc"
	out1="box_movar_${today}_roms+glby_sigma.nc"
	out2="box_movar_${today}_roms+nemo_sigma.nc"

	ncks -d eta_rho,$lat1,$lat2 -d eta_u,$lat1,$lat2 -d eta_v,$lat1,$lat2 -d xi_rho,$lon1,$lon2 -d xi_u,$lon1,$lon2 -d xi_v,$lon1,$lon2 $romsglby roms_glby_${today}_across-shelf_22S.nc
	ncks -d eta_rho,$lat1,$lat2 -d eta_u,$lat1,$lat2 -d eta_v,$lat1,$lat2 -d xi_rho,$lon1,$lon2 -d xi_u,$lon1,$lon2 -d xi_v,$lon1,$lon2 $romsnemo roms_nemo_${today}_across-shelf_22S.nc
	cdo -s --no_warning timavg roms_glby_${today}_across-shelf_22S.nc $out1
	cdo -s --no_warning timavg roms_nemo_${today}_across-shelf_22S.nc $out2
	rm roms_glby_${today}_across-shelf_22S.nc 
	rm roms_nemo_${today}_across-shelf_22S.nc

	glby="$ddir/$today/input_clm_brz0.05_01g_${today}_glby.nc"
	nemo="$ddir/$today/input_clm_brz0.05_01g_${today}_nemo.nc"
	out1="box_movar_${today}_glby_sigma.nc"
	out2="box_movar_${today}_nemo_sigma.nc"

	ncks -d eta_rho,$lat1,$lat2 -d eta_u,$lat1,$lat2 -d eta_v,$lat1,$lat2 -d xi_rho,$lon1,$lon2 -d xi_u,$lon1,$lon2 -d xi_v,$lon1,$lon2 $glby glby_${today}_across-shelf_22S.nc
	ncks -d eta_rho,$lat1,$lat2 -d eta_u,$lat1,$lat2 -d eta_v,$lat1,$lat2 -d xi_rho,$lon1,$lon2 -d xi_u,$lon1,$lon2 -d xi_v,$lon1,$lon2 $nemo nemo_${today}_across-shelf_22S.nc
	cdo -s --no_warning timavg glby_${today}_across-shelf_22S.nc $out1
	cdo -s --no_warning timavg nemo_${today}_across-shelf_22S.nc $out2
	rm glby_${today}_across-shelf_22S.nc 
	rm nemo_${today}_across-shelf_22S.nc
#
#   the end
#
