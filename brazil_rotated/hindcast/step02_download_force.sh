#!/bin/bash
#

####    Script to download GFS

	today=$1
	ogcm=$2
	here=$3
	log=$4

        source $here/hindcast_setup.sh # will load dir names and other info

	#====================================================================================
	echo >> $log ; cd $tmpdir; dr=`pwd`
	echo ; echo " ==> HERE I am @ $dr for step 02: download GFS data <=="; echo
	now=$(date "+%Y/%m/%d %T"); echo " ... starting download of GFS at $now" >> $log
	#====================================================================================

	echo
	echo " ... today is ${yr}-${mm}-${dd}"
	echo " ... will use dqdsst $dqdsst watt/m2/deg C"
	echo " ... will download $nhrs hours"
	echo " ... will store downloaded files in folder $stodir"
	echo

	nn=1
	mdate=$today
	y1=${mdate:0:4}
	m1=${mdate:4:2}
	d1=${mdate:6:2}

	rm -rf tmp*

	while [ $nn -le $ndays ]; do
	      # will download a file named gfsanl_$today.nc containing 1 day global GFS
	      echo " ... downloading gfs for date $mdate"
	      get_gfsanl4_historical_one_day.sh $mdate
	      ncks -d time,0,7 gfs_${mdate}.nc tmp
	      mv tmp gfs_${mdate}.nc
              mdate=`find_tomorrow.sh $y1 $m1 $d1`
	      y1=${mdate:0:4}
	      m1=${mdate:4:2}
              d1=${mdate:6:2}
              let nn=$nn+1
        done

	echo " ... today is $today"
	echo " ... ndate is $mdate"
	echo

	#### get an extra day at the end $ndays period to allow for time interpolations
	echo " ... downloading gfs for date $mdate"
	get_gfsanl4_historical_one_day.sh $mdate
        ncks -d time,0 gfs_${mdate}.nc tmp
        mv tmp gfs_${mdate}.nc

	echo; echo " ... merge all files in one"; echo
	cdo mergetime gfs_20*.nc gfsanl_$today.nc
	mv gfs_20*.nc $trunk/.

	#cdo mergetime ~/data/gfs/gfs_${yr}${mm}* ~/data/gfs/gfs_$mdate.nc gfsanl_$today.nc

	# create a force file for WW3
	fix_gfs_nomads4ww3.sh gfsanl_$today.nc gfs_glo0.50_$today.nc $today

	# create a force file for ROMS
	fix_gfs_nomads4roms.sh gfsanl_$today.nc gfs_${domain_wind}_${today}.nc \
		$today $wesn_gfs $dqdsst

	mv gfsanl_${today}.nc               ${stodir}/${today}/
	mv gfs_glo0.50_${today}.nc          ${stodir}/${today}/
	mv gfs_${domain_wind}_${today}.nc   ${stodir}/${today}/

	#====================================================================================
	echo ; echo " ==> FINISHED downloading GFS <=="; echo
	now=$(date "+%Y/%m/%d %T"); echo " ... finished download at $now" >> $log
	#====================================================================================

	cd $here

################################## *** the end *** ##############################################

