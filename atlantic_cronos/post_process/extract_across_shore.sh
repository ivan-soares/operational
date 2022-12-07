#!/bin/bash
#
	# yesterday=$1
	ndays=$1
    # ogcm=$3

	echo
	echo " +++ Starting script to extract a cross shelf snapshot +++"
	echo

	# mdate=$yesterday
	yr=${yesterday:0:4}
	mm=${yesterday:4:2}
	dd=${yesterday:6:2}

	# ddir="$__dir/d-storage"

	nn=1
	domainname="_${domain_roms}_01g_"
    # ROMS simulations transects converted to Zlevs
	while [ $nn -le $ndays ]; do

		ogcmfile="$tmpdir/roms_zlevs${domainname}${yesterday}_${ogcm}.nc"


        echo 
		echo " ... working on file $ogcmfile"
        echo

		
        ncks -d lat,460 -d lon,344,400 $ogcmfile roms_${ogcm}_${yesterday}_across-shelf_07S.nc
        ncks -d lat,380 -d lon,298,380 $ogcmfile roms_${ogcm}_${yesterday}_across-shelf_11S.nc
		ncks -d lat,160 -d lon,218,331 $ogcmfile roms_${ogcm}_${yesterday}_across-shelf_22S.nc
		ncks -d lat,145 -d lon,197,331 $ogcmfile roms_${ogcm}_${yesterday}_across-shelf_23S.nc
		ncks -d lat,100 -d lon,66,331  $ogcmfile roms_${ogcm}_${yesterday}_across-shelf_25S.nc
		ncks -d lat,40  -d lon,62,331  $ogcmfile roms_${ogcm}_${yesterday}_across-shelf_28S.nc

		mdate=$(date +%Y%m%d -d "$yesterday + $nn day")
		yr=${mdate:0:4}
		mm=${mdate:4:2}
		dd=${mdate:6:2}

		let nn=$nn+1

    done

        
        
	for lati in 07S 11S 22S 23S 25S 28S; do
		ncrcat -h roms_${ogcm}_*_across-shelf_${lati}.nc tmp1.nc
		cdo -s --no_warning timavg tmp1.nc across-shelf_${lati}_${yesterday}_roms+${ogcm}.nc
		rm roms_${ogcm}_*_across-shelf_${lati}.nc tmp1.nc 
	done


    # Boundary conditions from OGCM
	ogcmfile="$stodir/$yesterday/${ogcm}_${domain_ogcm}_${yesterday}.nc"

    echo 
    echo " ... working on file ${ogcm}_${domain_ogcm}_${yesterday}.nc"
    echo

    # NEMO
    if [ $ogcm = "nemo" ]; then
        ncks -d latitude,288 -d longitude,142,250  $ogcmfile nemo_${yesterday}_across-shelf_07S.nc
        ncks -d latitude,240 -d longitude,142,250  $ogcmfile nemo_${yesterday}_across-shelf_11S.nc
        ncks -d latitude,108 -d longitude,142,200  $ogcmfile nemo_${yesterday}_across-shelf_22S.nc
        ncks -d latitude,99  -d longitude,131,200  $ogcmfile nemo_${yesterday}_across-shelf_23S.nc
        ncks -d latitude,72  -d longitude,59,200   $ogcmfile nemo_${yesterday}_across-shelf_25S.nc
        ncks -d latitude,36  -d longitude,49,200   $ogcmfile nemo_${yesterday}_across-shelf_28S.nc
    fi
    
    # GLBY
    if [ $ogcm = "glby" ]; then
        ncks -d lat,600 -d lon,146,250  $ogcmfile glby_${yesterday}_across-shelf_07S.nc
        ncks -d lat,500 -d lon,146,250  $ogcmfile glby_${yesterday}_across-shelf_11S.nc
        ncks -d lat,225 -d lon,146,225  $ogcmfile glby_${yesterday}_across-shelf_22S.nc
        ncks -d lat,206 -d lon,136,225  $ogcmfile glby_${yesterday}_across-shelf_23S.nc
        ncks -d lat,150 -d lon,56,225   $ogcmfile glby_${yesterday}_across-shelf_25S.nc
        ncks -d lat,75  -d lon,51,225   $ogcmfile glby_${yesterday}_across-shelf_28S.nc
    fi

	for lati in 07S 11S 22S 23S 25S 28S; do
		cdo -s --no_warning timavg ${ogcm}_${yesterday}_across-shelf_${lati}.nc across-shelf_${lati}_${yesterday}_${ogcm}.nc
		rm ${ogcm}_${yesterday}_across-shelf_${lati}.nc
	done

#
#   the end
#
