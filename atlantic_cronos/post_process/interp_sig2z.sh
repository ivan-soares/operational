#!/bin/bash
#

#    script to interpolate ROMS data
#     from sigma to z levels
#
#    reftime is the reference time, e.g. 20000101 for 01/01/2001
#    initime is the name of directory where the roms output file is, e.g. 20080101 for 01/01/2008
#    today is the first day you want to convert, e.g. 20080115 for 15/01/2008

     today=$1
     iniday=$today
     refday='20000101'

     ndays=7

     region="brz"
     domain="brz0.05"
     version="01d"

     iopt=1

     yr=${today:0:4}
     mm=${today:4:2}
     dd=${today:6:2}

     echo
     echo " ==> STARTING BASH script to interp ROMS from sigma to z coord <=="
     echo
     echo " ... starting date is $today"
     echo " ... will run for $ndays days"
     echo

     # wesn not needed here, remapbil will do the cut

     #W=$2   # not being used
     #E=$3   # not being used
     #S=$4   # not being used
     #N=$5   # not being used

     # choose the roms file to convert

     inpfile="roms_${domain}_${version}_${iniday}_his.nc"

     echo " ... ROMS file to be interpolated is :"
     echo "     $inpfile"; echo

     if [ $iopt == 1 ]; then

        # interp ROMS grid to uniforme grid
        echo " ... interpolate ROMS grid file to uniforme grid type A"; echo
        interp_aux01_make_files.sh $today whatever 4 $inpfile whatever

        # create files profs.nc & depths.nc
        echo " ... create empty files profs.nc & depths.nc"; echo
        interp_aux01_make_files.sh $today whatever 1 whatever whatever
        interp_aux01_make_files.sh $today whatever 2 whatever whatever

        # write values on newly created files
        echo " ... write standard depths on file depths.nc and roms depths on profs.nc"; echo
        interp_aux02_write_values.py

     fi


     vars="u_eastward,v_northward"

     for (( n=1; n <=$ndays; n+=1 )); do

         echo
         echo " ===> START CDO interpolations"; echo
         echo " .... today is $today or ${yr}/${mm}/${dd}"; echo
         echo $today >& today

         outfile="${domain}_${today}_z.nc"
         # create an empty file $outfile for outputing interpolated value
         interp_aux01_make_files.sh $today $refday 3 $inpfile $outfile

         cdo -select,date=${yr}-${mm}-${dd},name=$vars       $inpfile  tmp1
         cdo remapbil,gridfile.txt                           tmp1  tmp2
         cdo intlevel3d,depths.nc tmp2       profs.nc           tmp3
         mv                                                      tmp3  tmp4

         echo; echo " ... write interpolated values on file $outfile"; echo
         interp_aux03_rewrite_values.py #reads from tmp4, writes on $outfile
         rm tmp* today

         today=`find_tomorrow.sh $yr $mm $dd`

         yr=${today:0:4}
         mm=${today:4:2}
         dd=${today:6:2}

     done

#    the end
