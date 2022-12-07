#!/bin/bash
#
     today=$1

     ### roms + nemo

     inpdir="$HOME/operational/forecast/store"
     infile="$inpdir/$today/roms_brz0.05_01g_${today}_his_nemo.nc"
     outfile1="roms_nemo_${today}_sse.nc"
     outfile2="roms_nemo_${today}_nne.nc"

     ### sse
     ncks -v temp,salt,zeta,u_eastward,v_northward,lon_rho,lat_rho \
          -d eta_rho,18,280 -d xi_rho,40,320  \
          -d s_rho,29 $infile $outfile1

     ### nne
     ncks -v temp,salt,zeta,u_eastward,v_northward,lon_rho,lat_rho \
     	-d eta_rho,458,800 -d xi_rho,1,400  \
     	-d s_rho,29 $infile $outfile2

     ### roms + hycom

     inpdir="$HOME/operational/atlantic/forecast/d-storage"
     infile="$inpdir/$today/roms_his_brz0.05_01g_${today}_glby.nc"
     outfile1="roms_glby_${today}_sse.nc"
     outfile2="roms_glby_${today}_nne.nc"

     ### sse
     ncks -v temp,salt,zeta,u_eastward,v_northward,lon_rho,lat_rho \
          -d eta_rho,18,280 -d xi_rho,40,320  \
          -d s_rho,29 $infile $outfile1

     ### nne
     ncks -v temp,salt,zeta,u_eastward,v_northward,lon_rho,lat_rho \
          -d eta_rho,458,800 -d xi_rho,1,400  \
          -d s_rho,29 $infile $outfile2

     ### satelite
     inpdir="$HOME/operational/atlantic/forecast/d-storage"
     infile="$inpdir/$today/cmems_multiobs_atl0.25_${today}.nc"
     infile="$inpdir/$today/cmems_sla_vels_atl0.25_${today}.nc"
     outfile1="sat_sla_vels_${today}_sse.nc"
     outfile2="sat_sla_vels_${today}_nne.nc"

     ### sse
     ncks -d latitude,-29.0,-16.0 -d longitude,-50.0,-36.0 $infile $outfile1

     ### nne
     ncks -d latitude,-7.0,10.0 -d longitude,-52.0,-32.0 $infile $outfile2


#
#  the end
#
