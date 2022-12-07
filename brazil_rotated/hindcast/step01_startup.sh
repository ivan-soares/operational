#!/bin/bash
#

       today=$1
       ogcm=$2
       here=$3
       log=$4

       source $here/hindcast_setup.sh # will load dir names and other info

       #====================================================================================
       #cd $tmpdir; dr=`pwd`
       echo ; echo " ==> HERE I am for step 01: start forecast <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ==> starting forecast at $now" >> $log
       #====================================================================================

       sto=$stodir/$today
       #lgf=$logdir/$today

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
              rm -rf $tmpdir/*
       else
              echo " ... dir $tmpdir doesnt exist, will create it" 
              mkdir $tmpdir
       fi



################################ the end #######################################################

