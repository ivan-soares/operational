#!/bin/bash
#
#########################################################################################
#                                                                                       #
#         bin2cdf: convert gridded or point binary data to Netcdf                       #
#                                                                                       #
#                                                IDS @ AT, Fpolis 2022.                 #
#                                                                                       #
#########################################################################################

	set -o errexit  # exit in case of fail
	set -o pipefail # if one command in the pipe fails the entire pipeline fails
	set -o nounset  # exits if encountering a variable that doesnt exist.
	#set -o xtrace  # output the executed command line before its execution.


	help_txt="date, nhrs, domain, icomp (yes/no), NC3/NC4, inpdir, outdir, fields"

	if [ "$1" == "-h" ]; then
		echo " "
		echo "    Usage: `basename $0` [$help_txt]"
		echo " "
		exit 0
	fi

######################### script arguments ##############################################

	echo
	echo " +++ Starting bash function bin2cdf_gridded.sh +++"
	echo

	fstID=${@:1:1}
	nhrs=${@:2:1}
	domain=${@:3:1}

	inpdir=${@:4:1}
	outdir=${@:5:1}

	source $inpdir/case_config.sh

	today=${fstID:0:8}
	year=${fstID:0:4}

	echo " "
	echo " ... initial date is ${today} "
	echo " ... will convert $nhrs hours "
	echo " "

########################### Setup Netcdf  ###############################################

	export WWATCH3_NETCDF=$ncdf
	export LD_LIBRARY_PATH=$HOME/apps/netcdf-c-4.8.0/lib/

	ncdf_type=${ncdf:2:1}

	case $ncdf in
	     NC3)
	       echo ; echo " ... using Netcdf $ncdf_type"; echo
	       export NETCDF_LIBDIR=$HOME/apps/netcdf-3.6.3/lib/
	       export NETCDF_INCDIR=$HOME/apps/netcdf-3.6.3/include/
	       ;;
	     NC4)
	       echo ; echo " ... using Netcdf $ncdf_type"; echo    
	       export NETCDF_CONFIG=$HOME/apps/netcdf-c-4.8.0/bin/nc-config 
	       ;;
	     * )
	       echo $"usage: $0 {NC4|NC3}"
	       exit 1
	esac      

######################### Setup directories  ############################################

	case_dir=`pwd`
	code_dir="$HOME/ww3/code_v5.16"

	path_x="$code_dir/exe"             # path for executables
	path_b="$code_dir/bin"             # path for binaries

	path_d="$inpdir"                   # data files: winds, depth, obstr
	path_r="$outdir"                   # dir to read binary and write netcdf


######################## Define model grid ##############################################

	NX=`cat $path_d/ww3_grid.inp.$domain | grep NCOLS | awk '{print $1}'`
	NY=`cat $path_d/ww3_grid.inp.$domain | grep NCOLS | awk '{print $2}'`

	#NX=`cat ${path_d}/${domain}.mask | wc -L | awk '{print $1/3}'`
	#NY=`cat ${path_d}/${domain}.mask | wc -l | awk '{print $1/1}'`

	echo " "; echo " ... working on grid $domain, size $NX x $NY" 

######################## Define model outputs ###########################################

	day_one=$today
	t_zero='000000'
	dt='3600'

	# FIELDS='DPT'
	# FIELDS=`cat run_npo.sh | grep FIELDS= | sed -e "s/FIELDS=//g" -e "s/'//g" `

	echo ' '
	echo ' ... output fields are: ' $fields

################## Setup wwatch env dir & compilation flags #############################

	export WWATCH3_ENV=${code_dir}/wwatch3.env

	flags01="TRKNC NOGRB NOPA LRB4 SHRD PR3 UQ FLX2 LN1 ST2 STAB2"
	flags02="NL1 BT1 DB1 MLIM TR0 BS0 IC0 IS0 REF0 XX0 WNT1 WNX1 CRT1 CRX1"
	flags03="O0 O1 O2 O3 O4 O5 O6 O7 O11 O14"

	case_switch="F90 $ncdf $flags01 $flags02 $flags03"

############### Change to output directory & compile code (or not)  #####################


	cd $path_r

	echo; echo " ... here I am at $PWD to convert binary to nectdf"; echo

	if [ $icomp = "yes" ]; then
	   echo ; echo ' ... code will be compiled ...' ; echo
	   echo $case_switch > ${path_b}/switch
	   ${path_b}/w3_make ww3_ounf
	   ${path_b}/w3_make ww3_ounp
	else
	   echo 
	   echo ' ... code is not being compiled ...' 
	   echo ' ... using previous version ...'
	fi

#########################################################################################
############                                                      #######################
############          choose between gridded and point data       #######################
############                                                      #######################
#########################################################################################

	if [ $domain == "points" ]; then

	########### CONVERT POINT

        echo ' '
	echo " ... convert point(buoy) data for $domain "
        echo ' '

        #  program ww3_ounp needs three input files:
        #
        #       ww3_ounp.inp: input file with info to run ww3_ounf
        #       mod_def.ww3: binary file created when compiling ww3_ounf
        #       out_grd.ww3: bindary file containing the data to be converted

        if [ -e mod_def.ww3  ] ; then rm -f mod_def.ww3;  fi
        if [ -e out_pnt.ww3  ] ; then rm -f out_pnt.ww3;  fi
        if [ -e ww3_ounp.inp ] ; then rm -f ww3_ounp.inp; fi

cat > ww3_ounp.inp << EOF
$ ----------------------------------------------------------------------------- $
$                    WAVEWATCH III Point output post-processing                 $
$ ----------------------------------------------------------------------------- $
$
  $day_one $t_zero $dt $nhrs
