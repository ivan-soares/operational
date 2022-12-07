#!/usr/bin/env bash
#

####   Script to run the model WW3

       #====================================================================================
       echo >> $log ; cd $tmpdir; dr=`pwd`
       echo ; echo " ==> HERE I am @ $dr for step 07: start WW3 <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... starting WW3 at $now" >> $log
       #====================================================================================

       echo
       echo " ... today is ${yr}-${mm}-${dd}"
       echo
       echo " ... ww3 domains are $domain_ww3"
       echo 


###################  copy windfile, restartfiles & gridfiles  ###################################

       inpdir="$tmpdir/ww3_in"
       outdir="$tmpdir/ww3_out"

       echo
       echo " ... will copy ww3 input files to $inpdir"
       echo " ... will output ww3 results to $outdir"
       echo

       if [ -d $inpdir ]; then
              echo " ... $inpdir exists, will use it"
       else
              echo " ... $inpdir DOES NOT exist, will create it"
              mkdir $inpdir
       fi
       if [ -d $outdir ]; then
              echo " ... $outdir exists, will use it"
       else
              echo " ... $outdir DOES NOT exist, will create it"
              mkdir $outdir
       fi

       rm -f $outdir/*
       rm -f $inpdir/*

       cd $inpdir

       ##### get input files: wind, restarts, grids
       source ${__dir}/step07_sub01_link_ww3_inputfiles.sh

       # buoy file was made in step06

############# go back to work directory 'd-tempo' & run the model ############################

       cd $tmpdir

       last=`date -d "$today +${ndays} days" +%Y%m%d`

       # run multi grid
       $ww3_codedir/run_ww3_multi-grid_new.sh $today $last $icomp $ncdf $wind $buoy \
              $inpdir $outdir $domain_ww3; wait

       # convert .out to .nc
       for d in $domain_ww3; do
           $ww3_codedir/bin2cdf_gridded_new.sh $today $nhrs_ww3 $d yes $ncdf \
                $inpdir $outdir $fields; wait
       done

       # 2d pnt spectral data
       #$ww3dir/bin2cdf_point.sh $today $nhrs yes $ncdf 1
       #wait
       #
       # 1d pnt spectral data
       #$ww3dir/bin2cdf_point.sh $today $nhrs yes $ncdf 2
       #wait

###################  move output files to storage  ###########################################

       for d in $domain_ww3; do
           mv $outdir/ww3_rst_${d}_*         $stodir/$today/
           mv $outdir/ww3_out_${d}_${yr}.nc  $stodir/$today/ww3_his_${d}_${today}.nc
       done

       #mv $outdir/ww3_out_pnt_${yr}_spec.nc \
       #   $stodir/$today/ww3_toc_pnt_${today}_spec.nc
       #
       #mv $outdir/ww3_out_pnt_${yr}_tab.nc \
       #   $stodir/$today/ww3_toc_pnt_${today}_tab.nc


       #====================================================================================
       echo ; echo " ==> FINISHED running WW3 <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... finished WW3 at $now" >> $log
       #====================================================================================

       cd ${__dir}

################################# *** the end *** ################################################


