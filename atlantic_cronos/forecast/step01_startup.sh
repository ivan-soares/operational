#!/usr/bin/env bash
#

       #====================================================================================
       echo ; echo " ==> HERE I am for step 01: start forecast <=="; echo
       now=$(date "+%Y/%m/%d %T"); echo " ==> starting forecast at $now" >> $log
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

################################ the end #######################################################
