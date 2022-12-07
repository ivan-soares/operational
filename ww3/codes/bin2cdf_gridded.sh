#!/bin/bash
#
#################################################################################
#                                                                               #
#         bin2cdf_gridded: convert binary data to GRIDDED Netcdf data           #
#                                                                               #
#                                               IDS @ TOC, Ctba 2018.           #
#                                                                               #
#################################################################################

     help_txt="date, nhrs, domain name, icomp (yes/no), ncdf (NC3/NC4), fields"

     if [ "$1" == "-h" ]; then
        echo " "
        echo "    Usage: `basename $0` [$help_txt]"
        echo " "
        exit 0
     fi

######################### script arguments ######################################

	echo
	echo " +++ Starting bash function bin2cdf_gridded.sh +++"
	echo

	fstID=${@:1:1}
	nhrs=${@:2:1}
	domain=${@:3:1}
	icomp=${@:4:1}
	ncdf=${@:5:1}

	inpdir=${@:6:1}
	outdir=${@:7:1}

	fields=${@:8}

	today=${fstID:0:8}
	year=${fstID:0:4}

	echo " "
	echo " ... initial date is ${today} "
	echo " ... will convert $nhrs hours "
	echo " "

########################### Setup Netcdf  #######################################

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

######################### Setup directories  ####################################

	case_dir=`pwd`
	code_dir="$HOME/ww3/code_v5.16"

	path_x="$code_dir/exe"             # path for executables
	path_b="$code_dir/bin"             # path for binaries

	path_d="$inpdir"                   # data files: winds, depth, obstr
	path_r="$outdir"                   # dir to read binary and write netcdf


######################## Define model grid ######################################

	NX=`cat $path_d/ww3_grid.inp.$domain | grep NCOLS | awk '{print $1}'`
	NY=`cat $path_d/ww3_grid.inp.$domain | grep NCOLS | awk '{print $2}'`

	#NX=`cat ${path_d}/${domain}.mask | wc -L | awk '{print $1/3}'`
	#NY=`cat ${path_d}/${domain}.mask | wc -l | awk '{print $1/1}'`

	echo " "; echo " ... working on grid $domain, size $NX x $NY" 

######################## Define model outputs ###################################

	day_one=$today
	t_zero='000000'
	dt='3600'

	# FIELDS='DPT'
	# FIELDS=`cat run_npo.sh | grep FIELDS= | sed -e "s/FIELDS=//g" -e "s/'//g" `

	echo ' '
	echo ' ... output fields are: ' $fields

################## Setup wwatch env dir & compilation flags #####################

	export WWATCH3_ENV=${code_dir}/wwatch3.env

	flags01="TRKNC NOGRB NOPA LRB4 SHRD PR3 UQ FLX2 LN1 ST2 STAB2"
	flags02="NL1 BT1 DB1 MLIM TR0 BS0 IC0 IS0 REF0 XX0 WNT1 WNX1 CRT1 CRX1"
	flags03="O0 O1 O2 O3 O4 O5 O6 O7 O11 O14"

	case_switch="F90 $ncdf $flags01 $flags02 $flags03"

############### Change to output directory & compile code (or not)  ################


	cd $path_r

	echo; echo " ... here I am at $PWD to convert binary to nectdf"; echo

	if [ $icomp = "yes" ]; then
	   echo ; echo ' ... code will be compiled ...' ; echo
	   echo $case_switch > ${path_b}/switch
	   ${path_b}/w3_make ww3_ounf
	else
	   echo 
	   echo ' ... code is not being compiled ...' 
	   echo ' ... using previous version ...'
	fi

############ convert data to gridded netcdf #####################################

	echo ' '
	echo " ... Gridded Netcdf data for $domain "
	echo " ... screen ouput routed to $path_r/logfile_ounf_${domain}.log"
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

	ln -s $path_d/ww3_out_grd_${today}.${domain} out_grd.ww3
	ln -s $path_d/mod_def.$domain mod_def.ww3

	$path_x/ww3_ounf > $path_r/logfile_ounf_${domain}.log
	mv ww3_${domain}_${year}.nc ww3_his_${domain}_${today}.nc

	mv ww3_ounf.inp $inpdir
	rm out_grd.ww3 mod_def.ww3

#################### End, cleaning up ###########################################

	#echo ' ' ; echo "Cleaning-up `pwd`"
	cd $case_dir

        echo
        echo " +++ End of bash function bin2cdf_gridded.sh +++"
        echo


#################################################################################
#                                                                               #
#                              End of Script                                    #
#                                                                               #
#################################################################################

