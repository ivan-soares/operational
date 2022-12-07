#!/bin/bash
#

	echo
	echo " +++ Starting  routine to convert ogcm files to z levels +++"
	echo

        n1=0
        let n2=${nhrs_roms}-1
        romsvars="zeta,u_eastward,v_northward,temp,salt"
        cdo="cdo -s --no_warnings"
	cdo2="$HOME/apps/cdo-1.9.7.1/bin/cdo -s --no_warnings"

        if [ "$imodel" == "roms1"  -o  "$imodel" == "all" ] ; then 

		################### interp ROMS grid 1

		echo ; echo " ==> doing ROMS file $outroms1" ; echo

		nx=`ncdump -h $depth_z1 | grep "lon ="   | awk '{print $3}'`
		ny=`ncdump -h $depth_z1 | grep "lat ="   | awk '{print $3}'`
		nz=`ncdump -h $depth_z1 | grep "level =" | awk '{print $3}'`

		echo " ... dimensions are : nx = $nx, ny = $ny, nz = $nz" ; echo

		sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g"\
		-e "s/NLON/$nx/g" -e "s/NLAT/$ny/g" -e "s/NDEP/$nz/g" \
		$here/d-interp/ogcm_jenny_YYYY-MM-DD_hrs.cdf >& cdf.cdf
		ncgen -k4 cdf.cdf -o $outroms1
		rm cdf.cdf

		echo " ... select vars"; echo

		rm -rf tmp*
		ncgen -k4 $here/d-interp/roms_selected_vars_npo0.08.cdf -o tmp2.nc
		python $here/d-interp/select_roms_vars.py $romsfile1 tmp2.nc; wait

		echo " ... interp vert."; echo

		#$cdo  intlevel3d,$depth_sig1     tmp2.nc   $depth_z1   tmp3.nc
		$cdo  intlevelx3d,$depth_sig1     tmp2.nc   $depth_z1   tmp3.nc; wait
		ncrename -v u_eastward,u -v v_northward,v   tmp3.nc; wait

		echo " ... rewrite vars"; echo

		python $here/d-interp/write_roms_file.py tmp3.nc $outroms1 3600.; wait
		mv tmp2.nc roms1_tmp2.nc
		mv tmp3.nc roms1_tmp3.nc
		#rm tmp* 
		
		echo; echo " ... extract z levels for JENNY and MLD"; echo

		ncks -h -d depth,0,7  $outroms1 $outroms1a; wait 
		ncks -h -d depth,5,21 -d time,12,,24 $outroms1 $outroms1b; wait

                mv $outroms1a $sto/.
                mv $outroms1b $sto/.
	fi 

        if [ "$imodel" == "roms2"  -o  "$imodel" == "all" ] ; then

		#################### interp ROMS grid 2

		echo ; echo " ==> doing ROMS file $outroms2" ; echo

		nx=`ncdump -h $depth_z2 | grep "lon ="   | awk '{print $3}'`
		ny=`ncdump -h $depth_z2 | grep "lat ="   | awk '{print $3}'`
		nz=`ncdump -h $depth_z2 | grep "level =" | awk '{print $3}'`

		echo " ... dimensions are : nx = $nx, ny = $ny, nz = $nz" ; echo

		sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g"\
		-e "s/NLON/$nx/g" -e "s/NLAT/$ny/g" -e "s/NDEP/$nz/g" \
		$here/d-interp/ogcm_jenny_YYYY-MM-DD_hrs.cdf >& cdf.cdf
		ncgen -k4 cdf.cdf -o $outroms2
		rm cdf.cdf

		echo " ... select vars"; echo

		rm -rf tmp*
		ncgen -k4 $here/d-interp/roms_selected_vars_npo0.0267.cdf -o tmp2.nc
		python $here/d-interp/select_roms_vars.py $romsfile2 tmp2.nc; wait


		echo " ... interp vert."; echo

		#$cdo  intlevel3d,$depth_sig1     tmp2.nc   $depth_z2   tmp3.nc
		$cdo  intlevelx3d,$depth_sig2     tmp2.nc   $depth_z2   tmp3.nc; wait
		ncrename -v u_eastward,u -v v_northward,v   tmp3.nc; wait

		echo " ... rewrite vars"; echo

		python $here/d-interp/write_roms_file.py tmp3.nc $outroms2 3600.; wait
		mv tmp2.nc roms2_tmp2.nc
		mv tmp3.nc roms2_tmp3.nc
		#rm tmp*

                echo; echo " ... extract z levels for JENNY and MLD"; echo

        	ncks -h -d depth,0,7  $outroms2 $outroms2a; wait
		ncks -h -d depth,5,21 -d time,12,,24 $outroms2 $outroms2b; wait

		mv $outroms2a $sto/.
		mv $outroms2b $sto/.
	fi

        if [ "$imodel" == "glby"  -o  "$imodel" == "all" ] ; then

		################### interp HYCOM GLBy

		echo ; echo " ==> doing OGCM file $outogcm1" ; echo

		nx=`ncdump -h $depth_z1 | grep "lon ="   | awk '{print $3}'`
		ny=`ncdump -h $depth_z1 | grep "lat ="   | awk '{print $3}'`
		nz=`ncdump -h $depth_z1 | grep "level =" | awk '{print $3}'`

		echo " ... dimensions are : nx = $nx, ny = $ny, nz = $nz" ; echo

		sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g"\
		-e "s/NLON/$nx/g" -e "s/NLAT/$ny/g" -e "s/NDEP/$nz/g" \
		$here/d-interp/ogcm_jenny_YYYY-MM-DD_hrs.cdf >& cdf.cdf
		ncgen -k4 cdf.cdf -o $outogcm1
		rm cdf.cdf

		echo " ... remap horiz."; echo

		rm -rf grid.nc weights.nc
		cp $here/d-interp/grid_r_${domain_roms}.nc  grid.nc
		$cdo genbil,grid.nc             $ogcmfile1  weights.nc
		$cdo remap,grid.nc,weights.nc   $ogcmfile1  tmp2.nc; wait
		
		rm weights.nc grid.nc

		echo " ... interp vert."; echo

		$cdo intlevel,$depths_mld         tmp2.nc tmp3.nc; wait
		#$cdo   intlevel3d,$depth_glby     tmp2.nc   $depth_z1  tmp3.nc; wait
		#$cdo  intlevelx3d,$depth_glby    tmp2.nc   $depth_z1  tmp3.nc; wait

		echo " ... rewrite vars"; echo

		ncrename -v water_u,u -v water_v,v -v water_temp,temp -v salinity,salt -v surf_el,zeta tmp3.nc
		python $here/d-interp/write_ogcm_file.py tmp3.nc $outogcm1 1.
		mv tmp2.nc glby_tmp2.nc
		mv tmp3.nc glby_tmp3.nc
		#rm tmp*

		echo; echo " ... extract z levels for JENNY and MLD"; echo
	
        	ncks -h -d depth,0,7  $outogcm1 $outogcm1a; wait
		ncks -h -d depth,5,21 -d time,2,,4 $outogcm1 $outogcm1b; wait

		mv $outogcm1a $sto/.
		mv $outogcm1b $sto/.
	fi

        if [ "$imodel" == "nemo"  -o  "$imodel" == "all" ] ; then

		################### interp NEMO

		echo ; echo " ==> doing OGCM file $outogcm2" ; echo

		nx=`ncdump -h $depth_z1 | grep "lon ="   | awk '{print $3}'`
		ny=`ncdump -h $depth_z1 | grep "lat ="   | awk '{print $3}'`
		nz=`ncdump -h $depth_z1 | grep "level =" | awk '{print $3}'`

		echo " ... dimensions are : nx = $nx, ny = $ny, nz = $nz" ; echo

		sed -e "s/YYYY-MM-DD/${yr}-${mm}-${dd}/g"\
		-e "s/NLON/$nx/g" -e "s/NLAT/$ny/g" -e "s/NDEP/$nz/g" \
		$here/d-interp/ogcm_jenny_YYYY-MM-DD_hrs.cdf >& cdf.cdf
		ncgen -k4 cdf.cdf -o $outogcm2
		rm cdf.cdf

		echo " ... remap horiz."; echo

		rm -rf grid.nc weights.nc
		cp $here/d-interp/grid_r_${domain_roms}.nc  grid.nc
		$cdo genbil,grid.nc             $ogcmfile2  weights.nc
		$cdo remap,grid.nc,weights.nc   $ogcmfile2  tmp2.nc; wait
		rm weights.nc grid.nc

		echo " ... interp vert."; echo

		$cdo intlevelx,$depths_mld         tmp2.nc tmp3.nc; wait
		#$cdo  intlevel3d,$depth_nemo     tmp2.nc   $depth_z1  tmp3.nc; wait
		#$cdo  intlevelx3d,$depth_ogcm    tmp2.nc   $depth_z1  tmp3.nc

		echo " ... rewrite vars"; echo

		ncrename -v uo,u -v vo,v -v so,salt -v zos,zeta -v thetao,temp tmp3.nc        
		python $here/d-interp/write_ogcm_file.py tmp3.nc $outogcm2 1.
		mv tmp2.nc nemo_tmp2.nc
                mv tmp3.nc nemo_tmp3.nc
		#rm tmp*

                echo; echo " ... extract z levels for JENNY and MLD"; echo

	        ncks -h -d depth,0,7  $outogcm2 $outogcm2a; wait
		ncks -h -d depth,5,21 -d time,1, $outogcm2 $outogcm2b; wait

		mv $outogcm2a $sto/.
		mv $outogcm2b $sto/.
	fi

        echo
        echo " +++ End of routine to convert ogcm files to z levels +++"
        echo

# the end
