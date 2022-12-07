#!/bin/bash
#

	ndays=1

	yr=${yesterday:0:4}
	mm=${yesterday:4:2}
	dd=${yesterday:6:2}

	domainname="${domain_roms}_01g"



################## *** convert outputs from sigma to z levels *** #############################################

	echo
	echo " +++ Starting code to convert ROMS output from sigma to z coord +++"
	echo

	inpfile="$sto/roms_his_${domainname}_${yesterday}_${ogcm}.nc"

	echo " ... input file is $inpfile"

	depth_sig="$__dir/d-interp/glby2sig/depths_sig_rho.nc"
	depth_z="$__dir/d-interp/glby2sig/depths_z_rho.nc"

	vars="zeta,u_eastward,v_northward,temp,salt"

	n1=0
	n2=23

	for d in $(seq 1 $ndays); do

 	    outfile="roms_zlevs_${domainname}_${yesterday}_${ogcm}.nc"
	   
	    echo " ... doing file $outfile"

	    sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g" ${__dir}/d-interp/sig2z/roms_YYYY-MM-DD_hrs.cdf >& cdf.cdf
		ncgen -k4 cdf.cdf -o $outfile
	    rm cdf.cdf

        tmpfile="roms_${dd}.nc"
	    ncks -d ocean_time,$n1,$n2 $inpfile $tmpfile

        echo " ... interpolating, it will take a while..."
	    cdo="cdo -s -w"
	    $cdo select,name=$vars $tmpfile tmp1.nc
	    $cdo  intlevel3d,$depth_z     tmp1.nc   $depth_sig  tmp2.nc
#         $cdo  intlevelx3d,$depth_z     tmp1.nc   $depth_sig  tmp2.nc        
	    
        ncrename -v u_eastward,u -v v_northward,v tmp2.nc

		# Running PYTHON script to generate nc file with z coord.
	    python $__dir/d-interp/sig2z/write_roms_file.py tmp2.nc $outfile

		if [ $d -lt $ndays ]; then
			mdate=$(date +%Y%m%d -d "$yesterday + $d day")
			echo " ... next day is $mdate"
			
			yr=${mdate:0:4}
			mm=${mdate:4:2}
			dd=${mdate:6:2}

			let n1=$n1+24
			let n2=$n2+24
		fi

	    rm tmp* $tmpfile

    done

	echo
	echo " +++ END of vertical interp from sigma to z coord "
	echo

##################################  *** the end *** #####################################

