#!/bin/bash
#############################################################################################################
#                                                                                                           #
#                Bash script to make input files to Wave Watch III, v5.16                                   #
#                                                                                                           #
#                                                                                 IDS @ AT, Fpolis 2021     #
#                                                                                                           #
#############################################################################################################

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

	echo
	echo " +++ Starting bash script to make input files for WW3 +++"
	echo

	date_ini=${@:1:1}
	date_end=${@:2:1}
	date_rst=${@:3:1}

	buoy=${@:4:1}
	buodir=${@:5:1}
	inpdir=${@:6:1}

	fields=${@:7}

	echo
	echo " ... date ini = $date_ini"
	echo " ... date end = $date_end"
	echo " ... date rst = $date_rst"
	echo
	echo " ... output points = $buoy"
	echo " ... output FIELDS = $fields"
	echo
	echo



	##### load file containing specifications about forcing and grids
	source case_config.sh

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

	itype=5                  # Start from sea at rest

	##### Set point output

	if   [ $buoy == 'no' ] ; then
	 dtb='0000' ; UPTS=F
	elif [ $buoy == 'points' ] ; then
	 dtb='3600' ; UPTS=T 
         echo; echo " ... create BUOY file"; echo
         # make sure that lon and lat are in the correct format
         #flon1b=`echo $flon1 | awk '{printf "%8.3f", $1+360.}'`
         flon1b=`echo $flon1 | awk '{printf "%8.3f", $1}'`
         flat1b=`echo $flat1 | awk '{printf "%7.3f", $1}'`
         echo " $flon1b $flat1b 'SYST COORD' 5.0 DAT TOC  1"    >& buoy.loc
         echo " 0000.000 00.0000 'STOPSTRING' 999. XXX XXX 99"  >> buoy.loc
        fi


	##### Partitioning

	# dtp='3600' ; PT=' '
	dtp='   0' ; PT='$'

	##### Set run times: undefined t_rst will give no restart file

	t_beg="${date_ini:0:8} ${date_ini:9:6}"
	t_end="${date_end:0:8} ${date_end:9:6}"
	t_rst="${date_rst:0:8} ${date_rst:9:6}"

	dt='3600'
	tn='25'

	if [ -z "$t_rst" ]; then
	      dte='   0'
	      t_rst=$t_end
	else
	      dte='   1'
	fi

	fstID=`echo $t_beg | sed 's/ /\./g'`
	rstID=`echo $t_rst | sed 's/ /\./g'`

	count=0

#############################################################################################################
#                                                                                                           #
#                               1.a WW3_GRID INPUT FILEs for BATH GRIDS                                     #
#                                                                                                           #
#############################################################################################################

for mod in $grds; do

cat > ww3_grid.inp.$mod << EOF
$ -------------------------------------------------------------------- $
$                WAVEWATCH III grid pre-processor input file           $
$ -------------------------------------------------------------------- $
      '${gtitle[count]}'
      1.1 0.04 42 24 0.
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

cat > ww3_grid.inp.$mod << EOF
$ -------------------------------------------------------------------- $
$                WAVEWATCH III grid pre-processor input file           $
$ -------------------------------------------------------------------- $
      '${gtitle[count]}'
      1.1 0.04 42 24 0.
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

cat > ww3_strt.inp << EOF
$ -------------------------------------------------------------------- $
$    WAVEWATCH III prnc input file                                     $
$ -------------------------------------------------------------------- $
   $itype
   0.07 0.01  245. 5  180.  20.  50.  10.  $Hini
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

cat > ww3_prnc.inp.$wnd << EOF
$ -------------------------------------------------------------------- $
$    WAVEWATCH III prnc input file                                     $
$ -------------------------------------------------------------------- $
  'WND' 'LL' T T
   lon lat
$   U   V
$  U_GRD_L103   V_GRD_L103
   Uwind  Vwind
  'wind.nc'
$ -------------------------------------------------------------------- $
$    End of file                                                       $
$ -------------------------------------------------------------------- $
EOF

mv ww3_prnc.inp.$wnd $inpdir

############################################################################################################
#                                                                                                           #
#                                  4. WW3_MULTI INPUT FILE                                                  #
#                                                                                                           #
#############################################################################################################

cat > ww3_multi.inp << EOF
$ ---------------------------------------------------------
$          WAVEWATCH III multi-grid input file
$ ---------------------------------------------------------
  $NR $NRI $UPTS 1 F F
$
EOF

  if [ "$wnd" != 'no' ] ; then
     echo " '$wnd'  F F T F F F F"   >> ww3_multi.inp ; fi
  if [ "$ice" != 'no' ] ; then
     echo " '$ice'  F F F T F F F"    >> ww3_multi.inp ; fi
  if [ "$buoy" != 'no' ] ; then
     echo " '$buoy'"                 >> ww3_multi.inp ; fi

  flags="'no' 'no' '$wnd' '$ice' 'no' 'no' 'no'"

  n=0
  for mod in $grds; do
   let n=n+1
   echo " '$mod' $flags  $n 1  0.00 1.00  F" >> ww3_multi.inp
  done

cat >> ww3_multi.inp << EOF
$
   $t_beg  $t_end
$
   T  F
$
   $t_beg  $dt  $t_end
   N
   $fields
   $t_beg  $dtb  $t_end
EOF

  if [ $buoy == 'points' ]; then
    cat $buodir/buoy.loc >> ww3_multi.inp
  fi

cat >> ww3_multi.inp << EOF
$
$ Four additional output types:
$
$  track output
$  restart files
$  boundary output
$  separated wave field data
$
   $t_beg      0  $t_end
   $t_rst   $dte  $t_rst
   $t_beg      0  $t_end
   $t_beg   $dtp  $t_end
$
$PT    0 999 1 0 999 1 T
$
  'the_end'  0
$
  'STP'
$
$ ---------------------------------------------------------
$                   End of input file
$ ---------------------------------------------------------
EOF


	echo " ... moving ww3_mult.inp to $inpdir"

	mv ww3_multi.inp $inpdir

        echo
        echo " +++ End of bash script to make input files for WW3 +++"
        echo


#############################################################################################################
#                                                                                                           #
#                                           THE END                                                         #
#                                                                                                           #
#############################################################################################################



