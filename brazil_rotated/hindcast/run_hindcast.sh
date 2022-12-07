#!/bin/bash
#

#    script to run ROMS in hindcast mode 

#    will download GFS, NEMO & HNCODA 
#    will run ROMS and create the files:
#
#         roms_his_domain_version_today_ogcm.nc
#         roms_rst_domain_version_today_ogcm.nc
#         roms_avg_domain_version_today_ogcm.nc
#

        set -o nounset
        set -o errexit

        if [ ! -e "hindcast_setup.sh" ]; then
		echo
	        echo "    ERROR: File hindcast_setup.sh not found! "
	        echo "    Make sure you copied the template and edited the variables to"
	        echo "    configure your models accordingly"
		echo
	        exit 1
	fi

######################   help text   #######################################################

	if [ "$1" == "-h" ]; then
		echo " "
		echo " Function run_hindcast.sh takes 4 arguments: "
		echo "                                             "
		echo "    (1) start date (yyyymmdd)                "
		echo "    (2) ndays (n. of days to run)            "
		echo "    (3) ogcm (glby/glbv/nemo)                "
		echo "                                             "
		echo "    (4) step:                                "
		echo "                                             "
		echo "        1 start new cycle                    "
		echo "        2 download gfs data                  "
		echo "        3 download ogcm data                 "
		echo "        4 make clim files for ROMS           "
		echo "        5 run the model ROMS                 "
		echo "                                             "
		echo "       99 do it all                          "
		echo "                                             "
		echo "    Example:  20190801 30 nemo 99            "
		echo " "
		exit 0
	fi

####################################################################################################

	sleep 2s

	today=$1
	ndays=$2
	ogcm=$3
	N=$4

	#### fix ndays in step00

	sed -i "/ ndays=/ c\       ndays=$ndays "  hindcast_setup.sh

	#### start logfile

	here=`pwd`
	log="$here/timelog_${ogcm}.$today"
	echo  >& $log

	#### get today's date	

	now=`date`

	echo
	echo " ==> STARTING ROMS SHORTTERM HINDCAST @ $now <== "
	echo

	args="$today $ogcm $here $log"
	arg1="$today glby  $here $log"
	arg2="$today nemo  $here $log"

##################################  DO IT ALL !!!  #################################################

	if  [ $N ==  1 -o $N == 99 ]; then ./step01_startup.sh        $args ; wait ; fi

	if  [ $N ==  2 -o $N == 99 ]; then ./step02_download_force.sh $args ; wait ; fi

	if  [ $N ==  3 -o $N == 99 ]; then ./step03_download_ogcm.sh  $args ; wait ; fi

	if  [ $N ==  4 -o $N == 99 ]; then ./step04_make_clim4roms.sh $args ; wait ; fi

	if  [ $N ==  5 -o $N == 99 ]; then ./step05_run_roms.sh       $args ; wait ; fi

###############################  DO ONLY ROMS  #####################################################

	if [ $N = 12345 ]; then 
		./step01_startup.sh         $args; wait 
		./step02_download_force.sh  $args; wait
		./step03_download_ogcm.sh   $args; wait
		./step04_make_clim4roms.sh  $args; wait
		./step05_run_roms.sh        $args; wait
	fi

	if [ $N = 1345 ]; then
        	./step01_startup.sh         $args; wait
		./step03_download_ogcm.sh   $args; wait
        	./step04_make_clim4roms.sh  $args; wait
        	./step05_run_roms.sh        $args; wait
	fi	

        if [ $N = 1234 ]; then
		./step01_startup.sh         $args; wait
	        ./step02_download_force.sh  $args; wait
	        ./step03_download_ogcm.sh   $args; wait
	        ./step04_make_clim4roms.sh  $args; wait
	fi

        if [ $N = 145 ]; then
                ./step01_startup.sh         $args; wait
		./step04_make_clim4roms.sh  $args; wait
                ./step05_run_roms.sh        $args; wait
        fi

        if [ $N = 1233 ]; then
                ./step01_startup.sh         $args; wait
                ./step02_download_force.sh  $args; wait
                ./step03_download_ogcm.sh   $arg1; wait
                ./step03_download_ogcm.sh   $arg2; wait
	fi

        if [ $N = 15 ]; then
                ./step01_startup.sh         $args; wait
                ./step05_run_roms.sh        $args; wait
	fi

################################# FINISH  ##########################################################

	now=`date`

	echo
	echo " ==> FINISHED ROMS HINDCAST @ $now <== "
	echo

	echo  >> $log
	now=$(date "+%Y/%m/%d %T"); echo " ==> finished hindcast cycle at $now" >> $log
	echo >> $log

        mv $log $here/d-logfiles/.


####################################################################################################

#                                  THE END

####################################################################################################

