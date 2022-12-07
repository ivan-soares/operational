#!/bin/bash
#
	today=$1
	ndays=$2
	ogcm=$3
	here=$4
	log=$5
	nn=1

        sed -i "/ ndays=/ c\        ndays=$ndays "  forecast_setup.sh

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

	cdo="$HOME/Applications/cdo-1.9.7/bin/cdo -s --no_warnings"
	cdo="cdo -s --no_warnings"

	################################### horizontal interpolation

	now=$(date "+%Y/%m/%d %T")

	echo
	echo "     ... horizontal interpolation: remap donor ogcm to roms grid"
	echo "     ... horizontal interpolation: remap donor ogcm to roms grid at $now" >> $log
	echo

	mdate=$today

	while [ $nn -le $ndays ]; do


		ogcmfile="$HOME/new_storage/environment/hncoda_glby_npo0.08_167W117W-15N47N_06h/glby_npo_${mdate}.nc"

		rm -rf grid_r.nc weights_r.nc
		ncks -v lon_rho,lat_rho $romsgrd grid_r.nc
		ncrename -h -O -v lon_rho,lon -v lat_rho,lat grid_r.nc
		$cdo genbil,grid_r.nc $ogcmfile weights_r.nc
		$cdo remap,grid_r.nc,weights_r.nc $ogcmfile remaped_${ogcm}_$mdate.nc

		################################## vertical interpolation

		now=$(date "+%Y/%m/%d %T")

		echo 
		echo "     ... vertical interpolation: interp remaped ogcm to sigma level"
		echo "     ... vertical interpolation: interp remaped ogcm to sigma level at $now" >> $log
		echo

		#### interp to sigma levels
		depth_z=$here/d-interp/${ogcm}2sig/depths_z_rho.nc
		depth_sig=$here/d-interp/${ogcm}2sig/depths_sig_rho.nc
		$cdo intlevel3d,$depth_z remaped_${ogcm}_${mdate}.nc $depth_sig remaped_${ogcm}_${mdate}_sig.nc
		cp remaped_${ogcm}_${mdate}_sig.nc remaped_${ogcm}_${mdate}_nonans.nc

		################################### inpaint nans

		now=$(date "+%Y/%m/%d %T")
		echo "     ... inpaint nans on remaped, sigma coord ogcm"
		echo "     ... inpaint nans on remaped, sigma coord ogcm at $now" >> $log

		tmpmask="$here/d-interp/roms_${domain_roms}_${version}_tmpmsk.nc"

		echo
		echo "     ... will use a temporary roms mask $tmpmask"
		echo "     ... to avoid inpainting on land points"
		echo

		python $interp4roms/make_clim_step01_inpaint_nans_on_remaped_ogcm.py $mdate $ogcm $ndat $nsig $dh \
		      $romsgrd remaped_${ogcm}_$mdate $tmpmask

		################################# re-write interpolated ogcm vars on staggered grid

		now=$(date "+%Y/%m/%d %T")
		echo "     ... re-write interpolated ogcm vars on staggered grid"
		echo "     ... re-write interpolated ogcm vars on staggered grid at $now" >> $log

		create_ncfiles_clm+bry.sh $reftime $nlon $nlat $nsig
		mv clm.nc $romsclm
		mv bry.nc $romsbry

		#### read ogcm and write roms clm & bry files
		python $interp4roms/make_clim_step02_write_clm_bry_files.py $ndat $mdate $ogcm $rotang $sig_params \
		       remaped_${ogcm}_${mdate}_nonans.nc $romsgrd $romsclm $romsbry


		#### move files to storage

		mv $romsclm $stodir/$mdate/.
		mv $romsbry $stodir/$mdate/.

		mdate=`find_tomorrow.sh $yr $mm $dd`

		yr=${mdate:0:4}
		mm=${mdate:4:2}
		dd=${mdate:6:2}

		let nn=$nn+1

	done

	cd $here

	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... finished making input files for ROMS at $now" >> $log; echo >> $log
	echo " ==> $now FINISHED making input files for ROMS <=="; echo
	#====================================================================================

################################# *** the end *** ################################################

