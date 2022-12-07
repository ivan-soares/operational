#!/usr/bin/env bash

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

	set -o errexit
	set -o pipefail
	set -o nounset
#	set -o xtrace

	export SHELLOPTS

	# Set magic variables for current file & dir
	export __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
	export __file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
	export __base="$(basename ${__file} .sh)"
	export __root="$(cd "$(realpath "${__dir}/../../")" && pwd)" # <-- change this as it depends on your app

##############################   help text   #######################################################

	if [ "$1" == "-h" ]; then
		echo " "
		echo " Function forecast_7days_all.sh takes 3 arguments: "
		echo "                                                   "
		echo "    (1) start date (yyyymmdd)                      "
		echo "    (2) # of days in the forecast range            "
		echo "    (3) ogcm (glby/glbv/nemo)                      "
		echo "                                                   "
		echo "    (4) steps:                                     "
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
		echo "       10 move files                               "
		echo "       11 cleanup                                  "
		echo "                                                   "
		echo "       99 do it all (default)                      "
		echo "                                                   "
		echo "    Example:  run_forecast.sh 20210208 nemo 1 2 3  "
		echo "              - This will run steps 1, 2 and 3     "
		echo " "
		echo "    Example:  run_forecast.sh 20210208 nemo        "
		echo "              - This will run the whole system (99)"
		echo " "
		exit 0
	fi

####################################################################################################

	export today=$(date --date="$1" +%Y%m%d)
	export ndays=$2
	export ogcm=$3
	shift 3

    # Default is to run the whole system: steps=99
	steps=${@-99}

	# Initialize model configuration variables

	if [ ! -e "${__dir}/forecast_setup.sh" ]; then
		echo "ERROR: File forecast_setup.sh not found! "
		echo "    Make sure you copied the template and edited the variables to"
		echo "    configure your models accordingly"
		exit 1
	fi

	set -o allexport
	source "${__dir}/forecast_setup.sh"
	set +o allexport

	#### start logfile

	export log="$tmpdir/timelog_${ogcm}.$today"
	echo  >& $log

	#### get today's date

	now=`date`

	echo
	echo " ==> STARTING ROMS/WW3 7-DAY FORECAST @ $now <== "
	echo

##################################  DO IT ALL !!!  #################################################
	for step in ${steps}; do
		if  [[ "${step}" -eq  1 || "${step}" -eq 99 ]]; then ${__dir}/step01_startup.sh; wait; fi

		if  [[ "${step}" -eq  2 || "${step}" -eq 99 ]]; then ${__dir}/step02_download_force.sh; wait; fi

		if  [[ "${step}" -eq  3 || "${step}" -eq 99 ]]; then ${__dir}/step03_download_ogcm.sh; wait; fi

		if  [[ "${step}" -eq  4 || "${step}" -eq 99 ]]; then ${__dir}/step04_make_clim4roms.sh; wait; fi

		if  [[ "${step}" -eq  5 || "${step}" -eq 99 ]]; then ${__dir}/step05_run_roms.sh; wait; fi

		if  [[ "${step}" -eq  6 || "${step}" -eq 99 ]]; then ${__dir}/step06_make_input4ww3.sh; wait; fi

		if  [[ "${step}" -eq  7 || "${step}" -eq 99 ]]; then ${__dir}/step07_run_ww3.sh; wait; fi

		if  [[ "${step}" -eq  8 || "${step}" -eq 99 ]]; then ${__dir}/step08_download_obs.sh; wait; fi

		if  [[ "${step}" -eq  9 || "${step}" -eq 99 ]]; then ${__dir}/step09_download_cmems.sh; wait; fi

		if  [[ "${step}" -eq 10 || "${step}" -eq 99 ]]; then ${__dir}/step10_make_report.sh; wait; fi

		if  [[ "${step}" -eq 11 || "${step}" -eq 99 ]]; then ${__dir}/step11_cleanup.sh; wait; fi
	done
################################# FINISH  ##########################################################

	now=`date`

	echo
	echo " ==> FINISHED ROMS/WW3 7-DAY FORECAST @ $now <== "
	echo

	echo  >> $log
	now=$(date "+%Y/%m/%d %T"); echo " ==> finished forecast cycle at $now" >> $log
	echo >> $log

	mv $log ${__dir}/d-outputs/logfiles/.
	rm -rf $tmpdir

####################################################################################################
#                                  THE END
####################################################################################################
