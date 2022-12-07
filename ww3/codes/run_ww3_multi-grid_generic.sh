#!/bin/bash

#############################################################################################################
#                                                                                                           #
#                Bash script to run Wave Watch III, v5.16                                                   #
#                                                                                                           #
#                                                                                 IDS @ AT, Fpolis 2022     #
#                                                                                                           #
#############################################################################################################

	set -o errexit  # exit in case of fail
	set -o pipefail # if one command in the pipe fails the entire pipeline will fail
	set -o nounset  # report an error & exist if encounters a variable that doesnt exist.
	#set -o xtrace    # output the executed command line before its execution result.



	help_txt="date_ini, date_end, date_rst, inpdir, outdir"

	if [ "$1" == "-h" ]; then
		echo " "
		echo "    Usage: `basename $0` [$help_txt]"
		echo " "
		exit 0
	fi

#############################################################################################################

	date_ini=${@:1:1}
	date_end=${@:2:1}
	date_rst=${@:3:1}

	inpdir=${@:4:1}
	outdir=${@:5:1}

#############################################################################################################

        ##### load file containing specifications about forcing and grds
        source $inpdir/case_config.sh

	echo
	echo " +++ Starting bash program run_multi-grid on grid $grds +++"
	echo

	echo 
	echo " ... ini date is ${date_ini:0:8} ${date_ini:9:16}"
	echo " ... end date is ${date_end:0:8} ${date_end:9:16}"
	echo " ... winds are set as $wnd"
	echo " ... buoys are set as $buoy"
	echo

#############################################################################################################
#                                                                                                           #
#                                         0. Preparations                                                   #
#                                                                                                           #
#############################################################################################################

	set -e

##### Define model forcings

	force=('wind' 'ice' 'lvl' 'cur')
	buo=$buoy
	
##### Set input/output directories

	case_dir=${PWD}

	path_d="$inpdir"       # path for wind file, buoy file & restarts
	path_g="$inpdir"       # path for grid files
	path_i="$inpdir"       # path for model input files

	path_r="$outdir"       # path for model results: binary and netcdf


	# path for ww3 code
	ww3_dir="${HOME}/ww3/code_v5.16"

	echo " ... ww3dir is $ww3_dir"

	path_e="$ww3_dir/exe"        # path for executables
	path_b="$ww3_dir/bin"        # path for binaries

##### Set run times: undefined t_rst will give no restart file

        t_ini="${date_ini:0:8}"
        t_end="${date_end:0:8}"
        t_rst="${date_rst:0:8}"

        #t_ini="${date_ini:0:8} 060000"
        #t_end="${date_end:0:8} 000000"
        #t_rst="${date_rst:0:8} 000000"

##### Parallel environment & compiler options

	mpi='yes'             
	nprocs=40
	compstr="gfortran"

	echo
	echo " ... running the model with mpi $mpi & netcdf $ncdf"
	echo " ... n. of processors: $nprocs & fortran compiler $compstr"
	echo

	export WWATCH3_NETCDF=$ncdf
	export WWATCH3_ENV=${ww3_dir}/wwatch3.env
	export LD_LIBRARY_PATH=/home/ivans/apps/netcdf-c-4.8.0/lib/

	case $ncdf in
	NC3)
	echo ; echo ' ... Using Netcdf 3'; echo 
	export NETCDF_LIBDIR=$HOME/apps/netcdf-3.6.3/lib/
	export NETCDF_INCDIR=$HOME/apps/netcdf-3.6.3/include/
	;;
	NC4)
	echo ; echo ' ... Using Netcdf 4'; echo
	export NETCDF_CONFIG=$HOME/apps/netcdf-c-4.8.0/bin/nc-config
	;;
	*)
	echo ; echo $"Usage: $0 {NC4|NC3}"; echo
	exit 1
	esac

