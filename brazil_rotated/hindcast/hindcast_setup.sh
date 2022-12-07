#!/bin/bash
#

       ###### issues to solve:

       ###### Nothing for now !!!

       ### export PATHs is necessary for the crontab
       ### which will not source .bashrc because it doesnt run in a terminal

       ### the next are necessary for runnning all bash functions
       export PATH=${PATH}:$HOME/scripts/bash
       export PATH=${PATH}:$HOME/scripts/bash/find_fncts
       export PATH=${PATH}:$HOME/scripts/bash/wget

       ### the next is necessary when downloading GFS
       export PATH=${PATH}:$HOME/apps/wgrib2/

       ### the next is necessary for running ROMS
       #export PATH=${PATH}:${HOME}/apps/bin
       #export PATH=${PATH}:${HOME}/operational/forecast/roms/npo0.08/code
       #export PATH=${PATH}:${HOME}/operational/scripts/roms_grd+clm

       ### the next is necessary for running WW3
       #export PATH=${PATH}:${HOME}/operational/forecast/ww3/npo0.33/bash


       echo
       echo " ==> Sourcing hindcast_setup.sh for general hindcast settings <=="
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
       #lastmonth=`find_last_month.sh $yr $mm $dd`
       
       ########################################################################
       #                                                                      #
       #                      GENERIC INFO                                    #
       #                                                                      #
       ########################################################################

       ndays=1 
       nsecs=60            ### delta-t
       nfast=30            ### ext mode steps

       roms_his_dh=3       ### output interval for history file
       nhrs_roms=`echo $ndays 24 $roms_his_dh | awk '{print $1*$2/$3 + 1}'`
       nsteps=`echo $ndays $nsecs | awk '{print int($1*24*3600/$2)}'`
       dt="${nsecs}.0d0"

       nsig='30'
       incr='0.05'        

       #nudge_scl='lin_10lines'
       nudge_scl='exp_medium'
       expt="${domain_roms}_${version}_${today}"

       dqdsst='-100'
       rotang="37."

       appflag="BRZ"
       mytitle="Brazil 1/20 rotated 55W-25W - 42S-0N (221x651x30)"
       varinfo="$HOME/src/roms/ROMS/External/varinfo.dat"
       
       # domain names and geographical limits

       domain_wind='brz0.50' 
       domain_roms='brz0.05r'
       domain_ogcm='brz0.08'

       version='01a'

       wesn_roms="-58.0 -20.0 -42.0 16.0"
       wesn_ogcm="-58.0 -20.0 -42.0 16.0"
       wesn_gfs=" -58.0 -20.0 -42.0 16.0"
       wesn_sla=" -58.0 -20.0 -42.0 16.0"

       # WIND
       wind='gfs'       ### either gfs or cfsr

       # nudging
       tnudg=360.0       #360.0       #0.3333
       znudg=360.0      #360.0       #0.0833
       obcfac=360.0      #360.0       #120.0

       # ref time for input files
       reftime=20000101

       # nrrec
       #  0 starts a new run
       # -1 restarts from last data in previous
       #  1 restarts from first data in previous
       nrrec=-1          

       ramp_flag='tide-no-ramp'    # either tide-with-ramp or tide-no-ramp
       nudge_flag='nudge-by-user'  # either nudge-by-user  or ananudge
       avg_flag='avg'              # either avg or no-avg

       # mpi tiles
       ntile_i=4
       ntile_j=10

       ########################################################################
       #                                                                      #
       #                      INFO FOR OGCM                                   #
       #                                                                      #
       ########################################################################

       if [ -z "$ogcm" ]; then
              echo ; echo " ... using generic OGCM setings !!"; echo
                # the next will be replaced depending on ogcm type
                dh=3
                nh=21
                ndep=40
                ntimes=8
                ndat=`echo $ndays $ntimes | awk '{print $1*$2+1}'`
                nhrs=`echo $ndays 24 | awk '{print $1*$2}'`       
       elif [ "$ogcm" == "nemo" ]; then
                dh=24
                nh=24
                ndep=50
                # the number of time steps per day
                ntimes=1
                # number of data in the aggregated OGCM file
                # for nemo it shall be +2
                ndat=`echo $ndays $ntimes | awk '{print $1*$2+2}'`
                nhrs=`echo $ndays 24 | awk '{print $1*$2}'`
       elif [[ "$ogcm" == "glby" ]] || [[ "$ogcm" == "glbv" ]] || [[ "$ogcm" == "glbu" ]]; then
                dh=6
                nh=18
                ndep=40
                # number of time steps per day
                ntimes=`echo 24 $dh | awk '{print int($1/$2)}'`
                # number of data in the aggregated OGCM file
                # for glby it shall be +1
                ndat=`echo $ndays $ntimes | awk '{print $1*$2+1}'`
                nhrs=`echo $ndays 24 | awk '{print $1*$2}'`
       else
                echo
                echo " ... ogcm $ogcm is not configured in the system"
                echo
       fi

       ########################################################################
       #                                                                      #
       #                   SPECIFIC INFO FOR ROMS                             #
       #                                                                      #
       ########################################################################


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
       #                     INFO FOR SIG2Z                                   #
       #                                                                      #
       ########################################################################


       depths_hncoda="0, 2, 4, 6, 8, 10, 12, 15, 20, 25, 30, 35, 40, 45, 50,  \
       60, 70, 80, 90, 100, 125, 150, 200, 250, 300, 350, 400, 500, 600, 700, \
       800, 900, 1000, 1250, 1500, 2000, 2500, 3000, 4000, 7000"

       depths_nemo="0., 1.541375, 2.645669, 3.819495, 5.078224, 6.440614,    \
       7.92956, 9.572997, 11.405, 13.46714, 15.81007, 18.49556, 21.59882,    \
       25.21141, 29.44473, 34.43415, 40.34405, 47.37369, 55.76429, 65.80727, \
       77.85385, 92.32607, 109.7293, 130.666, 155.8507, 186.1256, 222.4752,  \
       266.0403, 318.1274, 380.213, 453.9377, 541.0889, 643.5668, 763.3331,  \
       902.3393, 1062.44, 1245.291, 1452.251, 1684.284, 1941.893, 2225.078,  \
       2533.336, 2865.703, 3220.82, 3597.032, 3992.484, 4405.224, 4833.291,  \
       5274.784, 7000.000"

       ########################################################################
       #                                                                      #
       #                      FILE & DIR NAMES                                #
       #                                                                      #
       ########################################################################


       operdir="$HOME/operational/brazil_rotated/hindcast"
       interp4roms="$HOME/scripts/4roms"
       pythdir="$HOME/scripts/python"

       stodir="$operdir/d-storage"
       logdir="$operdir/d-logfiles"
       tmpdir="$operdir/d-temporary"
       trunk="$operdir/d-trunk"

       roms_inpdir=$tmpdir/roms_in
       roms_outdir=$tmpdir/roms_out

       if [ ! -e $logdir ]; then mkdir -p $logdir;fi
       if [ ! -e $stodir ]; then mkdir -p $stodir;fi
       if [ ! -e $tmpdir ]; then mkdir -p $tmpdir;fi
       if [ ! -e $trunk ];  then mkdir -p $trunk;fi

       if [ ! -e $ww3_inpdir ]; then mkdir -p $ww3_inpdir; fi
       if [ ! -e $ww3_outdir ]; then mkdir -p $ww3_outdir; fi
       if [ ! -e $roms_inpdir ]; then mkdir -p $roms_inpdir; fi
       if [ ! -e $roms_outdir ]; then mkdir -p $roms_outdir; fi


       ### roms dirs:
       romsdir="$HOME/operational/roms"
       roms_codedir="$romsdir/codes"
     
       romsgrd="$romsdir/grids/grid_${domain_roms}_${version}.nc"
       romstid="$romsdir/tides/tide_${domain_roms}_${version}_${yr}_ref2000.nc"
       romsnud="$romsdir/nudge/nudge_${domain_roms}_${version}_${nudge_scl}.nc"
       romsriv="$romsdir/river/river_${domain_roms}_${version}_${yr}0101_ref2000_small_rivers_zeroed.nc"

       romsfrc="$stodir/$today/${wind}_${domain_wind}_${today}.nc" # force file for roms

       #romsini="$stodir/$yesterday/roms_rst_${domain_roms}_${version}_${today}_${ogcm}.nc"
       romsini="$stodir/$lastmonth/roms_rst_${domain_roms}_${version}_${today}_${ogcm}.nc"
       ogcmfile="$stodir/$today/${ogcm}_${domain_ogcm}_${today}.nc" # ogcm file for roms

       romsclm="input_clm_${domain_roms}_${version}_${today}_${ogcm}.nc" # clim file for roms
       romsbry="input_bry_${domain_roms}_${version}_${today}_${ogcm}.nc" # bdry file for roms
       #romssst="input_clm_${domain_roms}_${version}_${today}_${ogcm}.nc" # surf file for roms

       nx=`cdo -s --no_warnings -griddes $romsgrd | grep xsize  | grep -m1 "" | awk '{print $3}'`
       ny=`cdo -s --no_warnings -griddes $romsgrd | grep ysize  | grep -m1 "" | awk '{print $3}'`
       x1=`cdo -s --no_warnings  info    $romsgrd | grep " 23 : " | awk '{printf "%.2f",  $9}'`
       x2=`cdo -s --no_warnings  info    $romsgrd | grep " 23 : " | awk '{printf "%.2f", $11}'`
       y1=`cdo -s --no_warnings  info    $romsgrd | grep " 24 : " | awk '{printf "%.2f",  $9}'`
       y2=`cdo -s --no_warnings  info    $romsgrd | grep " 24 : " | awk '{printf "%.2f", $11}'`

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


