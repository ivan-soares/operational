#!/bin/bash
#

        #### S07

	today=$1
	nhrs=$2
	here=$3
	log=$4

	source $here/forecast_setup.sh # will load dir names and other info

	#====================================================================================
	echo ; cd $tmpdir; dr=`pwd`; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... starting WW3 forecast expt at $now" >> $log; echo >> $log
	echo " ==> $now HERE I am @ $dr for step 07: run WW3 <=="; echo
	#====================================================================================

	echo
	echo " ... today is ${yr}-${mm}-${dd}"
	echo
	echo " ... ww3 domain(s) $domain_ww3"
	echo " ... ww3 forecast point coordinate is $pcoord"
	echo 
        echo 

	###################  copy windfile, restartfiles & gridfiles

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

	echo ; echo " ... get input files: wind, restarts, grids" ; echo

	source $here/step07_sub01_link_ww3_inputfiles.sh

	# buoy file was made in step06

	############# go back to work directory 'd-temporary' & run the model 

	cd $tmpdir

	echo; echo " ... run ww3 multi-grid" ; echo

	$ww3_codedir/run_ww3_multi-grid_oper.sh $date_ini $date_end $date_rst $icomp \
	             $ncdf $wnd $buoy $inpdir $outdir $domain_ww3; wait

	echo ; echo " ... move files to storage " ; echo

	mv $outdir/ww3_out_* $stodir/$today/.
	mv $outdir/mod_def.* $stodir/$today/.
	mv $outdir/logfile_* $logdir/$today/.


	##### when running bin2cdf, read & write from storage
	echo ; echo " ... convert binary results to netcdf"; echo 

	for d in $domain_ww3; do
	      $ww3_codedir/bin2cdf_gridded.sh $date_ini $nhrs $d yes $ncdf \
	      $inpdir $stodir/$today $fields; wait
	done

	echo ; echo " ... move logfile to storage" ; echo

	mv $stodir/$today/logfile_* $logdir/$today/.

	# 2d pnt spectral data
	#$ww3dir/bin2cdf_point.sh $today $nhrs yes $ncdf 1
	#wait
	#
	# 1d pnt spectral data
	#$ww3dir/bin2cdf_point.sh $today $nhrs yes $ncdf 2
	#wait


	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... finished WW3 forecast at $now" >> $log; echo >> $log
	echo " ==> $now FINISHED running ww3 <=="; echo
	#====================================================================================

	cd $here

################################# *** the end *** ################################################


