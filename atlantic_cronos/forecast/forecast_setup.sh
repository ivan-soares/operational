#!/bin/bash

       set +o nounset
       source ${HOME}/pyenvs/base/bin/activate
       set -o nounset

       scriptsdir=${__root}/scripts

       ### the next is necessary to run all compiled programs
       PREFIX="/shared/opt/gnusoft"
       PATH=${PATH:-}:${PREFIX}/bin
       LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:${PREFIX}/lib:${PREFIX}/lib64

       ### the next are necessary for running all bash functions
       PATH=${PATH}:${scriptsdir}/bash
       PATH=${PATH}:${scriptsdir}/bash/find_fncts
       PATH=${PATH}:${scriptsdir}/bash/wget
       PATH=${PATH}:${scriptsdir}/bash/check

       ### the next is necessary for running ROMS
       PATH=${PATH}:${scriptsdir}/roms_grd+clm

       ### the next is necessary to compile the latex bulletin
       PATH=${PATH}:/usr/local/texlive/2020/bin/x86_64-linux/
       
       ### the next is necessary to import python modules
       PYTHONPATH=${__root}/scripts/python

       export PATH
       export PYTHONPATH

       echo
       echo " ==> Sourcing forecast_setup.sh for general forecast settings <=="
       echo
       
       ########################################################################
       #                                                                      #
       #                          DATE                                        #
       #                                                                      #
       ########################################################################

       yr=${today:0:4}
       mm=${today:4:2}
       dd=${today:6:2}

       yesterday=`find_yesterday.sh $yr $mm $dd`
       tomorrow=`find_tomorrow.sh $yr $mm $dd`

       ########################################################################
       #                                                                      #
       #                      GENERIC INFO                                    #
       #                                                                      #
       ########################################################################

       nhrs_ww3=`echo $ndays 24 | awk '{print $1*$2}'`
       nhrs_roms=`echo $ndays 24 | awk '{print $1*$2 + 1}'`

       last=`find_last_day.sh $today $ndays`
       reftime=20000101

       # domain names and geographical limits

       domain_wind='glo0.50'
       domain_wind2='brz0.50'
       domain_roms='brz0.05'
       domain_ogcm='brz0.08'
       domain_ww3='atl0.500 sao0.125 bca0.025'

       wesn_roms="-52.0 -25.0 -30.0 10.0"
       wesn_ogcm="-53.0 -24.0 -31.0 11.0"
       wesn_gfs=" -53.0 -24.0 -31.0 11.0"
       wesn_ww3=" -49.0 -35.0 -26.0 -19.0"
       wesn_sla=" -53.0 -24.0 -31.0 11.0"

       # WIND
       wind='gfs'       ### either gfs or cfsr

       # XTRA products
       dh_noaa=3        ### WW3 NOAA best time interval is 3 hourly !!!!!!
       product=46       ### CMEMS SLA ALLSAT product

       ########################################################################
       #                                                                      #
       #                      INFO FOR OGCM                                   #
       #                                                                      #
       ########################################################################

       if [ -z "$ogcm" ]; then
              echo ; echo " ... using generic OGCM setings \!\!"; echo
                # the next will be replaced depending on ogcm type
                dh=3
                nh=21
                ndep=40
                ntimes=8
                extra_times=1
       elif [ "$ogcm" == "nemo" ]; then
                dh=24
                nh=24
                ndep=50
                # the number of time steps per day
                ntimes=1
                extra_times=2
                # number of data in the aggregated OGCM file
                # for nemo it shall be +2
       elif [[ "$ogcm" == "glby" ]] || [[ "$ogcm" == "glbv" ]] || [[ "$ogcm" == "glbu" ]]; then
                dh=6
                nh=18
                ndep=40
                # number of time steps per day
                ntimes=`echo 24 $dh | awk '{print int($1/$2)}'`
                # number of data in the aggregated OGCM file
                # for glby it shall be +1
                extra_times=1
       else
                echo
                echo " ... ogcm $ogcm is not configured in the system"
                echo
       fi
       ndat=$(($ndays*$ntimes+$extra_times))
       nhrs=$(($ndays*24))

       ########################################################################
       #                                                                      #
       #                     INFO FOR ROMS                                    #
       #                                                                      #
       ########################################################################

       nsecs=60            ### delta-t
       nfast=30            ### ext mode steps
       roms_his_dh=1       ### output interval for history file

       nsteps=$(($ndays*24*3600/$nsecs))
       dt="${nsecs}.0d0"

       nsig='30'
       incr='0.05'        
       version='01g'
       nudge_scl='exp_weak'
       expt="${domain_roms}_${version}_${today}"

       appflag="BRZ"
       mytitle="Brazil 1/20 degreee 52W-25W - 30S-10N (541x801x30)"
       varinfo="$HOME/codes/roms/ROMS/External/varinfo.dat"

       # nudging
       tnudg=360.0       #0.3333
       znudg=360.0       #0.0833
       obcfac=360.0      #120.0

       # nrrec
       #  0 starts a new run
       # -1 restarts from last data in previous
       #  1 restarts from first data in previous
       nrrec=1          

       ramp_flag='tide_no_ramp'    # either tide_with_ramp or tide_no_ramp
       nudge_flag='nudge_by_user'  # either nudge_by_user  or ananudge
       avg_flag='avg'              # either avg or no_avg

       # mpi tiles
       ntile_i=6
       ntile_j=10

       # sigma coord params
       spheri='1'
       vtrans='2'
       vstret='4'
       thetas='4.0'
       thetab='4.0'
       tcline='100'
       hc='100'

       sig_params="$spheri $vtrans $vstret $thetas $thetab $tcline $hc $nsig"

       ########################################################################
       #                                                                      #
       #                     INFO FOR WW3                                     #
       #                                                                      #
       ########################################################################

       wnd=$wind
       ice='no'
       lvl='no'
       cur='no'

       buoy='no'   # either 'no' or 'points'

       ncdf='NC4'
       icomp='no'

       #fields='HS LM T02 T0M1 T01 FP DIR SPR DP MXH PHS PTP PLP PDIR PSPR PNR'
       fields='DPT WND HS LM T01 T02 FP DIR DP SPR PHS PLP PTP PDIR PSPR PWS TWS PNR TUS USS'

       #grds='atl0.500 sao0.125 bca0.025'

       gnames=(             'atl0.500'            'sao0.125'               'bca0.025'                    'gfs'                 'points')
       gsizes=(              '223 291'             '281 385'                '517 237'                '720 361'                '  5   5')
       gsteps=('1200.  400.  600. 10.' '1200. 400. 600. 10.'     '360. 120. 180. 10.'  '3600. 1800. 1800. 30.'  '3600. 1800. 1800. 30.')
       gtitle=(       'Atlantic Ocean' 'West South Atlantic'           'Campos Basin'             'GFS Global'   'Spectral data points')
       gzeroc=(            '-81. -80.'           '-60. -38.'            '-48.4 -25.4'                 '0. -90'               '-1.  -1.')
       grefin=(                 ' 2.0'                ' 8.0'                   '40.0'                    '2.0'                    '1.0')
       gtptns=(                  '999'                 '999'                    '999'                 '259920'                     '25')
       
       # Since arrays can't be environment variables, we need a hack to pass
       # them around. The line below create a variable named ARRAYS containing
       # a string with a series of commands with the array declarations. Later,
       # we can just eval "ARRAYS" so that the array variables become available
       ARRAYS="$(declare -p gnames gsizes gsteps gtitle gzeroc grefin gtptns | tr '\n' ';')"

       ########################################################################
       #                                                                      #
       #                     INFO FOR SIG2Z                                   #
       #                                                                      #
       ########################################################################


       depths_hncoda="0, 2, 4, 6, 8, 10, 12, 15, 20, 25, 30, 35, 40, 45, 50,  \
       60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 350, 400, 500, 600, 700, \
       800, 900, 1000, 1250, 1500, 2000, 2500, 3000, 4000, 5000"

       depths_nemo="0., 1.541375, 2.645669, 3.819495, 5.078224, 6.440614,    \
       7.92956, 9.572997, 11.405, 13.46714, 15.81007, 18.49556, 21.59882,    \
       25.21141, 29.44473, 34.43415, 40.34405, 47.37369, 55.76429, 65.80727, \
       77.85385, 92.32607, 109.7293, 130.666, 155.8507, 186.1256, 222.4752,  \
       266.0403, 318.1274, 380.213, 453.9377, 541.0889, 643.5668, 763.3331,  \
       902.3393, 1062.44, 1245.291, 1452.251, 1684.284, 1941.893, 2225.078,  \
       2533.336, 2865.703, 3220.82, 3597.032, 3992.484, 4405.224, 4833.291,  \
       5274.784, 5727.917"


       ########################################################################
       #                                                                      #
       #                     INFO FOR REPORT POINTS                           #
       #                                                                      #
       ########################################################################
       Plon="-40.00440,nan,-47.08801,-34.32428,-36.931353"
       Plat="-22.12235,nan,-27.71916,-08.14138,-13.68440"
       AW="-48.40,-51.45,-50.24,nan,-42.39"
       AE="-35.50,-33.00,-40.89,nan,-31.38"
       AS="-27.50,-05.35,-30.00,nan,-17.32"
       AN="-19.50,08.75,-20.00,nan,-09.20"
       shrt_name="bsc,bam,flp,alg,bts"
       bdr_pos="NW,SW,NW,W,NW"
       lng_name="Campos-Santos Basin,Amazon Basin,Florianopolis,Alagoas Coast,Baia de Todos os Santos"


       ########################################################################
       #                                                                      #
       #                      FILE & DIR NAMES                                #
       #                                                                      #
       ########################################################################

       operdir="${__root}/atlantic/forecast"
       makedir="${__root}/scripts/roms_grd+clm"
       pythdir="${__root}/scripts/python"

       stodir="$operdir/d-storage"
       report="$operdir/d-report"

       logdir="$operdir/d-outputs/logfiles"
       tmpdir=$(mktemp -d "${operdir}/d-outputs/temporary/XXXXXXXXXXXX")
       trunk="$operdir/d-outputs/trunk"

       if [ ! -e $logdir ]; then mkdir -p $logdir;fi
       if [ ! -e $stodir ]; then mkdir -p $stodir;fi
       if [ ! -e $tmpdir ]; then mkdir -p $tmpdir;fi
       if [ ! -e $trunk ];  then mkdir -p $trunk;fi

       ### ww3 dirs:
       ww3_codedir="$operdir/../../ww3/bash"
       ww3_grddir="$operdir/d-inputs/ww3/grids"
       ww3_inpdir="$operdir/d-inputs/ww3/inpfiles"

       ### roms dirs:
       roms_codedir="$operdir/d-codes/roms"
       roms_grddir="$operdir/d-inputs/roms/grids"
       roms_inpdir="$operdir/d-inputs/roms/inpfiles"

       romsgrd="$roms_grddir/grid_${domain_roms}_${version}.nc"
       romstid="$roms_inpdir/tide_${domain_roms}_${version}_${yr}_ref2000.nc"
       romsnud="$roms_inpdir/nudge_${domain_roms}_${version}_${nudge_scl}.nc"
       romsriv="$roms_inpdir/river_${domain_roms}_${version}_${yr}0101_ref2000_small_rivers_zeroed.nc"

       ww3wind="$stodir/$today/${wind}_glo0.50_${today}.nc" # wind file for ww3
       romsfrc="$stodir/$today/${wind}_brz0.50_${today}.nc" # force file for roms

       ww3ini="$stodir/$yesterday/ww3_rst_DOMAIN_${today}.000000"
       romsini="$stodir/$yesterday/roms_rst_${domain_roms}_${version}_${today}_${ogcm}.nc"
       ogcmfile="$stodir/$today/${ogcm}_${domain_ogcm}_${today}.nc" # ogcm file for roms

       romsclm="input_clm_${domain_roms}_${version}_${today}_${ogcm}.nc" # clim file for roms
       romsbry="input_bry_${domain_roms}_${version}_${today}_${ogcm}.nc" # bdry file for roms
       romssst="input_clm_${domain_roms}_${version}_${today}_${ogcm}.nc" # surf file for roms

       nx=`cdo -s -w -griddes $romsgrd | grep xsize  | grep -m1 "" | awk '{print $3}'`
       ny=`cdo -s -w -griddes $romsgrd | grep ysize  | grep -m1 "" | awk '{print $3}'`
       x1=`cdo -s -w  info    $romsgrd | grep " 23 : " | awk '{printf "%.2f",  $9}'`
       x2=`cdo -s -w  info    $romsgrd | grep " 23 : " | awk '{printf "%.2f", $11}'`
       y1=`cdo -s -w  info    $romsgrd | grep " 24 : " | awk '{printf "%.2f",  $9}'`
       y2=`cdo -s -w  info    $romsgrd | grep " 24 : " | awk '{printf "%.2f", $11}'`

       lonlatbox="$x1 $x2 $y1 $y2"

       nlon=$nx
       nlat=$ny
       lon1=$x1
       lon2=$x2
       lat1=$y1
       lat2=$y2

       dlon=$incr
       dlat=$incr

       ###############################################################################################
       #                                                                                             #
       #                                     THE END                                                 #
       #                                                                                             #
       ###############################################################################################


