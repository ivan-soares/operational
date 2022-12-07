#!/usr/bin/env bash
#

####    Script to fix GFS

	today=$1

	domain_wind="glo0.50"
	domain_wind2="brz0.50"

	wesn_gfs=" -53.0 -24.0 -31.0 11.0"

        inpdir="$HOME/operational/atlantic/forecast/d-data"
	stodir="$HOME/operational/atlantic/forecast/d-storage/$today"
	bashdir="$HOME/operational/scripts/bash"

	# create a force file for WW3
	#$bashdir/fix_gfs_nomads4ww3.sh $inpdir/gfs_$today.nc gfs_${domain_wind}_$today.nc $today

	# create a force file for ROMS
	$bashdir/fix_gfs_nomads4roms.sh $inpdir/gfs_$today.nc gfs_${domain_wind2}_$today.nc $today $wesn_gfs

	#mv gfs_${today}.nc                 ${stodir}/
	#mv gfs_${domain_wind}_${today}.nc   ${stodir}/
	mv gfs_${domain_wind2}_${today}.nc   ${stodir}/


################################## *** the end *** ##############################################

