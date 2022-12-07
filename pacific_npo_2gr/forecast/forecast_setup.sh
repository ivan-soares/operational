#!/bin/bash
#

	###### issues to solve:

	###### Nothing for now !!!

	### export PATHs is necessary for the crontab
	### which will not source .bashrc because it doesnt run in a terminal

	scriptsdir=${HOME}/scripts/bash

	export PATH=${PATH}:${scriptsdir}
	export PATH=${PATH}:${scriptsdir}/find_fncts
	export PATH=${PATH}:${scriptsdir}/wget
	export PATH=${PATH}:${scriptsdir}/check

	### the next is necessary when downloading GFS
	export PATH=${PATH}:$HOME/apps/wgrib2/

	#### path to ncdump
	export PATH=${PATH}:$HOME/apps/netcdf-c-4.8.0/bin

	#export PATH=${PATH}:${ww3dir}

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

        ndays=1 

	nhrs_ww3=`echo $ndays 24 | awk '{print $1*$2}'`
	nhrs_roms=`echo $ndays 24 | awk '{print $1*$2 + 1}'`

	last=`find_last_day.sh $today $ndays`
	refday=20000101
	reftime=$refday


	# domain names and geographical limits

	domain_wind='glo0.25'
	domain_wind2='npo0.25'
	domain_roms='npo0.08'
	domain_roms2='npo0.0267'
	domain_ogcm='npo0.08'
	domain_ww3='pac1.00 npo0.25'

	wesn_roms="-166.0 -118.0 16.0 46.0"
	wesn_ogcm="-167.0 -117.0 15.0 47.0"
	wesn_gfs=" -167.0 -117.0 15.0 47.0"   # used to make force file for roms
	wesn_ww3=" -170.0 -100.0 10.0 61.0"   # used to download noaa ww3
	wesn_sla=" -170.0 -100.0 10.0 61.0"   # used to download cmems sla

	# WIND
	wind='gfs'       ### either gfs or cfsr

	# XTRA products
	dh_noaa=1        ### WW3 NOAA best time interval is 3 hourly !!!!!!
	product=46       ### CMEMS SLA ALLSAT product


	nz_mld=17        ### number of z levels in files used to compute MLD and Langmuir


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
        elif [ "$ogcm" == "nemo24" ]; then
                dh=24
                nh=24
                ndep=50
                # the number of time steps per day
                ntimes=1
                # number of data in the aggregated OGCM file
                # for nemo it shall be +2
                ndat=`echo $ndays $ntimes | awk '{print $1*$2+2}'`
                nhrs=`echo $ndays 24 | awk '{print $1*$2}'`
	elif [ "$ogcm" == "nemo" ]; then
		dh=24
		nh=24
		ndep=50
		# number of data in the aggregated OGCM file
		# for nemo it shall be +1
                if [ $ndays -le 2 ]; then
		     nh=6
	             ntimes=4
		     ndat=$(($ndays*$ntimes+1))
		else
		     nh=24
                     ntimes=1
		     kdays=$(($ndays-2))
                     ndat=$((8+$kdays*$ntimes+1))
		     #ndat=`echo $ndays $ntimes | awk '{print $1*$2+1}'`
		fi
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
        elif [[ "$ogcm" == "data" ]] || [[ "$ogcm" == "ww3" ]]; then
                dh=1
                nh=24
                ndep=1
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
	#                     INFO FOR ROMS                                    #
	#                                                                      #
	########################################################################

	nsecs=120            ### delta-t
	nfast=30            ### ext mode steps
	roms_his_dh=1       ### output interval for history file

	nsteps=`echo $ndays $nsecs | awk '{print int($1*24*3600/$2)}'`
	dt="${nsecs}.0d0"

	nsecs2=`echo $nsecs | awk '{print $1/2}'`
	nsteps2=`echo $ndays $nsecs2 | awk '{print int($1*24*3600/$2)}'`
	dt2="${nsecs2}.0d0"

	nsig='30'
	incr='0.08'        
	version='07e'
	version2='01c'

	nudge_scl='exp_strong'
	expt="${domain_roms}_${version}_${today}"
	rotang=0.

	appflag="NPO2GR"
	mytitle="NorthEast Pacific 1/12.5 degreee 166W-118W - 16N-46N (601x376x30)"
	varinfo="$HOME/roms/trunk/ROMS/External/varinfo.dat"

	# nudging
	tnudg=360.0       #0.3333
	znudg=360.0       #0.0833
	obcfac=360.0      #120.0

	# nrrec
	#  0 starts a new run
	# -1 restarts from last data in previous
	#  1 restarts from first data in previous
	nrrec=-1
	nrrec2=1          

	### keep ramp_flag as 'tide_with_ramp'
	### if no restart file is found, the flag will changed to 'tide_no_ramp'

	ramp_flag='tide_no_ramp'  # either tide_with_ramp or tide_no_ramp
	nudge_flag='nudge_by_user'  # either nudge_by_user  or ananudge
	avg_flag='avg_no_dqdsst'              # either avg or no_avg

	# mpi tiles
	ntile_i=8
	ntile_j=5

	let ntiles=${ntile_i}*${ntile_j}

	# sigma coord params
	spheri='1'
	vtrans='2'
	vstret='4'
	thetas='10.0'
	thetab='4.0'
	tcline='150'
	hc='150'

	sig_params="$spheri $vtrans $vstret $thetas $thetab $tcline $hc $nsig"

	########################################################################
	#                                                                      #
	#                     INFO FOR WW3                                     #
	#                                                                      #
	########################################################################

	date_ini="${today}.000000"
        date_rst="${tomorrow}.000000"
        date_end="${last}.000000"

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

	gnames=(              'pac1.00'             'npo0.25'                   'gfs'                 'points')
        gsizes=(             '177  144'            '165  125'              '1440 721'                    '3 3')
        gsteps=('3600. 1700. 1800. 30.' '1800. 900. 900. 30.' '3600. 1700. 1800. 30.'  '3600. 1700. 1800. 30.')
        gtitle=(        'Pacific Ocean'   'Northeast Pacific'   'GFS Global 0.25 deg'   'Spectral data points')
        gzeroc=(            '120. -80.'         '204.0 19.00'              '0. -90.0'               '-1.  -1.')
        grefin=(                 ' 1.0'                ' 4.0'                   '4.0'                    '1.0')
        gtptns=(                  '999'                 '999'               '1038240'                      '9')

	#### forecast point coordinates

	echo "33 50 218 50 100" >& forecast_coord.txt

	latdeg=`cat forecast_coord.txt | awk '{print $1}'`
	latmin=`cat forecast_coord.txt | awk '{print $2}'`
	londeg=`cat forecast_coord.txt | awk '{print $3}'`
	lonmin=`cat forecast_coord.txt | awk '{print $4}'`
	ldiv=`  cat forecast_coord.txt | awk '{print $5}'`

	rm forecast_coord.txt

	s1=`echo $latdeg | awk '{print $1/sqrt($1^2)}'`
	s2=`echo $londeg | awk '{print $1/sqrt($1^2)}'`

	flat1=`echo $latdeg $latmin $ldiv $s1 | awk '{printf "%.2f", $1 + $4*$2/$3}'`
	flon1=`echo $londeg $lonmin $ldiv $s2 | awk '{printf "%.2f", $1 + $4*$2/$3}'`

	pcoord="${flat1}N${flon1}W"
	pcoord=${pcoord/\./p}
	pcoord=${pcoord/\./p}

	########################################################################
	#                                                                      #
	#                     INFO FOR SIG2Z                                   #
	#                                                                      #
	########################################################################

	depths_jenny="0,2,4,6,8,10,12,14"

	depths_mld="0,2,4,6,8,10,12,14,20,30,40,50,60,70,80,90,100,125,150,175,200,250"

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

	interp4roms="$HOME/scripts/4roms"
	pythdir="$HOME/scripts/python"

	operdir="$HOME/operational/pacific_npo_2gr/forecast"
	stodir="$operdir/d-storage"
	logdir="$operdir/d-logfiles"
	tmpdir="$operdir/d-temporary"
	trunk="$operdir/d-trunk"

	if [ ! -e $logdir ]; then mkdir -p $logdir;fi
	if [ ! -e $stodir ]; then mkdir -p $stodir;fi
	if [ ! -e $tmpdir ]; then mkdir -p $tmpdir;fi
	if [ ! -e $trunk ];  then mkdir -p $trunk;fi

	### ww3 dirs:
	ww3_codedir="$HOME/operational/ww3/codes"
	ww3_grddir="$HOME/operational/ww3/grids"
	ww3_inpdir="$HOME/operational/ww3/inpfiles"

	### roms dirs:
	romsdir="$HOME/operational/roms"
	roms_codedir="$romsdir/codes"

	romsgrd="$romsdir/grids/grid_${domain_roms}_${version}.nc"
        romsgrd2="$romsdir/grids/grid_${domain_roms2}_${version2}.nc"
        romsngc="$romsdir/grids/ngc_${domain_roms}_${version}+${domain_roms2}_${version2}.nc"

	romstid="$romsdir/tides/tide_${domain_roms}_${version}_${yr}_ref2000.nc"
	romsnud="$romsdir/nudge/nudge_${domain_roms}_${version}_${nudge_scl}.nc"
	romsriv="$romsdir/river/river_${domain_roms}_${version}_${yr}0101_ref2000.nc"

	ww3wind="$stodir/$today/${wind}_glo0.25_${today}.nc" # wind file for ww3
	romsfrc="$stodir/$today/${wind}_npo0.25_${today}.nc" # force file for roms

	ww3ini="$stodir/$yesterday/ww3_out_rst_${today}.000000.DOMAIN"
	romsini="$stodir/$yesterday/roms_rst_${domain_roms}_${version}_${today}_${ogcm}.nc"
        romsini2="$stodir/$yesterday/roms_rst_${domain_roms2}_${version2}_${today}_${ogcm}.nc"

	ogcmfile="$stodir/$today/${ogcm}_${domain_ogcm}_${today}.nc" # ogcm file for roms

	romsclm="input_clm_${domain_roms}_${version}_${today}_${ogcm}.nc" # clim file for roms
	romsbry="input_bry_${domain_roms}_${version}_${today}_${ogcm}.nc" # bdry file for roms
	romssst="input_clm_${domain_roms}_${version}_${today}_${ogcm}.nc" # surf file for roms

        romsclm2="input_clm_${domain_roms2}_${version2}_${today}_${ogcm}.nc" # clim file for roms grid 2

	###################### names of files used in step 11 to make files for storage JENNY!!!!!!!

        depth_ogcm="$here/d-interp/depths_${ogcm}_${domain_roms}.nc"
        depth_glby="$here/d-interp/depths_glby_${domain_roms}.nc"
        depth_nemo="$here/d-interp/depths_nemo_${domain_roms}.nc"

        depth_sig1="$here/d-interp/depths_sig_${domain_roms}.nc"
        depth_z1="$here/d-interp/depths_mld_${domain_roms}.nc"

        depth_sig2="$here/d-interp/depths_sig_${domain_roms2}.nc"
        depth_z2="$here/d-interp/depths_mld_${domain_roms2}.nc"

        domainname1="${domain_roms}_${version}"
        domainname2="${domain_roms2}_${version2}"

        romsfile1="$stodir/$today/roms_his_${domainname1}_${today}_${ogcm}.nc"
        romsfile2="$stodir/$today/roms_his_${domainname2}_${today}_${ogcm}.nc"
        ogcmfile1="$stodir/$today/glby_${domain_roms}_${today}.nc"
        ogcmfile2="$stodir/$today/nemo_${domain_roms}_${today}.nc"

        satfile="$stodir/$today/cmems_sla_vels_atl0.25_${today}.nc"
	mldfile="$stodir/$today/mld_${domainname1}_${today}.nc"

	jenny="$HOME/storage-jenny/operational/$today"
	
        outroms1="roms_zlevs_${domainname1}_${today}_${ogcm}.nc"
        outroms2="roms_zlevs_${domainname2}_${today}_${ogcm}.nc"
        outogcm1="glby_zlevs_${domainname1}_${today}.nc"
        outogcm2="nemo_zlevs_${domainname1}_${today}.nc"

        outroms1a="roms_zlevs_jenny_${domainname1}_${today}_${ogcm}.nc"
        outroms2a="roms_zlevs_jenny_${domainname2}_${today}_${ogcm}.nc"
        outogcm1a="glby_zlevs_jenny_${domainname1}_${today}.nc"
        outogcm2a="nemo_zlevs_jenny_${domainname1}_${today}.nc"

        outroms1b="roms_zlevs_mld_${domainname1}_${today}_${ogcm}.nc"
        outroms2b="roms_zlevs_mld_${domainname2}_${today}_${ogcm}.nc"
        outogcm1b="glby_zlevs_mld_${domainname1}_${today}.nc"
        outogcm2b="nemo_zlevs_mld_${domainname1}_${today}.nc"

        outsat="sat_sla+vel_${today}.nc"
	outmld="mld+langmuir_${today}.nc"

        outwave1="ww3_his_npo0.33_${today}.nc"
        outwave2="noaa_ww3_npo0.25_${today}.nc"

        outwind="gfs_${today}.nc"

        echo " ... roms grid file is $romsgrd"

        if [ -e  lonlat1.nc ]; then rm  lonlat1.nc; fi
        if [ -e  lonlat2.nc ]; then rm  lonlat2.nc; fi
        ncks -v lon_rho,lat_rho -d eta_rho,0 -d xi_rho,0   $romsgrd lonlat1.nc
        ncks -v lon_rho,lat_rho -d eta_rho,-1 -d xi_rho,-1 $romsgrd lonlat2.nc

        nx=`ncdump -h $romsgrd | grep "xi_rho = " | awk '{print $3}'`
        ny=`ncdump -h $romsgrd | grep "eta_rho = " | awk '{print $3}'`
        x1=`ncdump lonlat1.nc | grep -A1 "lon_rho =" | column | awk '{print $3}'`
        y1=`ncdump lonlat1.nc | grep -A1 "lat_rho =" | column | awk '{print $3}'`
        x2=`ncdump lonlat2.nc | grep -A1 "lon_rho =" | column | awk '{print $3}'`
        y2=`ncdump lonlat2.nc | grep -A1 "lat_rho =" | column | awk '{print $3}'`
        rm lonlat*

        #nx=`cdo -s --no_warnings -griddes $romsgrd | grep xsize  | grep -m1 "" | awk '{print $3}'`
        #ny=`cdo -s --no_warnings -griddes $romsgrd | grep ysize  | grep -m1 "" | awk '{print $3}'`
        #x1=`cdo -s --no_warnings  info    $romsgrd | grep " 23 : " | awk '{printf "%.2f",  $9}'`
        #x2=`cdo -s --no_warnings  info    $romsgrd | grep " 23 : " | awk '{printf "%.2f", $11}'`
        #y1=`cdo -s --no_warnings  info    $romsgrd | grep " 24 : " | awk '{printf "%.2f",  $9}'`
        #y2=`cdo -s --no_warnings  info    $romsgrd | grep " 24 : " | awk '{printf "%.2f", $11}'`

        lonlatbox="$x1 $x2 $y1 $y2"

        echo " ... grid box is $lonlatbox"

        nlon=$nx
        nlat=$ny
        lon1=$x1
        lon2=$x2
        lat1=$y1
        lat2=$y2

        nz=$nsig

        dlon=$incr
        dlat=$incr

        echo 
        echo " ... grid size is $nlon lons,  $nlat lats, $nz layers"
        echo


	###############################################################################################
	#                                                                                             #
	#                                     THE END                                                 #
	#                                                                                             #
	###############################################################################################


