#!/bin/bash
#
	#### S11

	today=$1
	ogcm=$2
	here=$3
	log=$4

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	source $here/forecast_setup.sh # will load dir names and other info

	#====================================================================================
	echo >> $log; cd $tmpdir; dr=$PWD; now=$(date "+%Y/%m/%d %T")
	echo " ... starting script to post process files at $now" >> $log
	echo ; echo " ==> $now HERE I am @ $dr for step 11: post process files <=="; echo
	#====================================================================================

	sto="$stodir/$today"
	jenny="$HOME/storage-jenny/operational/$today"

	echo
	echo " ... today is ${yr}-${mm}-${dd}"
	echo " ... will interpolate files and move them to storage $jenny"
	echo

	imodel="glby"


	################ check directories in storage JENNY

	source $here/step11_sub00_check_jenny_dirs.sh
 
	######  sub01 will create zlevel files $outroms1, $outroms2, $outogm1 & outogcm2

	source $here/step11_sub01_interp_ogcms_to_zlevels.sh

        ######  sub02 will create MLD & LANGMUIR files

        source $here/step11_sub02_interp_mld_langmuir.sh	

	#====================================================================================
	echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
	echo " ... ... finished post processing files at $now" >> $log; echo >> $log
	echo " ==> $now FINISHED post processing files <=="; echo
	#====================================================================================

	cd $here

#### the end