##### Code compilation options

	flags01="PR3 UQ FLX2 LN1 ST2 STAB2 NL1 BT1 DB1"
	flags02="MLIM TR0 BS0 IC0 IS0 REF0 XX0 WNT1 WNX1"
	flags03="CRT1 CRX1 O0 O1 O2 O3 O4 O5 O6 O7 O11 012 013 O14"

	case_switch_ser="F90 $ncdf NOGRB NOPA LRB4 SHRD     $flags01 $flags02 $flags03"
	case_switch_mpi="F90 $ncdf NOGRB NOPA LRB4 MPI DIST $flags01 $flags02 $flags03"

	# Compiler headings
	cp ${ww3_dir}/bin/comp.${compstr} ${ww3_dir}/bin/comp
	cp ${ww3_dir}/bin/link.${compstr} ${ww3_dir}/bin/link

	# Compile appropriate code 
	if [ $icomp == 'yes' ]; then
	     #${path_b}/w3_clean all
	     ${path_b}/w3_new
	     echo; echo $case_switch_ser > ${path_b}/switch
	     ${path_b}/w3_make ww3_grid ww3_strt ww3_prnc 
	     if [ "$mpi" = "yes" ]; then
	  	   echo $case_switch_mpi > ${path_b}/switch
	  	   ${path_b}/w3_make ww3_multi
	     else
	  	   echo $case_switch_ser > ${path_b}/switch
	  	   ${path_b}/w3_make ww3_multi
	     fi
	fi

##### Make sub-dirs and move to ww3_out dir

	cd $path_r
	this_dir=`pwd`

	echo
	echo " ... inside directory: $this_dir"
	echo

#######################################################################################
#                                                                                     #
#                          1. GRID PRE-PROCESSOR: WW3_GRID                            #
#                                                                                     #
#######################################################################################

	echo ' '
	echo '                       +--------------------+'
	echo '                       |  Grid preprocessor |'
	echo '                       +--------------------+'
	echo ' '

        echo ; echo " ... run ww3_grid"; echo

	rm -f mod_def.*

	##### copy grid files to here
	for mod in $grds ; do 
		cp $path_g/${mod}.* .
	done


	for mod in $grds $wnd $ice $buo; do 
	    if [ "$mod" != 'no' ]; then

		##### copy input files to here
		cp $path_i/ww3_grid.inp.$mod ww3_grid.inp

		NX=`cat ww3_grid.inp | grep NCOLS | awk '{print $1}'`
		NY=`cat ww3_grid.inp | grep NCOLS | awk '{print $2}'`

		echo
		echo " ... Working on grid $mod, size $NX x $NY"
		echo

		$path_e/ww3_grid > logfile_grid.$mod.log 

		rm -f mapsta.ww3 mask.ww3
		mv mod_def.ww3 mod_def.$mod
		mv ww3_grid.inp ww3_grid.inp.$mod

	    fi
	done

	# After ww3_grid, we need to keep files mod_def.*
	# which will be needed to convert binary data to netcdf

	rm -f *.depth *.obstr *.mask *.meta

	echo ; echo " ... finished ww3_grid"; echo

#######################################################################################
#                                                                                     #
#                           2. INITIAL CONDITIONS: WW3_STRT                           #
#                                                                                     #
#######################################################################################

	echo ' '
	echo '                       +--------------------+'
	echo '                       | Initial conditions |'
	echo '                       +--------------------+'
	echo ' '

	echo ; echo " ... locate restart file or run ww3_strt to make a new one"; echo


	for grid in $grds; do

	    logfile="logfile_strt.$grid.log"	
	    restart="$path_d/ww3_out_rst_${t_ini}.${grid}"

	 if [ -e $restart ]; then

            echo " ... found restart file $restart"
	    echo " ... will use it as Initial Condition"

	    echo > $logfile
	    echo " ... found restart file $restart " >> $logfile
    	    echo " ... will use it as Initial Condition" >> $logfile	    
	    echo >> $logfile

	    ln -sf $restart restart.$grid

	 else

	    rm -f mod_def.ww3
	    ln -s mod_def.$grid mod_def.ww3
	    cp $path_i/ww3_strt.inp .

	    echo " ... didnt find restartfile $restart"; echo
	    echo " ... will run ww3_strt for initial conditions"; echo
	    echo " ... ... model output directed to $path_r/$logfile"
	    echo

	    echo > $logfile
            echo " ... didnt find restartfile $restart"  >> $logfile
            echo " ... will run ww3_strt for initial conditions" >> $logfile
	    echo > $logfile

	    $path_e/ww3_strt >> $logfile
	    mv restart.ww3 restart.$grid

	 fi
	done

	rm -f mod_def.ww3 ww3_strt.inp

	echo ; echo " ... finished ww3_strt"; echo

