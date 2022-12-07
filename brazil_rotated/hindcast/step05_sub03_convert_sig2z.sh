#!/bin/bash
#


################## *** convert outputs from sigma to z levels *** #############################################

	echo " ... interp ROMS output from sigma to z coord "

	inpfile="$stodir/$today/roms_his_${d}_${today}_${ogcm}.nc"
	outfile="$stodir/$today/roms_zlevs_${d}_${today}_${ogcm}.nc"

	#gridfile="$here/d-interp/glby2sig/gridfile_rho.txt"
	depth_sig="$here/d-interp/${ogcm}2sig/depths_sig.nc"
	depth_z="$here/d-interp/${ogcm}2sig/depths_z.nc"

	vars="zeta,u_eastward,v_northward,temp,salt"

	cdo="cdo -s -w"
	$cdo select,name=$vars $inpfile tmp1.nc
	$cdo  intlevel3d,$depth_z     tmp1.nc   $depth_sig  tmp2.nc
	ncrename -v u_eastward,u -v v_northward,v tmp2.nc

	sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g" \
	    -e "s/NLON/$nlon/g" \
	    -e "s/NLAT/$nlat/g" \
	    -e "s/NDEP/$ndep/g" \
	    $here/d-interp/sig2z/roms_YYYY-MM-DD_hrs.cdf >& cdf.cdf

	ncgen -k4 cdf.cdf -o $outfile
	python $here/d-interp/sig2z/write_roms_file.py tmp2.nc $outfile

	rm tmp* cdf.cdf


##################################  *** the end *** ############################################################
#
