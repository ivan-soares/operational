#!/usr/bin/env bash
#

####   Script to make clm & bry files to ROMS

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

       ######################  STEP 01: create clm and bry netcdf files

       mydate=`date`; echo >> $log
       echo "     ... step 01: ncgen clm/bry & write sig params @ $mydate" >> $log

       #### ncgen: create empty clim and bdry files
       create_ncfiles_clm+bry.sh $reftime $nlon $nlat $nsig
       mv clm.nc $romsclm
       mv bry.nc $romsbry

       #### computes sigma levels: Cs_r, Cs_w, s_rho, s_w
       #### writes out params & levels on newly created files
       python $makedir/make_clim_step01_write_clim_params.py $romsgrd $romsclm $romsbry $sig_params
       wait

       #####################  STEP 02: interpolates donor to roms, will need input files

       mydate=`date`; echo >> $log
       echo "     ... step 02: remap ogcmfile @ $mydate  " >> $log

       #### access previously created depthfiles, mask & gridfiles
       cp $operdir/d-interp/${ogcm}2sig/depths_*.nc .
       cp $operdir/d-interp/${ogcm}2sig/gridfile_*.txt .
       cp $operdir/d-interp/${ogcm}2sig/${ogcm}_mask.nc ogcm_mask.nc

       
       #### creates file ogcm_today.nc from donor ogcm
       $makedir/make_clim_step02a_access_ogcm.sh $ogcm $ogcmfile $today ; wait 

       #### reads ogcm_today.nc, inpaint nans, writes ogcm_today_nonans.nc
       python $makedir/make_clim_step02b_inpaint_nans_on_ogcm.py $ogcm $ndep $today $ndat ; wait

       #### reads ogcm_today_nonans, remap, writes clim_e, clim_u, clim_v
       $makedir/make_clim_step02c_remap_ogcm2roms.sh $today $ogcm; wait 

       ###################  STEP 03: writes newly interpolated vars on roms clim files

       mydate=`date`; echo >> $log
       echo "     ... step 03: write remaped vars on clm and bry files @ $mydate" >> $log
       echo >> $log

       #### will read clim_e, clim_u & clim_v & write on roms_clm & roms_bry 
       python $makedir/make_clim_step03_write_clim_vars.py  $dh $ndat $ogcm $today \
              $sig_params $romsgrd $romsclm $romsbry
       wait

       #### will read $romsclm and write on $romsclm2
       cp $romsclm ${romsclm}2
       python ${__dir}/step04_sub01_fix_climfile.py $romsgrd $romsclm; wait
       mv ${romsclm}2 $romsclm

       #### move files to storage

       mv $romsclm $stodir/$today/.
       mv $romsbry $stodir/$today/.


       #====================================================================================
       echo ; echo " ==> FINISHED making climfile for ROMS <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... finished clim files at $now" >> $log
       #====================================================================================

       cd ${__dir}

################################# *** the end *** ################################################

