#!/bin/bash
#

####    Script to check integrity of file

	infile=$1
	itype=$2
	log=$2

	
	#====================================================================================
	dr=`pwd`
	echo ; echo " ==> HERE I am @ $dr to execute check procedure on file $infile <=="; echo
	now=$(date "+%Y/%m/%d %T"); echo " ... starting check procedure at $now" >> $log
	#====================================================================================

	echo
	echo " ... Initiating routine to check integrity of file "
	echo " ... must provide the full-length directory of input file "
	echo

	check=000
	get_file_again="no"

	case $itype in
	     'glby')
	        check=`./check_glby.sh $infile`
		;;
	     'nemo')
		check=`./check_nemo.sh $infile`
		;;
	     'gfs')
		check=`./check_gfs.sh $infile`
	        ;;
	      *)
	        echo " ... ERROR ! wrong check itype option, exiting"
	        exit
	esac

	echo " ... file check is $check"
	echo

	check_nan=${check:0:1}
	check_size=${check:1:1}
	check_espur=${check:2:1}

	##### NaNs
	if [ $check_nan == 0 ]; then
	 	echo " ... the file has no NaN"
	elif [ $check_nan == 1 ]; then
		echo " ... the file contain NaN, will download again \!\!"
		get_file_again="yes"
	else
		echo " ... error, wrong check result, exiting"
		exit; echo
	fi

	##### size of downloaded data: nlon/nlat
	if [ $check_size == 0 ]; then
		echo " ... downloaded data have the correct size (nlon/nlat)"
	elif [ $check_size == 1 ]; then
		echo " ... the size of the data is not the expected one, will download again \!\!"
		get_file_again="yes"
	else
		echo " ... error, wrong check result, exiting"
		exit; echo
	fi

	##### espurious values
	if [ $check_espur == 0 ]; then
		echo " ... downloaded data have no espurious values"
	elif [ $check_espur == 1 ]; then
		echo " ... the file contain espurious values, will download again \!\!"
		get_file_again="yes"
	else
		echo " ... error, wrong check result, exiting"
		exit; echo
	fi
	

	#====================================================================================
	echo ; echo " ==> FINISHED checking file <=="; echo
	now=$(date "+%Y/%m/%d %T"); echo " ... finished check procedure at $now" >> $log
	#====================================================================================


#### the end
