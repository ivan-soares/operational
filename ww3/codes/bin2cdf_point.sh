#!/bin/bash
#
#################################################################################
#                                                                               #
#           bin2cdf_point: convert binary data to POINT Netcdf data             #
#                                                                               #
#                                              IDS @ TOC, Ctba 2018.            #
#                                                                               #
#################################################################################

help_txt="date, nhours, icomp(yes/no), ncdf(NC3/NC4), output type(1=spectra)"

     if [ "$1" == "-h" ]; then
        echo " "
        echo "    Usage: `basename $0` [$help_txt]"
        echo " "
        exit 0
     fi

######################### script arguments ######################################

  echo " "
  echo " ===> starting bash function bin2cdf_point.sh"
  echo " "

  today=${@:1:1}
  nhours=${@:2:1}

  icomp=${@:3:1}

  ncdf_type=${@:4:1}
  output_type=${@:5:1}
  
  echo " "
  echo " ... initial date is ${today} "
  echo " ... will convert $nhours hours "
  echo " "

########################### Setup Netcdf  #######################################

  export WWATCH3_NETCDF=$ncdf_type

  case $ncdf_type in
   NC3)   
    echo ' '; echo ' ... using Netcdf 3'
    export NETCDF_LIBDIR=$HOME/apps/netcdf-3.6.3/lib/
    export NETCDF_INCDIR=$HOME/apps/netcdf-3.6.3/include/
    ;;
   NC4)
    echo ' '; echo ' ... using Netcdf 4'    
    export NETCDF_CONFIG=$HOME/apps/netcdf-c-4.8.0/bin/nc-config
    ;;
   * )
    echo $"usage: $0 {NC4|NC3}"
    exit 1
  esac

######################### Setup directories  ####################################

  case_dir=`pwd`
  code_dir="$HOME/ww3/code_v5.16"

  # code dir
  path_x="$code_dir/exe"             # path for executables
  path_b="$code_dir/bin"             # path for binaries

  # permanent dirs
  path_d="$case_dir/d-data"            # data files: winds, cur, lvl
  path_g="$case_dir/d-grids"           # grid files: depth, obstr, mask
  path_i="$case_dir/d-inputs"          # model input files

  # directories for this case
  path_o="$case_dir/mod_$today"        # directory to read  binary data
  path_t="$case_dir/tmp_$today"         # temporary directory
  path_r="$case_dir/d-outputs/${today}"  # model results

######################## Define model grid ######################################

                      ### NOT WANTED HERE ###

######################## Define model outputs ###################################

  day_one=$today
  t_zero='000000'
  dt='3600'

# FIELDS NOT NEEDED HERE

  

################## Setup wwatch env dir & compilation flags #####################

  export WWATCH3_ENV=${code_dir}/wwatch3.env

  flags01="TRKNC NOGRB NOPA LRB4 SHRD PR3 UQ FLX2 LN1 ST2 STAB2"
  flags02="NL1 BT1 DB1 MLIM TR0 BS0 IC0 IS0 REF0 XX0 WNT1 WNX1 CRT1 CRX1"
  flags03="O0 O1 O2 O3 O4 O5 O6 O7 O11 O14"

  case_switch="F90 $ncdf_type $flags01 $flags02 $flags03"

############### Change to tmp directory & compile code (or not)  ################

  #rm -rf   $path_t
  if [ ! -e $path_t ] ; then mkdir $path_t ; fi
  cd $path_t

  if [ $icomp = "yes" ]; then
       echo ' '; echo ' ... code will be compiled ...'
       echo $case_switch > ${path_b}/switch
       ${path_b}/w3_make ww3_ounp
  else
       echo ' ' 
       echo ' ... code is not being compiled ...' 
       echo ' ... using previous version ...'
  fi


############ convert data to point netcdf #######################################

  echo ' '
  echo " ... Spectral Netcdf point data ..."
  echo ' '

  if [ ! -e $path_o ]; then
     echo; echo " ... cant find dir $path_o,  exiting !!"; echo
  fi

  if [ ! -e $path_r ]; then
     echo; echo " ... cant find dir $path_r,  exiting !!"; echo
  fi

 
# program ww3_ounp needs three input files:
#
#       ww3_ounp.inp: input file with info to run ww3_ounf
#       mod_def.ww3: binary file created when compiling ww3_ounf
#       out_pnt.ww3: bindary file containing the data to be converted

  if [ -e mod_def.ww3  ] ; then rm -f mod_def.ww3;  fi
  if [ -e out_pnt.ww3  ] ; then rm -f out_pnt.ww3;  fi
  if [ -e ww3_ounp.inp ] ; then rm -f ww3_ounp.inp; fi

cat > ww3_ounp.inp << EOF
$ ----------------------------------------------------------------------------- $
$                    WAVEWATCH III Point output post-processing                 $
$ ----------------------------------------------------------------------------- $
$
  $day_one $t_zero $dt $nhours
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
   ww3_out_pnt_
   4
   ${ncdf_type:2:1}
   T 150
$ ----------------------------------------------------------------------------- $
$  output type ITYPE [0,1,2,3]
$
$  ITYPE = 0, inventory of file
$  ITYPE = 1, netCDF Spectra.
$  ITYPE = 2, netCDF Tables of (mean) parameter
$  ITYPE = 3, netCDF Source terms
$ ----------------------------------------------------------------------------- $
   $output_type
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
  2 -1. -1. 33 F
$ ----------------------------------------------------------------------------- $
$                          End of input file                                    $
$ ----------------------------------------------------------------------------- $
EOF

  ln -s $path_r/ww3_out_pnt.points out_pnt.ww3
  ln -s $path_o/mod_def.points mod_def.ww3

  logfile="$path_r/logfile_ounp_${today}.log"

  echo
  echo " ... run netcdf converter ounf "
  echo " ... screen output routed to $logfile"
  echo

  ${path_x}/ww3_ounp > $logfile
  mv ww3_out_pnt_*.nc $path_r/.
  mv ww3_ounp.inp $path_i/
  #  ww3_out_pnt_2018_spec.nc

# End, cleaning up -------------------------------------------------------

  echo ' ' ; echo "Cleaning-up `pwd`"
  #rm -f mod_def.ww3 out_pnt.ww3
  #rm ww3_ounp.inp

  echo ' '  
  echo ' '
  echo '                  ======>  END OF WAVEWATCH III  <====== '
  echo '                    ==================================   '
  echo ' '

#############################################################################
#                                                                           #
#                              End of Script                                #
#                                                                           #
#############################################################################

