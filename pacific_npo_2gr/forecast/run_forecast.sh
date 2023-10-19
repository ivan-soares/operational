#!/bin/bash
#

#    script to run 7-day forecast

#    will download GFS and HNCODA and create files:
#
#         gfs_bsa0.02_today.nc
#         gfs_atl1.00_today.nc
#
#    will run ROMS and WW3 and create the files:
#
#         roms_domain_version_today_ogcm_his.nc
#         roms_domain_version_today_ogcm_rst.nc
#         ww3_domain_version_today.nc
#         restart_xxxx
#

	set -o nounset
	set -o errexit
        set -o pipefail

##############################   help text   #######################################################

	if [ "$1" == "-h" ]; then
		echo " "
		echo " Function forecast_7days_all.sh takes 3 arguments: "
		echo "                                                   "
		echo "    (1) start date (yyyymmdd)                      "
		echo "    (2) # of days in the forecast range            "
		echo "    (3) ogcm (glby/glbv/nemo)                      "
		echo "                                                   "
		echo "    (4) step:                                      "
		echo "                                                   "
		echo "        1 start forecast                           "
		echo "        2 download gfs data                        "
		echo "        3 download ogcm data                       "
		echo "        4 make clim files for ROMS                 "
		echo "        5 run the model ROMS                       "
                echo "        6 make input files for WW3                 "
		echo "        7 run the model WW3                        "
		echo "        8 download NOAA WW3 + SIMCOSTA             "
		echo "        9 download CMEMS SLA + Vels                "
                echo "       10 make report                              "
                echo "       11 post process                             "
		echo "                                                   "
		echo "       99 do it all                                "
		echo "                                                   "
		echo "    Example:  20190801 nemo 99                     "
		echo " "
		exit 0
	fi

####################################################################################################

	#sleep 2s

	today=$1
	ndays=$2
	ogcm=$3
	N=$4

        #### fix ndays in step00

	sed -i "/ndays=/ c\        ndays=$ndays "  forecast_setup.sh

	#### start logfile

	here=`pwd`
	log="$here/timelog_${ogcm}.$today"

	now=$(date "+%Y/%m/%d %T")

	echo  >& $log
	echo " ########## NEW SHORT-RANGE OPERATIONAL FORECAST @ $now ##########" >> $log
	echo  >> $log

	echo
	echo " ==> STARTING ROMS/WW3 7-DAY FORECAST @ $now <== "
	echo

	args="$today $ogcm $here $log"
	args01="$today glby $here $log"
	args02="$today nemo $here $log"

##################################  DO IT ALL !!!  #################################################

	if  [ $N ==  1 -o $N == 99 ]; then ./step01_startup.sh         $args ; wait ; fi

	if  [ $N ==  2 -o $N == 99 ]; then ./step02_download_force.sh  $args ; wait ; fi

	if  [ $N ==  3 -o $N == 99 ]; then ./step03_download_ogcm.sh   $args ; wait ; fi

	if  [ $N ==  4 -o $N == 99 ]; then ./step04_make_clim4roms.sh  $args ; wait ; fi

	if  [ $N ==  5 -o $N == 99 ]; then ./step05_run_roms.sh        $args ; wait ; fi

        if  [ $N ==  6 -o $N == 99 ]; then ./step06_make_input4ww3.sh  $args ; wait ; fi

	if  [ $N ==  7 -o $N == 99 ]; then ./step07_run_ww3.sh         $args ; wait ; fi

        if  [ $N ==  8 -o $N == 99 ]; then ./step08_download_obs.sh    $args ; wait ; fi

	if  [ $N ==  9 -o $N == 99 ]; then ./step09_download_cmems.sh  $args ; wait ; fi

	if  [ $N == 10 -o $N == 99 ]; then ./step10_make_report.sh     $args ; wait ; fi

	if  [ $N == 11 -o $N == 99 ]; then ./step11_post_processing.sh   $args ; wait ; fi

