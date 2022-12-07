#!/usr/bin/env bash
#

####   Script to run model ROMS

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

       source ${__dir}/step05_sub01_link_roms_inputfiles.sh

       ######### *** make ocean.in file: will create a file named $inpdir/ocean_${expt}.in *** #####################################

       source ${__dir}/step05_sub02_create_ocean-in.sh

       cd $outdir

       ################################## *** run the model *** ####################################################################

       #export LD_LIBRARY_PATH="$HOME/Applications/netcdf-4.3.all/lib"
       #export LD_LIBRARY_PATH="$HOME/Applications/mpich-3.2/lib/":$LD_LIBRARY_PATH

       if    [ $ramp_flag == 'tide_with_ramp' ];  then echo " ... will use tide ramp"
       elif  [ $ramp_flag == 'tide_no_ramp'   ];  then echo " ... will NOT use tide ramp"
       else    echo " ... ERROR, wrong ramp choice, exiting "; exit 1
       fi

       if    [ $nudge_flag == 'ananudge'      ]; then echo " ... will use anannudge"
       elif  [ $nudge_flag == 'nudge_by_user' ]; then echo " ... will use nudge built by user"
       else    echo " ... ERROR, wrong nudge choice, exiting "; exit 1
       fi

       if    [ $avg_flag == 'avg'    ]; then echo " ... will compute daily averages"
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

       # srun -n 60 --mpi=pmi2 $roms_codedir/$roms_exec $inpdir/ocean_${expt}.in >& roms.log &

       cp $inpdir/ocean_${expt}.in ocean.in
       
       cat <<EOF > job.sh
#PBS -N roms
#PBS -j oe

export PREFIX=/shared/opt/gnusoft
export PATH=\$PREFIX/bin:\$PATH
export LD_LIBRARY_PATH="\$PREFIX/lib:\$LD_LIBRARY_PATH"

cd $outdir

mpirun -np 60 $roms_codedir/$roms_exec ocean.in > roms.log

now=\$(date "+%Y/%m/%d %T")
echo " ... end of simulation @ \$now" >& endos
EOF
       qsub -l "nodes=1:ppn=60" job.sh
       while [ ! -e endos ]; do
           sleep 1s
       done
       rm endos
       ################################## *** check outputs *** #####################################################################

       echo
       echo " ... now we check that history file exists and has $nhrs_roms time steps"
       echo

       d="${domain_roms}_${version}"
       romshis="roms_his.nc"

       if [ -e $romshis ]; then

              echo " ... found file $romshis"
              npassos=`ncdump -h $romshis | grep "ocean_time = UNLIMITED" | sed -e 's/(//g' | awk '{print $6}'`
              echo " ... the # of time steps in the file is $npassos"
              echo " ... the # of expected time steps is $nhrs_roms"

              if [ $npassos -eq $nhrs_roms ]; then

                     echo 
                     echo " ... all is fine, roms history file $romshis has $npassos steps"
                     echo " ... move output files to storage"
                     echo

                     mv roms.log      $stodir/$today/roms_${today}_${ogcm}.log
                     mv roms_his.nc   $stodir/$today/roms_his_${d}_${today}_${ogcm}.nc
                     mv roms_rst.nc   $stodir/$today/roms_rst_${d}_${tomorrow}_${ogcm}.nc

        	     if [ $avg_flag == 'avg' ]; then
                          mv roms_avg.nc   $stodir/$today/roms_avg_${d}_${today}_${ogcm}.nc
                     fi

              else

                     echo                
                     echo " ... roms history is not OK, it has $npassos steps"
                     echo " ... will use yesterday's file"
                     echo

		     mv roms.log      $stodir/$today/roms_${today}_${ogcm}.log
                     ncks -d ocean_time,8,$npassos $stodir/$yesterday/roms_his_${d}_${yesterday}_${ogcm}.nc \
                     $stodir/$today/roms_his_${d}_${today}_${ogcm}.nc2

              fi
       else

              echo
              echo " ... roms history was NOT found"
              echo " ... will use yesterday's file"
              echo

	      mv roms.log      $stodir/$today/roms_${today}_${ogcm}.log
              ncks -d ocean_time,8,$npassos $stodir/$yesterday/roms_his_${d}_${yesterday}_${ogcm}.nc \
              $stodir/$today/roms_his_${d}_${today}_${ogcm}.nc2

       fi

       cd $tmpdir

       ########################## *** convert outputs from sigma to z levels *** ####################################################

       source ${__dir}/step05_sub03_convert_sig2z.sh
       wait

       ####################### finish

       #====================================================================================
       echo ; echo " ==> FINISHED running ROMS <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... finished ROMS at $now" >> $log
       #====================================================================================

       cd ${__dir}

##################################   ***  the end  *** ##############################################################################
