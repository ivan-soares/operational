#!/bin/bash
#
        #### S01

	today=$1
	ogcm=$2
	here=$3
	log=$4

	source $here/forecast_setup.sh # will load dir names and other info

	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ==> starting forecast at $now" >> $log; echo >> $log
	echo " ==> $now HERE I am for step 01: start forecast <=="; echo
	#====================================================================================

	sto=$stodir/$today
	lgf=$logdir/$today

	echo
	echo " ... today is ${yr}-${mm}-${dd}"
	echo

	######################### storage dir

	if [ -e $sto ]; then
	      echo " ... dir $sto exists, will use it"
	else 
	      echo " ... dir $sto doesnt exist, will create it"
	      mkdir $sto
	fi

	######################### logfile dir

	#if [ -e $lgf ]; then
	#       echo " ... dir $lgf exists, will use it"
	#else
	#        echo " ... dir $lgf doesnt exist, will create it"
	#        mkdir $lgf
	#fi

	######################### temporary dir

	if [ -e $tmpdir ]; then 
	      echo " ... dir $tmpdir exists, will clean it"
	      rm -r $tmpdir/*
	else
	      echo " ... dir $tmpdir doesnt exist, will create it" 
	      mkdir $tmpdir
	fi

	echo; echo " ... end of step 01 "; echo

################################ the end #######################################################

