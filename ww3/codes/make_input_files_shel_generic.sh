#!/bin/bash
#############################################################################################################
#                                                                                                           #
#                Bash script to make input files to Wave Watch III, v5.16                                   #
#                                                                                                           #
#                                                                                 IDS @ AT, Fpolis 2021     #
#                                                                                                           #
#############################################################################################################

        set -o errexit  # exit in case of fail
        set -o pipefail # if one command in the pipe fails the entire pipeline will fail
        set -o nounset  # report an error & exist if encounters a variable that doesnt exist.
        #set -o xtrace    # output the executed command line before its execution result.

	help_txt="date_ini, date_end, date_rst, buoy (yes/no), buoy dir, inpdir, FIELDS"

	if [ "$1" == "-h" ]; then
		echo " "
		echo "    Usage: `basename $0` [$help_txt]"
		echo " "
		exit 0
	fi

#############################################################################################################
#                                                                                                           #
#                               0. EXPT GENERAL CONFIGS                                                     #
#                                                                                                           #
#############################################################################################################

	date_ini=${@:1:1}
	date_end=${@:2:1}
	date_rst=${@:3:1}

	buoy=${@:4:1}
	inpdir=${@:5:1}
	
#############################################################################################################

	##### load file containing specifications about forcing and grids
	source $inpdir/case_config.sh


	echo
	echo " +++ Starting bash program to make input files to run ww3_shel +++ "
	echo

	echo
	echo " ... date ini = $date_ini"
	echo " ... date end = $date_end"
	echo " ... create point output = $buoy"
	echo " ... ww3 output FIELDS = $fields"
	echo


	##### set number of grids
	NR=`echo $grds | wc -w | awk '{print $1}'`

	### set number of forcings
	NRI='0'
	for mod in $wnd $ice $lvl $cur; do
	  if [ "$mod" != 'no' ]; then
		NRI=`expr $NRI + 1`
	  fi
	done

	##### Set initial conditions

	# itype = 1 set Gaussian in frequency and space, cos type in direction.
	# itype = 2 set JONSWAP spectrum with Hasselmann direct. distribution.
	# itype = 5 start from sea at rest

	itype=5

	#  will need 
	#  fp and spread (Hz), mean direction (degr., oceanographic
	#  convention) and cosine power, Xm and spread (degr. or m) Ym and
	#  spread (degr. or m), Hmax (m) (Example for lon-lat grid in degr.).
	#
	#  0.1000 0.01 270. 2 1. 0.5 1. 0.5 2.5        for itype 1
	#  0.0081 0.10 270. 1.0 0. 0.  1. 100. 1. 100. for itype 2
	#  no other information for itype 5

	IC='$'
	#IC=' .1000 0.01 270. 2 1. 0.5 1. 0.5 2.5'
	#IC=' 0.0081 0.10 270. 1.0 0. 0.  1. 100. 1. 100.'

	##### Set point output

	if   [ $buoy == 'no' ] ; then
	 dtb='0000' ; UPTS=F
	elif [ $buoy == 'points' ] ; then
	 dtb='3600' ; UPTS=T 
         #echo; echo " ... create BUOY file"; echo
         # make sure that lon and lat are in the correct format
         #flon1b=`echo $flon1 | awk '{printf "%8.3f", $1+360.}'`
         #flon1b=`echo $flon1 | awk '{printf "%8.3f", $1}'`
         #flat1b=`echo $flat1 | awk '{printf "%7.3f", $1}'`
         #echo " $flon1b $flat1b 'SYST COORD' 5.0 DAT TOC  1"    >& buoy.loc
         #echo " 0000.000 00.0000 'STOPSTRING' 999. XXX XXX 99"  >> buoy.loc
        fi


	##### Partitioning

	# dtp='3600' ; PT=' '
	dtp='   0' ; PT='$'

	##### Set run times: undefined t_rst will give no restart file

	t_ini="${date_ini:0:8} ${date_ini:9:6}"
	t_end="${date_end:0:8} ${date_end:9:6}"
	t_rst="${date_rst:0:8} ${date_rst:9:6}"

	#t_ini="${date_ini:0:8} 060000"
        #t_end="${date_end:0:8} 000000"
        #t_rst="${date_rst:0:8} 000000"

	dt='3600'
	tn='25'

	if [ -z "$t_rst" ]; then
	      dte='   0'
	      t_rst=$t_end
	else
	      dte='   1'
	fi

	count=0

#############################################################################################################
#                                                                                                           #
#                               1.a WW3_GRID INPUT FILEs for BATH GRIDS                                     #
#                                                                                                           #
#############################################################################################################

for mod in $grds; do

echo; echo " +++ Make ww3_grid.inp.$mod +++"; echo

cat > ww3_grid.inp.$mod << EOF
$ -------------------------------------------------------------------- $
$                WAVEWATCH III grid pre-processor input file           $
$ -------------------------------------------------------------------- $
      '${gtitle[count]}'
      $spec_defs
      F T T T F T
      ${gsteps[count]}
