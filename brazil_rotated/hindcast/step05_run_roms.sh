#!/bin/bash
#

####   Script to run model ROMS

       today=$1
       ogcm=$2
       here=$3
       log=$4

       source $here/hindcast_setup.sh # will load dir names and other info

       #====================================================================================
       echo >> $log ; cd $tmpdir; dr=`pwd`
       echo ; echo " ==> HERE I am @ $dr for step 05: start ROMS <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... starting ROMS at $now" >> $log
       #====================================================================================

       echo
       echo " ... today is ${yr}-${mm}-${dd}"
       echo 
       echo " ... roms grid size is $nx x $ny x $nsig" 
       echo " ... roms grid limits are: x1,x2 = $x1,$x2, y1,y2 = $y1,$y2"
       echo " ... roms grid resolution is regular: $incr x $incr"
       echo
       echo " ... will store outputs in folder $stodir"
       echo
       echo " ... start day is $today"
       echo " ... the expt is $expt"
       echo " ... will run for $ndays day(s)"
       echo 
       echo " ... the donor file is $ogcmfile"
       echo " ... will read donor $ndat time steps every $dh hours"
       echo
       echo " ... the grid file is $romsgrd"
       echo " ... the nudg file is $romsnud"
       echo " ... the tide file is $romstid"
       echo

       ############################### *** set inputs/outputs *** ##################################################################

       inpdir="$tmpdir/roms_in"
       outdir="$tmpdir/roms_out"

       echo
       echo " ... will copy roms input files to $inpdir"
       echo " ... will output roms results to $outdir"
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

       ################ ***  make links to input files: grid, tides. nudge, clim, bdry *** #########################################

       source $here/step05_sub01_link_roms_inputfiles.sh
       wait

       ######### *** make ocean.in file: will create a file named $inpdir/ocean_${expt}.in *** #####################################
       
       source $here/step05_sub02_create_ocean-in.sh
	       wait

       cd $outdir

       ################################## *** run the model *** ####################################################################

       #export LD_LIBRARY_PATH="$HOME/Applications/netcdf-4.3.all/lib"
       #export LD_LIBRARY_PATH="$HOME/Applications/mpich-3.2/lib/":$LD_LIBRARY_PATH


       if    [ $ramp_flag == 'tide-with-ramp' ];  then echo " ... will use tide ramp"
       elif  [ $ramp_flag == 'tide-no-ramp'   ];  then echo " ... will NOT use tide ramp"
       else    echo " ... ERROR, wrong ramp choice, exiting "; exit 1
       fi

       if    [ $nudge_flag == 'ananudge'      ]; then echo " ... will use anannudge"
       elif  [ $nudge_flag == 'nudge-by-user' ]; then echo " ... will use nudge built by user"
       else    echo " ... ERROR, wrong nudge choice, exiting "; exit 1
       fi

       if    [ $avg_flag == 'avg'  -o $avg_flag == 'avg_debug' ]; then echo " ... will compute daily averages"
       elif  [ $avg_flag == 'no_avg' ]; then echo " ... will NOT compute daily averages"
       else    echo " ... ERROR, wrong avg choice, exiting "; exit 1
       fi

       roms_exec="romsM_${ramp_flag}_${nudge_flag}_${avg_flag}"

       echo
       echo " ... roms executable code is $roms_exec"
       echo

       if [ ! -e $roms_codedir/$roms_exec ]; then
	       echo " ... ERROR, ROMS executable $roms_codedir/$roms_exec was not found"
	       echo " ... exiting"; exit; echo
       fi

       echo
       echo " ... starting the model"
       echo

       now=$(date "+%Y/%m/%d %T"); echo " ==> starting forecast at $now" ; echo

       nprocs=`echo $ntile_i $ntile_j | awk '{print $1*$2}'`

       #srun -n 60 --mpi=pmi2 $roms_codedir/$roms_exec $inpdir/ocean_${expt}.in >& roms.log &
       mpirun -np $nprocs $roms_codedir/$roms_exec $inpdir/ocean_${expt}.in >& roms.log &
       wait

       now=$(date "+%Y/%m/%d %T"); echo " ==> end of forecast at $now" ; echo

       echo
       echo " ... end of simulation"
       echo

       ################################## *** move outputs *** #######################################################################

       echo
       echo " ... move files to storage"
       echo

       d="${domain_roms}_${version}"

       mv roms.log      $stodir/$today/roms_${today}_${ogcm}.log
       mv roms_his.nc   $stodir/$today/roms_his_${d}_${today}_${ogcm}.nc

       nlast=`ncdump -h roms_rst.nc | grep "currently" | sed 's/(/ /g' | awk '{print $6-1}'`

       ncks -d ocean_time,$nlast roms_rst.nc   rst.nc
       rstdate=`cdo -s --no_warnings showtimestamp rst.nc | sed -e 's/\-//g' -e 's/T/ /g' | awk '{print $1}'`
       mv rst.nc $stodir/$today/roms_rst_${d}_${rstdate}_${ogcm}.nc

       if [ $avg_flag == 'avg' ]; then mv roms_avg.nc   $stodir/$today/roms_avg_${d}_${today}_${ogcm}.nc; fi

       cd $tmpdir

       ########################## *** convert outputs from sigma to z levels *** ####################################################

       source $here/step05_sub03_convert_sig2z.sh

       ####################### finish
       
       #====================================================================================
       echo ; echo " ==> FINISHED running ROMS <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... finished ROMS at $now" >> $log
       #====================================================================================

       cd $here

##################################   ***  the end  *** ##############################################################################
