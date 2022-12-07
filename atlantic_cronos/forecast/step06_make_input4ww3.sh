#!/usr/bin/env bash

       #====================================================================================
       echo >> $log ; cd $tmpdir; dr=`pwd`
       echo ; echo " ==> HERE I am @ $dr for step 06: make input files for WW3 <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ... make inputs for WW3 at $now" >> $log
       #====================================================================================

       #The next line is "importing" the array variables defined globally on forecast_setup"
       eval "$ARRAYS"

       date_ini=$today
       date_end=`date -d "$today +${ndays} days" +%Y%m%d`

       echo 
       echo " ... date ini is $date_ini"
       echo " ... date end is $date_end"
       echo
       echo " ... # of hrs  is $nhrs"
       echo " ... # of days is $ndays"
       echo
       echo " ... domain names are $domain_ww3"
       echo " ... will use $wnd winds "
       echo
       echo " ... output FIELDS are $fields"
       echo " ... point output (yes/no) :  $buoy"
       echo

       ##### Set number of forcings

       NRI='0'
       NR=`echo $domain_ww3 | wc -w | awk '{print $1}'`
       for mod in $wnd $ice $lvl $cur; do
         if [ "$mod" != 'no' ]; then
              NRI=`expr $NRI + 1`
         fi
       done

       ##### Set initial conditions

       itype=5  # Start from sea at rest

       ##### Set point output

       if   [ $buoy == 'no' ] ; then
        dtb='0000' ; UPTS=F ; buo='no'
       elif [ $buoy == 'yes' ] ; then
        dtb='3600' ; UPTS=T ; buo='points'
       fi

       if [ $buoy == 'yes' ]; then
        echo; echo " ... create BUOY file"; echo
        # make sure that lon and lat are in the correct format
        #flon1b=`echo $flon1 | awk '{printf "%8.3f", $1+360.}'`
        flon1b=`echo $flon1 | awk '{printf "%8.3f", $1}'`
        flat1b=`echo $flat1 | awk '{printf "%7.3f", $1}'`
        echo " $flon1b $flat1b 'SYST COORD' 5.0 DAT TOC  1"    >& buoy.loc
        echo " 0000.000 00.0000 'STOPSTRING' 999. XXX XXX 99"  >> buoy.loc
       fi

       #### Will need directory $ww3_inpdir to put the *.inp files
       rm -rf $ww3_inpdir; mkdir -p $ww3_inpdir

       # Partitioning

       # dtp='3600' ; PT=' '
       dtp='    0' ; PT='$'

       # run times
       t_beg="$date_ini 000000"
       t_end="$date_end 000000"

       # storage interval
       dt=' 3600'

       # restartfile interval
       dte='86400'

       #fstID=`echo $t_beg | sed 's/ /\./g'`
       #rstID=`echo $t_rst | sed 's/ /\./g'`


########################################################################
#                                                                      #
#               1. WW3_GRID INPUT FILE                                 #
#                                                                      #
########################################################################


count=0

for mod in $domain_ww3 ; do

echo; echo " ... doing .inp file for $mod"; echo

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
mv ww3_grid.inp.$mod $ww3_inpdir
done

for mod in $wnd $ice $buo; do 
if [ "$mod" != 'no' ]; then

echo; echo " ... doing .inp file for $mod"; echo

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
mv ww3_grid.inp.$mod $ww3_inpdir
fi
done

########################################################################
#                                                                      #
#                      2. WW3_STRT INPUT FILE                          #
#                                                                      #
########################################################################

cat > ww3_strt.inp << EOF
$ -------------------------------------------------------------------- $
$    WAVEWATCH III prnc input file                                     $
$ -------------------------------------------------------------------- $
  $itype
$  fp   sip     thm  ncos xm    six     ym     siy hmax
$  0.07 0.01    245. 5    180.  20.     50.    10. 1
$ -------------------------------------------------------------------- $
$    End of file                                                       $
$ -------------------------------------------------------------------- $
EOF

mv ww3_strt.inp $ww3_inpdir

########################################################################
#                                                                      #
#                      3. WW3_PRNC INPUT DATA                          #
#                                                                      #
########################################################################

cat > ww3_prnc.inp.$wnd << EOF
$ -------------------------------------------------------------------- $
$    WAVEWATCH III prnc input file                                     $
$ -------------------------------------------------------------------- $
  'WND' 'LL' T T
   lon lat
$  U   V
$  U_GRD_L103   V_GRD_L103
   Uwind  Vwind
  'wind.nc'
$ -------------------------------------------------------------------- $
$    End of file                                                       $
$ -------------------------------------------------------------------- $
EOF

mv ww3_prnc.inp.$wnd $ww3_inpdir

########################################################################
#                                                                      #
#                      4. WW3_MULTI INPUT FILE                         #
#                                                                      #
########################################################################

cat > ww3_multi.inp << EOF
$ ---------------------------------------------------------
$          WAVEWATCH III multi-grid input file
$ ---------------------------------------------------------
  $NR $NRI $UPTS 1 F F
$
EOF

if [ "$wnd" != 'no' ] ; then
echo "  '$wnd'  F F T F F F F"   >> ww3_multi.inp ; fi
if [ "$ice" != 'no' ] ; then
echo "  '$ice'  F F F T F F F"   >> ww3_multi.inp ; fi
if [ "$buo" != 'no' ] ; then
echo "  '$buo'"                  >> ww3_multi.inp ; fi

flags="'no' 'no' '$wnd' '$ice' 'no' 'no' 'no'"

n=0
for mod in $domain_ww3; do
let n=n+1
echo "  '$mod' $flags  $n 1  0.00 1.00  F" >> ww3_multi.inp
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

if [ $buoy == 'yes' ]; then
cat buoy.loc >> ww3_multi.inp
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
  $t_beg   $dte  $t_end
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

mv ww3_multi.inp $ww3_inpdir

#=======================================================================
echo ; echo " ==> FINISHED making input files <==";
echo ; now=$(date "+%Y/%m/%d %T")
echo " ... finished input files at $now" >> $log
#=======================================================================


cd ${__dir}

#########################################################################
#                                                                       #
#                            THE END                                    #
#                                                                       #
#########################################################################
