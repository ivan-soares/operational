#!/bin/bash
#
       #### S10

       today=$1
       ogcm=$2
       here=$3
       log=$4

       yr=${today:0:4}
       mm=${today:4:2}
       dd=${today:6:2}

       source $here/forecast_setup.sh # will load dir names and other info

       #====================================================================================
       echo >> $log; cd $report; dr=`pwd`; now=$(date "+%Y/%m/%d %T")
       echo " ... starting script to make report of forecast at $now" >> $log
       echo ; echo " ==> $now HERE I am @ $dr for step 10: make report <=="; echo
       #====================================================================================

       sto="$stodir/$today"
       txt="$report/$today"

       echo
       echo " ... today is ${yr}-${mm}-${dd}"
       echo
       echo " ... will make a report and store at $txt"
       echo

       if [ -e $txt ]; then
             echo " ... dir $txt exists, will use it"
       else
             echo " ... dir $txt doesnt exist, will create it"
             mkdir $txt
       fi

       cd $txt

       echo " ... HERE we are at $txt to make report pictures"

       ####### will use roms and satellite velocities
       ####### don't forget that multiobs has the dimension 'depth' and sla vels doesn't

       romsfile="$sto/roms_his_${domain_roms}_${version}_${today}_${ogcm}.nc"
       ogcmfile="$sto/${ogcm}_npo0.08_${today}.nc"
       sat1file="$sto/sla_allsat_npo0.25_${today}.nc"
     
       out1="roms_${today}.nc"
       out2="sat1_${today}.nc"
       out3="ogcm_${today}.nc"

       ### boundary box:
       ###  -45.150 (137)   -35.150 (337)
       ###  -26.500 (70)    -19.25  (215)

       lo1='-45.15'; i1=137
       lo2='-35.15'; i2=337
       la1='-26.50'; j1=70
       la2='-19.25'; j2=215
       
       wesn_bcampos="$lo1 $lo2 $la1 $la2"

       ### the next will create files out1 out2 out3

       rm -rf $out1 $out2 $out3
       source $here/step10_sub02_extract_data.sh 

       ##### sub routine step10_sub01 will read the files above & make pictures:
       #####     vels_roms_today.png, vels_sat1_today.png, vels_ogcm_today.png
       ##### will use a file named coastline.mat

       rm -rf coastline.mat
       ln -s $report/costa_sse.mat coastline.mat
       python $here/step10_sub03_surface_maps.py $out1 $out2 $out3 $today $ogcm \
              $troms $togcm $wesn_bcampos
       
       mv vels_roms_${today}.png bcampos_surf_vel_roms+${ogcm}_${today}.png
       mv vels_sat1_${today}.png bcampos_geostr_vel_sat1_${today}.png
       mv vels_ogcm_${today}.png bcampos_surf_vel_${ogcm}_${today}.png

       mv vels_roms_${today}_02.png bcampos_surf_vel_roms+${ogcm}_${today}_02.png


       rm -rf $out1 $out2 $out3

       #====================================================================================
       echo ; now=$(date "+%Y/%m/%d %T"); echo >> $log
       echo " ... ... finished report at $now" >> $log; echo >> $log
       echo " ==> $now FINISHED report <=="; echo
       #====================================================================================

       cd $here

#### the end
