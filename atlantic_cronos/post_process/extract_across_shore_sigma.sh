#!/bin/bash
#
	today=$1

	echo
	echo " +++ Starting script to extract a cross shelf snapshot +++"
	echo

	ddir="$HOME/operational/atlantic/forecast/d-storage"


	romsglby="$ddir/$today/roms_avg_brz0.05_01g_${today}_glby.nc"
	romsnemo="$ddir/$today/roms_avg_brz0.05_01g_${today}_nemo.nc"
	glby="$ddir/$today/input_clm_brz0.05_01g_${today}_glby.nc"
	nemo="$ddir/$today/input_clm_brz0.05_01g_${today}_nemo.nc"

	################# lat 22 S

	ncks -d eta_rho,160 -d eta_u,160 -d eta_v,159 -d xi_rho,218,331 -d xi_u,218,330 -d xi_v,218,331 $romsglby roms_glby_${today}_across-shelf_22S.nc
	ncks -d eta_rho,160 -d eta_u,160 -d eta_v,159 -d xi_rho,218,331 -d xi_u,218,330 -d xi_v,218,331 $romsnemo roms_nemo_${today}_across-shelf_22S.nc
	cdo -s --no_warning timavg roms_glby_${today}_across-shelf_22S.nc across-shelf_22S_${today}_roms+glby_sigma.nc
	cdo -s --no_warning timavg roms_nemo_${today}_across-shelf_22S.nc across-shelf_22S_${today}_roms+nemo_sigma.nc
	rm roms_glby_${today}_across-shelf_22S.nc roms_nemo_${today}_across-shelf_22S.nc

	ncks -d eta_rho,160 -d eta_u,160 -d eta_v,159 -d xi_rho,218,331 -d xi_u,218,330 -d xi_v,218,331 $glby glby_${today}_across-shelf_22S.nc
	ncks -d eta_rho,160 -d eta_u,160 -d eta_v,159 -d xi_rho,218,331 -d xi_u,218,330 -d xi_v,218,331 $nemo nemo_${today}_across-shelf_22S.nc
	cdo -s --no_warning timavg glby_${today}_across-shelf_22S.nc across-shelf_22S_${today}_glby_sigma.nc
	cdo -s --no_warning timavg nemo_${today}_across-shelf_22S.nc across-shelf_22S_${today}_nemo_sigma.nc
	rm glby_${today}_across-shelf_22S.nc nemo_${today}_across-shelf_22S.nc

        ################# lat 25 S

	ncks -d eta_rho,100 -d eta_u,100 -d eta_v,99 -d xi_rho,66,331 -d xi_u,66,330 -d xi_v,66,331 $romsglby roms_glby_${today}_across-shelf_25S.nc
	ncks -d eta_rho,100 -d eta_u,100 -d eta_v,99 -d xi_rho,66,331 -d xi_u,66,330 -d xi_v,66,331 $romsnemo roms_nemo_${today}_across-shelf_25S.nc
	cdo -s --no_warning timavg roms_glby_${today}_across-shelf_25S.nc across-shelf_25S_${today}_roms+glby_sigma.nc
	cdo -s --no_warning timavg roms_nemo_${today}_across-shelf_25S.nc across-shelf_25S_${today}_roms+nemo_sigma.nc
	rm roms_glby_${today}_across-shelf_25S.nc roms_nemo_${today}_across-shelf_25S.nc

	ncks -d eta_rho,100 -d eta_u,100 -d eta_v,99 -d xi_rho,66,331 -d xi_u,66,330 -d xi_v,66,331 $glby glby_${today}_across-shelf_25S.nc
	ncks -d eta_rho,100 -d eta_u,100 -d eta_v,99 -d xi_rho,66,331 -d xi_u,66,330 -d xi_v,66,331 $nemo nemo_${today}_across-shelf_25S.nc
	cdo -s --no_warning timavg glby_${today}_across-shelf_25S.nc across-shelf_25S_${today}_glby_sigma.nc
	cdo -s --no_warning timavg nemo_${today}_across-shelf_25S.nc across-shelf_25S_${today}_nemo_sigma.nc
	rm glby_${today}_across-shelf_25S.nc nemo_${today}_across-shelf_25S.nc

	################# lat 28 S

	ncks -d eta_rho,40 -d eta_u,40 -d eta_v,39 -d xi_rho,62,331 -d xi_u,62,330 -d xi_v,62,331 $romsglby roms_glby_${today}_across-shelf_28S.nc
	ncks -d eta_rho,40 -d eta_u,40 -d eta_v,39 -d xi_rho,62,331 -d xi_u,62,330 -d xi_v,62,331 $romsnemo roms_nemo_${today}_across-shelf_28S.nc
	cdo -s --no_warning timavg roms_glby_${today}_across-shelf_28S.nc across-shelf_28S_${today}_roms+glby_sigma.nc
	cdo -s --no_warning timavg roms_nemo_${today}_across-shelf_28S.nc across-shelf_28S_${today}_roms+nemo_sigma.nc
	rm roms_glby_${today}_across-shelf_28S.nc roms_nemo_${today}_across-shelf_28S.nc
						        
	ncks -d eta_rho,40 -d eta_u,40 -d eta_v,39 -d xi_rho,62,331 -d xi_u,62,330 -d xi_v,62,331 $glby glby_${today}_across-shelf_28S.nc
	ncks -d eta_rho,40 -d eta_u,40 -d eta_v,39 -d xi_rho,62,331 -d xi_u,62,330 -d xi_v,62,331 $nemo nemo_${today}_across-shelf_28S.nc
	cdo -s --no_warning timavg glby_${today}_across-shelf_28S.nc across-shelf_28S_${today}_glby_sigma.nc
	cdo -s --no_warning timavg nemo_${today}_across-shelf_28S.nc across-shelf_28S_${today}_nemo_sigma.nc
	rm glby_${today}_across-shelf_28S.nc nemo_${today}_across-shelf_28S.nc




#
#   the end
#
