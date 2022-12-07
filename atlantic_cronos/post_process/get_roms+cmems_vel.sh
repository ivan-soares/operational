#!/bin/bash
#
	today=$1

	inpfile="$today/roms_brz0.05_01g_${today}_glby_zlevs.nc"
	outfile="roms_${today}_glby_surface.nc"

	cdo select,name=u,v                         $inpfile tmp1.nc
	cdo sellevel,0                               tmp1.nc tmp2.nc
	cdo expr,'vzao=sqrt(u*u+v*v)'                tmp2.nc tmp3.nc 
	ncks -d lat,-26.5,-18.75 -d lon,-50.1,-35.1  tmp3.nc $outfile
        rm tmp*

	inpfile="$today/cmems_sla+vels_atl0.25_${today}.nc"
	outfile="cmems_${today}.nc"

	cdo expr,'vzao=sqrt(ugos*ugos+vgos*vgos)'               $inpfile tmp1.nc
	ncks -d latitude,-26.5,-18.75 -d longitude,-50.1,-35.1   tmp1.nc $outfile
	rm tmp*
#
#   the end
#