###############################  DO ONLY ROMS  #####################################################

	if [ $N = 12345 ]; then 
		./step01_startup.sh         $args; wait 
		./step02_download_force.sh  $args; wait
		./step03_download_ogcm.sh   $args; wait
		./step04_make_clim4roms.sh  $args; wait
		./step05_run_roms.sh        $args; wait
	fi

	if [ $N = 123458910 ]; then
		./step01_startup.sh         $args; wait
		./step02_download_force.sh  $args; wait
		./step03_download_ogcm.sh   $args; wait
		./step04_make_clim4roms.sh  $args; wait
		./step05_run_roms.sh        $args; wait
		./step08_download_obs.sh    $args; wait
		./step09_download_cmems.sh  $args; wait
		./step10_make_report.sh     $args; wait
	fi

	if [ $N = 1345 ]; then
        	./step01_startup.sh         $args; wait
		./step03_download_ogcm.sh   $args; wait
        	./step04_make_clim4roms.sh  $args; wait
        	./step05_run_roms.sh        $args; wait
	fi

        if [ $N = 345 ]; then
                ./step03_download_ogcm.sh   $args; wait
                ./step04_make_clim4roms.sh  $args; wait
                ./step05_run_roms.sh        $args; wait
        fi	

        if [ $N = 145 ]; then
                ./step01_startup.sh         $args; wait
		./step04_make_clim4roms.sh  $args; wait
                ./step05_run_roms.sh        $args; wait
        fi

        if [ $N = 15 ]; then
                ./step01_startup.sh         $args; wait
                ./step05_run_roms.sh        $args; wait
	fi

	if [ $N = 1234 ]; then
		./step01_startup.sh         $args; wait
		./step02_download_force.sh  $args; wait
		./step03_download_ogcm.sh   $args; wait
		./step04_make_clim4roms.sh  $args; wait
        fi

        if [ $N = 123 ]; then
                ./step01_startup.sh         $args; wait
                ./step02_download_force.sh  $args; wait
                ./step03_download_ogcm.sh   $args; wait
        fi


        if [ $N = 134 ]; then
                ./step01_startup.sh         $args; wait
                ./step03_download_ogcm.sh   $args; wait
                ./step04_make_clim4roms.sh  $args; wait
        fi

	if [ $N = 14 ]; then
                ./step01_startup.sh         $args; wait
                ./step04_make_clim4roms.sh  $args; wait
        fi

	if [ $N = 13 ]; then
                ./step01_startup.sh         $args; wait
                ./step03_download_ogcm.sh   $args; wait
        fi

        if [ $N = 89 ]; then
		./step08_download_obs.sh    $args ; wait
		./step09_download_cmems.sh  $args ; wait
	fi

        if [ $N = 33 ]; then
                ./step03_download_ogcm.old  $args; wait
        fi

###############################  DO ONLY WW3  ######################################################

	if [ $N = 1267 ]; then
		./step01_startup.sh         $args; wait
                ./step02_download_force.sh  $args; wait
		./step06_make_input4ww3.sh  $args; wait
		./step07_run_ww3.sh         $args; wait
	fi

        if [ $N = 167 ]; then
                ./step01_startup.sh         $args; wait
                ./step06_make_input4ww3.sh  $args; wait
                ./step07_run_ww3.sh         $args; wait
        fi

        if [ $N = 67 ]; then
                ./step06_make_input4ww3.sh  $args; wait
                ./step07_run_ww3.sh         $args; wait
        fi

################################# FINISH  ##########################################################

	now=$(date "+%Y/%m/%d %T")

	echo
	echo " ==> FINISHED ROMS/WW3 7-DAY FORECAST @ $now <== "
	echo

	echo  >> $log
	echo "########## END OF SHORT-RANGE OPERATIONAL FORECAST @ $now ##########" >> $log
	echo >> $log

	mv $log $here/d-logfiles/.

####################################################################################################

#                                  THE END

####################################################################################################

