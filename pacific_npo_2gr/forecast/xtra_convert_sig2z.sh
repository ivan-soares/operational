#!/bin/bash
#

	today='20210101'
	ndays=1

	yr=${today:0:4}
	mm=${today:4:2}
	dd=${today:6:2}

	here=`pwd`
	stodir="$here/d-storage"

	ogcm='glby'
	domainname="npo0.08_07e"

	mdate=$today
	nx=601
	ny=376
	nz=8

	if [ $ogcm == 'nemo' ]; then
           nz=50
	fi

################## *** convert outputs from sigma to z levels *** #############################################

	echo
	echo " +++ Starting code to convert ROMS output from sigma to z coord +++"
	echo

	inpfile="$stodir/$mdate/roms_his_${domainname}_${mdate}_${ogcm}.nc"

	echo " ... input file is $inpfile"

	depth_sig="$here/d-interp/depths_sig.nc"
	depth_z="$here/d-interp/depths_oper.nc"

	vars="zeta,u_eastward,v_northward,temp,salt"

	n1=0
	n2=23

	for d in $(seq 1 $ndays); do

	    #outfile="$stodir/$today/roms_zlevs_${domainname}_${mdate}_${ogcm}.nc"
	    outfile="roms_zlevs_${domainname}_${mdate}_${ogcm}.nc"
	    echo " ... doing file $outfile"

	    sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g" \
	        -e "s/NLON/$nx/g" -e "s/NLAT/$ny/g" -e "s/NDEP/$nz/g" \
                $here/d-interp/roms_YYYY-MM-DD_hrs.cdf >& cdf.cdf

            ncgen -k4 cdf.cdf -o $outfile
	    rm cdf.cdf

 
	    ddd=`printf "%3.3d" $d`
            tmpfile="roms_${ddd}.nc"
	    ncks -d ocean_time,$n1,$n2 $inpfile $tmpfile

	    cdo="cdo -s --no_warnings"
	    $cdo select,name=$vars $tmpfile tmp1.nc
	    $cdo  intlevelx3d,$depth_sig     tmp1.nc   $depth_z  tmp2.nc
	    ncrename -v u_eastward,u -v v_northward,v tmp2.nc

	    python $here/d-interp/write_roms_file.py tmp2.nc $outfile

	    mdate=`find_tomorrow.sh $yr $mm $dd`
	    yr=${mdate:0:4}
	    mm=${mdate:4:2}
	    dd=${mdate:6:2}

	    let n1=$n1+24
	    let n2=$n2+24

	    #rm tmp* $tmpfile

        done

	echo
	echo " +++ END of vertical interp from sigma to z coord "
	echo

##################################  *** the end *** ############################################################
#
