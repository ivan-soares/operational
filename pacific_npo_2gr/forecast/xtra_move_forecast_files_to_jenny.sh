#!/bin/bash
#

        echo
        echo " +++ Move FORECAST files to storage JENNY +++"
        echo

        set -o nounset
        set -o errexit
        set -o pipefail

        today=$1
        yr=${today:0:4}
        mm=${today:4:2}
        dd=${today:6:2}


####################### FILE NAMES

        here=$PWD
        ddir="$here/d-storage/$today"
        jenny="$HOME/storage-jenny/operational/${today}/forecast"
	jenny="d-trunk"

        wind="$ddir/gfs_${today}.nc"

        roms1="$ddir/roms_zlevs_jenny_npo0.08_07e_${today}_glby.nc"
        roms2="$ddir/roms_zlevs_jenny_npo0.0267_01c_${today}_glby.nc"

        ogcm1="$ddir/glby_zlevs_jenny_npo0.08_07e_${today}.nc"
        ogcm2="$ddir/nemo_zlevs_jenny_npo0.08_07e_${today}.nc"

        wave1="$ddir/ww3_his_npo0.33_${today}.nc"
        wave2="$ddir/noaa_ww3_npo0.25_${today}.nc"

        sat="$ddir/cmems_sla_vels_npo0.25_${today}.nc"
        mld="$ddir/mld_npo0.08_07e_${today}.nc"

        ####### files in the storage

        swind="$jenny/Wind_Models/gfs_${today}.nc"
        swave1="$jenny/Wave_Models/ww3_toc_${today}.nc"
        swave2="$jenny/Wave_Models/ww3_noaa_${today}.nc"

        sroms1="$jenny/Regional_Ocean_Models/roms+hycom_${today}_1.nc"
        sroms2="$jenny/Regional_Ocean_Models/roms+hycom_${today}_1.nc"

        sogcm1="$jenny/Regional_Ocean_Models/hycom_${today}.nc"
        sogcm2="$jenny/Regional_Ocean_Models/nemo_${today}.nc"

        smld="$jenny/Regional_Ocean_Models/mld+langmuir_${today}.nc"
        ssat="$jenny/Regional_Ocean_Models/sat_sla+vel_${today}.nc"


###################### LOOP TRHOUGH FILES

        names_in=($roms1 $roms2 $ogcm1 $ogcm2 $wave1 $wave2 $wind $mld $sat)
        names_out=($sroms1 $sroms2 $sogcm1 $sogcm2 $swave1 $swave2 $swind $smld $ssat)
        ndat=(24 24 4 4 24 24 8 4 0)

        for n in 0 1 2 3 4 5 6 7 8; do

                echo 
                echo " ==> doing file  ${names_in[n]}"
                echo

                if [ -e ${names_in[n]} ]; then
                        ntimes=`ncdump -h ${names_in[n]} | grep "UNLIMITED" | \
                        awk '{print $6}' | sed -e 's/(//g'`
                        echo " ... ntimes $ntimes, ndat ${ndat[n]}"; echo
                        if [ $ntimes -ge ${ndat[n]} ]; then

                                echo
                                echo " ... the files is OK, will move it to storage"
                                echo

                                cp ${names_in[n]} ${names_out[n]}; wait
                          
                        fi

                fi
                if [ -e hindcast.nc ]; then rm hindcast.nc; fi
        done

        echo
        echo " +++ END of Script +++"
        echo

### the end