#######################################################################################
#                                                                                     #
#                             3. INPUT FIELDS: WW3_PRNC                               #
#                                                                                     #
#######################################################################################

	echo ' '
	echo '                       +--------------------+'
	echo '                       |    Input data      |'
	echo '                       +--------------------+'
	echo ' '

        echo ; echo " ... run ww3_prnc"; echo

	NRI='0'

	for mod in $wnd $ice $lvl $cur; do
	if [ "$mod" != 'no' ]; then
	  #NRI=`expr $NRI + 1`
	  forcefile="${force[NRI]}.nc"
	  inputfile="${mod}_${t_ini}.nc"
	  if [ -f ${path_d}/$inputfile ]; then
		echo " ... found the data file ${path_d}/$inputfile"
		echo " ... remove old link $forcefile and build a new one"
		rm -f $forcefile
		ln -s $path_d/$inputfile $forcefile
	  else
		echo " ... data file ${path_d}/$inputfile not found, exiting "
		echo " "
		exit
	  fi

	  if [ -e  ${force[NRI]}.$mod ]; then
		echo " ... file ${force[NRI]}.$mod exists, will be used"
	  else
		echo  
		echo " ... didnt find ${force[NRI]}.$mod"; echo
		echo " ... will run ww3_prnc to make a new file" ; echo
		echo " ... model output directed to $path_r/logfile_prnc.$mod.log"
                echo
	  	cp mod_def.$mod mod_def.ww3
	  	cp $path_i/ww3_prnc.inp.$mod ww3_prnc.inp
	  	$path_e/ww3_prnc > logfile_prnc.$mod.log 
	  	mv ${force[NRI]}.ww3 ${force[NRI]}.$mod
	  	rm -f mod_def.ww3 ww3_prnc.inp
	  	rm $forcefile
	  	NRI=`expr $NRI + 1`
	  fi
	fi
	done

	echo ; echo " ... finished ww3_prnc"; echo

#######################################################################################
#                                                                                     #
#                           4. MAIN PROGRAM: WW3_MULTI                                #
#                                                                                     #
#######################################################################################

        echo ' '
        echo '                       +--------------------+'
        echo '                       |    Main program    |'
        echo '                       +--------------------+'
        echo ' '

        echo " ... run multi-grid model "
        echo 
        echo " ... model output directed to $path_r/logfile_multi.log"
        echo

        cp $path_i/ww3_multi.inp .

        if [ "$mpi" = 'yes' ]; then
           mpirun -np $nprocs $path_e/ww3_multi >& logfile_multi.log &
           #srun --mpi=pmi2 -n $nprocs $path_e/ww3_multi >& logfile_multi.log &
           wait
        else
           $path_e/ww3_multi  >& logfile_multi.log &
           wait
        fi

        rm ww3_multi.inp

        echo ; echo " ... finished ww3_multi"; echo

#######################################################################################
#                                                                                     #
#                                 5. CLEANUP                                          #
#                                                                                     #
#######################################################################################

	echo " ... clean up !!!"

	echo 
	echo " ... rename files and delete unwanted files"
	echo   

	for mod in $grds; do
		mv out_grd.$mod     ww3_out_grd_${t_ini}.$mod
		mv restart001.$mod  ww3_out_rst_${t_rst}.$mod
	done

	if [ $buoy == 'points' ]; then 
	    mv out_pnt.points  ww3_out_pnt_${t_ini}.points
	fi

	cd $case_dir

	echo
	echo " +++ End of bash program run_ww3_multi-grid +++"
	echo

#############################################################################################################
#                                                                                                           #
#                                         END OF SCRIPT                                                     #
#                                                                                                           #
#############################################################################################################

