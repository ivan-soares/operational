#!/bin/bash
#

####   Script to make clm & bry files to ROMS

       today=$1
       ogcm=$2
       here=$3
       log=$4

       source $here/hindcast_setup.sh # will load dir names and other info

       #=====================================================================================
       echo >> $log ; cd $tmpdir; dr=`pwd`
       echo ; echo " ==> HERE I am @ $dr for step 04: make clim files for ROMS <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... starting script to make clim files at $now" >> $log
       #=====================================================================================

       echo
       echo " ... today is ${yr}-${mm}-${dd}, ogcm is $ogcm"
       echo " ... will read $ndat time steps every $dh hours"
       echo " ... will run for $ndays day(s)"
       echo " ... donor file is $ogcmfile"
       echo

	cdo="$HOME/apps/bin/cdo -s --no_warnings"
	cdo="cdo -s --no_warnings"

	### interpolate all ogcm vars to grid_r.nc 
	### (assuming all ogcm vars are in grid A locations)

	rm -rf clim_${ogcm}_$today.nc grid_rho.nc weights_rho.nc
	cp $here/d-interp/grid_rho.nc .

	echo
	echo " ... starting cdo routines to remap ogcm $ogcm"
        echo

        $cdo genbil,grid_rho.nc $ogcmfile weights_rho.nc
	$cdo remap,grid_rho.nc,weights_rho.nc $ogcmfile clim_${ogcm}_$today.nc
	rm weights_rho.nc grid_rho.nc

	echo
	echo " ... starting cdo routine to vertically interp ogcm $ogcm"
	echo

	#### interp to sigma levels
	depth_lev="$here/d-interp/depths_${ogcm}.nc"
	depth_sig="$here/d-interp/depths_sig.nc"
        $cdo intlevelx3d,$depth_lev clim_${ogcm}_${today}.nc $depth_sig clim_${ogcm}_${today}_sig.nc
	cp clim_${ogcm}_${today}_sig.nc clim_${ogcm}_${today}_nonans.nc

        #### inpaint nans on ogcm file
	#### will read rotated_${ogcm}_$today_sig.nc and write rotated_${ogcm}_${today}_nonans.nc
	#### will need a land mask for ogcm to avoid wasting time inpainting nans on large land masses

        echo
	echo " ... starting python code to inpaint nan on ogcm $ogcm"
	echo

        ogcm_mask="$HOME/operational/roms/grids/grid_brz0.05r_01a_tmpmsk.nc"

	python $interp4roms/make_clim_step01_inpaint_nans_on_remaped_ogcm.py $today $ogcm $ndat $nsig $dh \
	       $romsgrd clim_${ogcm}_$today $ogcm_mask

	#echo
	#echo " ... creating new, empty clm & bry netcdf files, nlon/nlat = $nlon/$nlat"
	#echo

	#### ncgen: create empty clim and bdry files
	nlon=`ncdump -h $romsgrd | grep 'xi_rho = ' | awk '{print $3}'`
        nlat=`ncdump -h $romsgrd | grep 'eta_rho = ' | awk '{print $3}'`

        create_ncfiles_clm+bry.sh $reftime $nlon $nlat $nsig
        mv clm.nc $romsclm
        mv bry.nc $romsbry

	echo
	echo " ... tarting python code to write interpolated $ogcm on roms format"
	echo

	#### read ogcm and write roms clm & bry files
        python $interp4roms/make_clim_step02_write_clm_bry_files.py $ndat $today $ogcm $rotang $sig_params \
	       clim_${ogcm}_${today}_nonans.nc $romsgrd $romsclm $romsbry
	wait

        #### move files to storage

        mv $romsclm $stodir/$today/.
        mv $romsbry $stodir/$today/.

	#====================================================================================
	echo ; echo " ==> FINISHED making climfile for ROMS <=="; echo
	now=$(date "+%Y/%m/%d %T"); echo " ... finished clim files at $now" >> $log
	#====================================================================================

	cd $here

	################################# *** the end *** ############################################

