#!/bin/bash
#

	#### S04

	today=$1
	ogcm=$2
	here=$3
	log=$4

	source $here/forecast_setup.sh # will load dir names and other info

	#=====================================================================================
	echo ; cd $tmpdir; dr=`pwd`; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... starting script to make input files for ROMS at $now" >> $log; echo >> $log
	echo " ==> $now HERE I am @ $dr for step 04: make input files for ROMS <=="; echo
	#=====================================================================================

	echo
	echo " ... today is ${yr}-${mm}-${dd}, ogcm is $ogcm"
	echo " ... will read $ndat time steps every $dh hours"
	echo " ... will run for $ndays day(s)"
	echo " ... donor file is $ogcmfile"
	echo

	cdo="$HOME/apps/cdo-1.9.7.1/bin/cdo -s --no_warnings"
	cdo="cdo -s --no_warnings"

	################################### horizontal interpolation

	now=$(date "+%Y/%m/%d %T")

	echo
	echo "     ... horizontal interpolation: remap donor ogcm to roms grid"
	echo "     ... horizontal interpolation: remap donor ogcm to roms grid at $now" >> $log
	echo

	rm -rf grid_r.nc weights_r.nc
	if [ -e $operdir/d-interp/grid_r_${domain_roms}.nc ]; then
		echo " ... found file grid_r_${domain_roms}.nc; will use it !!"; echo
		cp $operdir/d-interp/grid_r_${domain_roms}.nc grid_r.nc
	else
		ncks -v h,lon_rho,lat_rho $romsgrd grid_r.nc
		ncrename -h -O -v lon_rho,lon -v lat_rho,lat grid_r.nc
		ncatted -h -O -a coordinates,h,c,c,"lon lat" grid_r.nc
	fi
	$cdo genbil,grid_r.nc $ogcmfile weights_r.nc
	$cdo remap,grid_r.nc,weights_r.nc $ogcmfile remaped_${ogcm}_$today.nc

	################################## vertical interpolation

	now=$(date "+%Y/%m/%d %T")

	echo 
	echo "     ... vertical interpolation: interp remaped ogcm to sigma level"
	echo "     ... vertical interpolation: interp remaped ogcm to sigma level at $now" >> $log
	echo

	#### interp to sigma levels
	depth_z=$here/d-interp/depths_${ogcm}_${domain_roms}.nc
	depth_sig=$here/d-interp/depths_sig_${domain_roms}.nc
	$cdo intlevel3d,$depth_z remaped_${ogcm}_${today}.nc $depth_sig remaped_${ogcm}_${today}_sig.nc
	cp remaped_${ogcm}_${today}_sig.nc remaped_${ogcm}_${today}_nonans.nc

	################################### inpaint nans

	now=$(date "+%Y/%m/%d %T")
	echo "     ... inpaint nans on remaped, sigma coord ogcm"
	echo "     ... inpaint nans on remaped, sigma coord ogcm at $now" >> $log

	tmpmask="$here/d-interp/roms_${domain_roms}_${version}_tmpmsk.nc"

	echo
	echo "     ... will use a temporary roms mask $tmpmask"
	echo "     ... to avoid inpainting on land points"
	echo

	python $interp4roms/make_clim_step01_inpaint_nans_on_remaped_ogcm.py $today $ogcm $ndat $nsig $dh \
	      $romsgrd remaped_${ogcm}_$today $tmpmask

	################################# re-write interpolated ogcm vars on staggered grid

	now=$(date "+%Y/%m/%d %T")
	echo "     ... re-write interpolated ogcm vars on staggered grid"
	echo "     ... re-write interpolated ogcm vars on staggered grid at $now" >> $log

	create_ncfiles_clm+bry.sh $reftime $nlon $nlat $nsig
	mv clm.nc $romsclm
	mv bry.nc $romsbry

	#### read ogcm and write roms clm & bry files
	python $interp4roms/make_clim_step02_write_clm_bry_files.py $ndat $today $ogcm $rotang $sig_params \
	       remaped_${ogcm}_${today}_nonans.nc $romsgrd $romsclm $romsbry


	#### move files to storage

	mv $romsclm $stodir/$today/.
	mv $romsbry $stodir/$today/.

	cd $here

	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... finished making input files for ROMS at $now" >> $log; echo >> $log
	echo " ==> $now FINISHED making input files for ROMS <=="; echo
	#====================================================================================

################################# *** the end *** ################################################