$
  &MISC CICE0 = 0.25, CICEN = 0.75, FLAGTR = 4, FLC = .FALSE. /
  &OUTS E3D = 1, TH1MF = 1, TH2MF = 1 /
END OF NAMELISTS
$
     'RECT' T 'NONE'
      ${gsizes[count]}  # NCOLS NROWS
       1.   1. ${grefin[count]}
      ${gzeroc[count]} 1.0
$
     -0.1 2.50 20  0.001 1 1 '(....)' 'NAME' '${gnames[count]}.depth'
               21  0.010 1 1 '(....)' 'NAME' '${gnames[count]}.obstr'
               22        1 1 '(....)' 'NAME' '${gnames[count]}.mask'
$
      0.   0.   0.   0.   0
$
$ -------------------------------------------------------------------- $
$                        End of input file                             $
$ -------------------------------------------------------------------- $
EOF

let count=$count+1

mv ww3_grid.inp.$mod $inpdir

done

#############################################################################################################
#                                                                                                           #
#                               1.b WW3_GRID INPUT FILEs for WIND, ICE & BUOY                               #
#                                                                                                           #
#############################################################################################################

for mod in $wnd $ice $buoy; do if [ "$mod" != 'no' ]; then

echo; echo " +++ Make ww3_grid.inp.$mod +++"; echo

cat > ww3_grid.inp.$mod << EOF
$ -------------------------------------------------------------------- $
$                WAVEWATCH III grid pre-processor input file           $
$ -------------------------------------------------------------------- $
      '${gtitle[count]}'
      $spec_defs
      F T T T F T
      ${gsteps[count]}
$
END OF NAMELISTS
$
     'RECT' T 'NONE'
      ${gsizes[count]}  # NCOLS NROWS
       1.   1. ${grefin[count]}
      ${gzeroc[count]} 1.0
$
     -0.1 2.50 10 -1000. 2 1 '(....)' 'UNIT' 'dummy'
      ${gtptns[count]}*1
                      10 3 1 '(....)' 'PART' 'dummy'
      0   0   F
      0   0   F
      0   0
$
      0.   0.   0.   0.   0
$
$ -------------------------------------------------------------------- $
$                        End of input file                             $
$ -------------------------------------------------------------------- $
EOF

let count=$count+1

mv ww3_grid.inp.$mod $inpdir

fi
done



#############################################################################################################
#                                                                                                           #
#                                 2. WW3_STRT INPUT FILE                                                    #
#                                                                                                           #
#############################################################################################################

echo; echo " +++ Make ww3_strt.inp +++"; echo

cat > ww3_strt.inp << EOF
$ -------------------------------------------------------------------- $
$ WAVEWATCH III Initial conditions input file
$
$ -------------------------------------------------------------------- $
$
$ type of initial field ITYPE .
$
$ ITYPE = 1 ---------------------------------------------------------- $
$ Gaussian in frequency and space, cos type in direction.
$  fp and spread (Hz), mean direction (degr., oceanographic
$  convention) and cosine power, Xm and spread (degr. or m) Ym and
$  spread (degr. or m), Hmax (m) (Example for lon-lat grid in degr.).
$
$ 0.10 0.01 270. 2 1. 0.5 1. 0.5 2.5
$ 0.10 0.01 270. 2 0. 1000. 1. 1000. 2.5
$ 0.10 0.01 270. 2 0. 1000. 1. 1000. 0.01
$ 0.10 0.01 270. 2 0. 1000. 1. 1000. 0.
$
$ ITYPE = 2 ---------------------------------------------------------- $
$ JONSWAP spectrum with Hasselmann et al. (1980) direct. distribution.
$  alfa, peak freq. (Hz), mean direction (degr., oceanographical
$  convention), gamma, sigA, sigB, Xm and spread (degr. or m) Ym and
$  spread (degr. or m) (Example for lon-lat grid in degr.).
$  alfa, sigA, sigB give default values if less than or equal to 0.
$
$  0.0081 0.1 270. 1.0 0. 0. 1. 100. 1. 100.
$
$ ITYPE = 3 ---------------------------------------------------------- $
$ Fetch-limited JONSWAP
$  No additional data, the local spectrum is calculated using the
$  local wind speed and direction, using the spatial grid size as
$  fetch, and assuring that the spectrum is within the discrete
$
$ ITYPE = 4 ---------------------------------------------------------- $
$ User-defined spectrum
$
$ ITYPE = 5 ---------------------------------------------------------- $
$ Starting from calm conditions.
$  No additional data.
$
$itype
$IC
$ -------------------------------------------------------------------- $
$    End of file                                                       $
$ -------------------------------------------------------------------- $
EOF

mv ww3_strt.inp $inpdir

#############################################################################################################
#                                                                                                           #
#                                  3. WW3_PRNC INPUT DATA                                                   #
#                                                                                                           #
#############################################################################################################

echo; echo " +++ Make ww3_prnc.inp.$wnd+++"; echo

