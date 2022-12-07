#!/bin/bash
#
	rm zeta*
	
	for d in 11 12 13 14 15 16 17 18 19 20 ; do 
	    ncks -v zeta -d ocean_time,0,23 \
	    d-storage/202001${d}/roms_his_brz0.05_01g_202001${d}_glby.nc \
	    zeta_202001${d}.nc 
        done
	
	cdo mergetime zeta_20* zeta.nc
	rm zeta_20*
#
#   the end
#