$
$ ----------------------------------------------------------------------------- $
$ Points requested: Define points for which output is to be generated.
$ If no one defined, all points are selected
$ One index number per line, negative number identifies end of list.
$ ----------------------------------------------------------------------------- $
$
$  3
$ mandatory end of list
  -1
$
$ ----------------------------------------------------------------------------- $
$  file prefix
$  number of characters in today [4(yearly),6(monthly),8(daily),10(hourly)]
$  netCDF version [3,4]
$  points in same file [T] or not [F] and max number of points to be processed
$         in one pass
$ ----------------------------------------------------------------------------- $
   ww3_${domain}_
   4
   $ncdf_type
   T 150
$ ----------------------------------------------------------------------------- $
$  output type ITYPE [0,1,2,3]
$
$  ITYPE = 0, inventory of file
$  ITYPE = 1, netCDF Spectra.
$  ITYPE = 2, netCDF Tables of (mean) parameter
$  ITYPE = 3, netCDF Source terms
$ ----------------------------------------------------------------------------- $
   $point_output_type
$ ----------------------------------------------------------------------------- $
$ flag for global attributes WW3 [0] or variable version [1-2-3-4]
$ flag for dimensions order time,station [T] or station,time [F]
$ ----------------------------------------------------------------------------- $
   0
   T
$ ----------------------------------------------------------------------------- $
$ OTYPE for ITYPE = 1 (netCDF Spectra)
$
$   1 : Print plots.
$   2 : Table of 1-D spectra
$   3 : Transfer file.
$   4 : Spectral partitioning.
$
$ Scaling factors for 1-D and 2-D spectra : negative factor disables
$ Output factors, factor = 0. gives normalized spectrum.
$
$ ----------------------------------------------------------------------------- $
   3 -1. -1. 33 F
$  3 -1. 0
$ ----------------------------------------------------------------------------- $
$                          End of input file                                    $
$ ----------------------------------------------------------------------------- $
EOF

	cp $path_d/ww3_out_pnt_${today}.points out_pnt.ww3
	cp $path_d/mod_def.points mod_def.ww3

	logfile="$path_r/logfile_ounp_${domain}.log"

	echo
	echo " ... run netcdf converter ounp "
	echo " ... screen output routed to $logfile"
	echo

	${path_x}/ww3_ounp > $logfile

	echo " ... after running ww3_ounp"
	echo " ... rewrite file ww3_${domain}_${year}_spec.nc to"
	echo " ... ww3_his_point_${today}.nc"
	echo

	ncks -v time,longitude,latitude,station_name,efth \
	       	ww3_${domain}_${year}_spec.nc ww3_his_point_${today}.nc
	
	echo " ... finished rewriting"
	echo

	rm ww3_${domain}_${year}_spec.nc
	rm out_pnt.ww3 mod_def.ww3
	#mv ww3_ounp.inp $inpdir/


	else


	############ CONVERT GRIDDED

	echo ' '
	echo " ... convert gridded data for $domain "
	echo ' '

	#  program ww3_ounf needs three input files:
	#
	#       ww3_ounf.inp: input file with info to run ww3_ounf
	#       mod_def.ww3: binary file created when compiling ww3_ounf
	#       out_grd.ww3: bindary file containing the data to be converted

	if [ -e mod_def.ww3  ] ; then rm -f mod_def.ww3;  fi
	if [ -e out_grd.ww3  ] ; then rm -f out_grd.ww3;  fi
	if [ -e ww3_ounf.inp ] ; then rm -f ww3_ounf.inp; fi

cat > ww3_ounf.inp << EOF
$ ----------------------------------------------------------------------------- $
$         WAVEWATCH III Grid output post-processing                             $
$ ----------------------------------------------------------------------------- $
$
  $day_one $t_zero $dt $nhrs
$
$  Output flags
$
  N
  $fields
$
$  netCDF version [3,4] and variable type 4 [2,3,4]
$  swell partitions [0 1 2 3 4 5]
$  variables in same file [T] or not [F]
$
  $ncdf_type 4
  0 1 2
  T
$
$ ----------------------------------------------------------------------------- $
$  File prefix
$  number of characters in date [4(yearly),6(monthly),8(daily),10(hourly)]
$  IX and IY ranges [regular:IX NX IY NY DX DY, unstructured:IP NP DP DP]
$
  ww3_${domain}_
  4
  1 $NX 1 $NY
$
$ ----------------------------------------------------------------------------- $
$  End of input file                                                            $
$ ----------------------------------------------------------------------------- $
EOF

	cp $path_d/ww3_out_grd_${today}.${domain} out_grd.ww3
	cp $path_d/mod_def.$domain mod_def.ww3

	logfile="$path_r/logfile_ounf_${domain}.log"

	echo
        echo " ... run netcdf converter ounf "
        echo " ... screen output routed to $logfile"
        echo

	$path_x/ww3_ounf > $logfile
	mv ww3_${domain}_${year}.nc ww3_his_${domain}_${today}.nc
	#mv ww3_ounf.inp $inpdir
	rm out_grd.ww3 mod_def.ww3

	fi

#################### End, cleaning up ###################################################

	#echo ' ' ; echo "Cleaning-up `pwd`"
	cd $case_dir

        echo
        echo " +++ End of bash function bin2cdf_gridded.sh +++"
        echo


#########################################################################################
#                                                                                       #
#                              End of Script                                            #
#                                                                                       #
#########################################################################################