cat > ww3_prnc.inp.$wnd << EOF
$ -------------------------------------------------------------------- $
$ WAVEWATCH III Field preprocessor input file                          $
$ -------------------------------------------------------------------- $
$ Mayor types of field and time flag
$   Field types  :  ICE   Ice concentrations.
$                   LEV   Water levels.
$                   WND   Winds.
$                   WNS   Winds (including air-sea temp. dif.)
$                   CUR   Currents.
$                   DAT   Data for assimilation.
$
$   Format types :  AI    Transfer field 'as is'. (ITYPE 1)
$                   LL    Field defined on regular longitude-latitude
$                         or Cartesian grid. (ITYPE 2)
$   Format types :  AT    Transfer field 'as is', performs tidal
$                         analysis on the time series (ITYPE 6)
$                         When using AT, another line should be added
$                         with the choice ot tidal constituents:
$                         ALL or FAST or VFAST or a list: e.g. 'M2 S2'
$
$        - Format type not used for field type 'DAT'.
$
$   Time flag    : If true, time is included in file.
$   Header flag  : If true, header is added to file.
$                  (necessary for reading, FALSE is used only for
$                   incremental generation of a data file.)
$
  'WND' 'LL' T T
$
$ Name of dimensions ------------------------------------------------- $
$
$ longitude latitude time
  lon lat time
$
$ Variables to use --------------------------------------------------- $
$
$ U V
  Uwind Vwind
$
$ Additional time input ---------------------------------------------- $
$ If time flag is .FALSE., give time of field in yyyymmdd hhmmss format.
$
$   19680606 053000
$
$ Define data files -------------------------------------------------- $
$ The input line identifies the filename using for the forcing field.
$
  'wind.nc'
$
$ -------------------------------------------------------------------- $
$ End of input file                                                    $
$ -------------------------------------------------------------------- $
EOF

mv ww3_prnc.inp.$wnd $inpdir

#############################################################################################################
#                                                                                                           #
#                                  4. WW3_BOUNC INPUT DATA                                                  #
#                                                                                                           #
#############################################################################################################

echo; echo " +++ Make ww3_bounc.inp +++"; echo

cat > ww3_bounc.inp << EOF
$ -------------------------------------------------------------------- $
$    WAVEWATCH III bounc input file                                    $
$ -------------------------------------------------------------------- $
$
$ Boundary option: READ or WRITE
$
WRITE
$
$ Interpolation method: 1: nearest
$                       2: linear interpolation
2
$ Verbose (0, 1, 2)
1
$
$ List of spectra files. These NetCDF files use the WAVEWATCH III
$ format as described in the ww3_ounp.inp file. The files are
$ defined relative to the directory in which the program is run.
$
EOF

nspecs=$nspecs-1
for (( n=0; n<=$nspecs; n++ )); do echo $inpdir/${specfiles[$n]} >> ww3_bounc.inp; done

cat >> ww3_bounc.inp << EOF
'STOPSTRING'
$
$ -------------------------------------------------------------------- $
$    End of file                                                       $
$ -------------------------------------------------------------------- $
EOF

mv ww3_bounc.inp $inpdir

#############################################################################################################
#                                                                                                           #
#                                  5. WW3_SHEL INPUT FILE                                                   #
#                                                                                                           #
#############################################################################################################

echo; echo " +++ Make ww3_shel.inp +++"; echo

cat > ww3_shel.inp << EOF
$ ---------------------------------------------------------
$          WAVEWATCH III multi-grid input file
$ ---------------------------------------------------------
$
$ the second T/F option for sea level, currents and winds 
$ decides if the field is homogeneous or not.
$
   F F     Water levels
   F F     Currents
EOF

if [ $wnd == 'no' ]; then
     echo "   F F     Winds" >> ww3_shel.inp
else
     echo "   T F     Winds" >> ww3_shel.inp
fi

cat >> ww3_shel.inp << EOF
   F       Ice concentrations
   F       Assimilation data : Mean parameters
   F       Assimilation data : 1-D spectra
   F       Assimilation data : 2-D spectra.
$ 
   $t_ini  
   $t_end
$
   1
$
   $t_ini  $dt  $t_end
$
   N
   $fields
$
   $t_ini  $dtb  $t_end
EOF

  if [ $buoy == 'points' ]; then
    cat $inpdir/buoy.loc >> ww3_shel.inp
  fi

cat >> ww3_shel.inp << EOF
$
$ Four additional output types:
$
$  track output
$  restart files
$  boundary output
$  separated wave field data
$
   $t_ini      0  $t_end
   $t_rst   $dte  $t_rst
   $t_ini      0  $t_end
   $t_ini   $dtp  $t_end
$
$PT    0 999 1 0 999 1 T
$
$ 'the_end'  0
$
  'STP'
$
$ ---------------------------------------------------------
$                   End of input file
$ ---------------------------------------------------------
EOF


mv ww3_shel.inp $inpdir/.

echo
echo " +++ End of bash program to make input files to run ww3_shel +++ "
echo

#############################################################################################################
#                                                                                                           #
#                                           THE END                                                         #
#                                                                                                           #
#############################################################################################################



