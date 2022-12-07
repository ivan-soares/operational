#!/usr/bin/env bash

     today=$1

     nlon=$2
     nlat=$3
     nsig=$4
     ndep=$5
     lon1=$6
     lat1=$7
     dlon=$8
     dlat=$9

     yr=${today:0:4}
     mm=${today:4:2}
     dd=${today:6:2}

     y1=${refday:0:4}
     m1=${refday:4:2}
     d1=${refday:6:2}

     ref_time="${yr}-${mm}-${dd} 00:00:00"

     npts=`echo $nlon $nlat | awk '{print $1*$2}'`

     echo
     echo " ==> STARTING BASH SCRIPT interp_aux01_make_files.sh <=="
     echo
     echo " ... will create an empty file for the date $yr/$mm/$dd"
     echo " ... the total n. of grid points is $npts"
     echo " ... lon1/lat1 = $lon1/$lat1"
     echo " ... dlon/dlat = $dlon/$dlat"
     echo " ... ref time  = $ref_time"
     echo


     echo ; echo " ... make file profs.nc"; echo
     rm -rf tmp profs.nc

     ### make file 'profs.nc' with roms depths in sgima levels

     echo "netcdf profs {"         >& tmp
     echo "dimensions:"            >> tmp
     echo "   lon = $nlon ;"       >> tmp
     echo "   lat = $nlat ;"       >> tmp
     echo "   sig = $nsig ;"       >> tmp
     echo "variables:"             >> tmp
     echo "   double lon(lon) ;"   >> tmp
     echo "           lon:standard_name = 'longitude' ;"  >> tmp
     echo "           lon:long_name = 'longitude' ;"      >> tmp
     echo "           lon:units = 'degrees_east' ;"       >> tmp
     echo "           lon:axis = 'X' ;"                   >> tmp
     echo "   double lat(lat) ;"                          >> tmp
     echo "           lat:standard_name = 'latitude' ;"   >> tmp
     echo "           lat:long_name = 'latitude' ;"       >> tmp
     echo "           lat:units = 'degrees_north' ;"      >> tmp
     echo "           lat:axis = 'Y' ;"                   >> tmp
     echo "   double sig(sig) ;"                          >> tmp
     echo "           sig:long_name = 'S-coordinate' ;"   >> tmp
     echo "           sig:valid_min = -1. ;"              >> tmp
     echo "           sig:valid_max = 0. ;"               >> tmp
     echo "           sig:units = '%' ;"                  >> tmp
     echo "           sig:axis = 'Z' ;"                   >> tmp
     echo "   float prof(sig, lat, lon) ;"                >> tmp
     echo "           prof:standard_name = 'depth' ;"     >> tmp
     echo "           prof:long_name = 'distance below surface' ;" >> tmp
     echo "           prof:units = 'meter' ;"             >> tmp
     echo "           prof:_FillValue = 1.e+37f ;"        >> tmp
     echo "           prof:missing_value = 1.e+37f ;"     >> tmp
     echo "                                         "     >> tmp
     echo "// global attributes:"                         >> tmp
     echo "        :history = 'ncgen -k4 *.cdf -o *.nc' ;" >> tmp
     echo "}"                                             >> tmp

     sed s/\'/\"/g tmp >& profs.cdf
     ncgen -k4 profs.cdf -o profs.nc
     rm profs.cdf tmp

     echo ; echo " ... make file depths.nc"; echo
     rm -rf tmp depths.nc

     ### make file depths.nc with standard depths

     echo "netcdf depths {"        >& tmp
     echo "dimensions:"            >> tmp
     echo "   lon = $nlon ;"       >> tmp
     echo "   lat = $nlat ;"       >> tmp
     echo "   dep = $ndep ;"       >> tmp
     echo "variables:"             >> tmp
     echo "   double lon(lon) ;"   >> tmp
     echo "           lon:standard_name = 'longitude' ;"   >> tmp
     echo "           lon:long_name = 'longitude' ;"       >> tmp
     echo "           lon:units = 'degrees_east' ;"        >> tmp
     echo "           lon:axis = 'X' ;"                    >> tmp
     echo "   double lat(lat) ;"                           >> tmp
     echo "           lat:standard_name = 'latitude' ;"    >> tmp
     echo "           lat:long_name = 'latitude' ;"        >> tmp
     echo "           lat:units = 'degrees_north' ;"       >> tmp
     echo "           lat:axis = 'Y' ;"                    >> tmp
     echo "   double dep(dep) ;"                           >> tmp
     echo "           dep:standard_name = 'depth' ;"       >> tmp
     echo "           dep:long_name = 'distance below surface' ;" >> tmp
     echo "           dep:units = 'meter' ;"               >> tmp
     echo "           dep:_FillValue = 1.e+37f ;"          >> tmp
     echo "           dep:missing_value = 1.e+37f ;"       >> tmp
     echo "   float depth(dep, lat, lon) ;"                >> tmp
     echo "           depth:standard_name = 'depth' ;"     >> tmp
     echo "           depth:long_name = 'distance below surface' ;" >> tmp
     echo "           depth:units = 'meter' ;"             >> tmp
     echo "           depth:_FillValue = 1.e+37f ;"        >> tmp
     echo "           depth:missing_value = 1.e+37f ;"     >> tmp
     echo "                                         "      >> tmp
     echo "// global attributes:"                          >> tmp
     echo "        :history = 'ncgen -k4 *.cdf -o *.nc' ;" >> tmp
     echo "}"                                              >> tmp

     sed s/\'/\"/g tmp >& depths.cdf
     ncgen -k4 depths.cdf -o depths.nc
     rm depths.cdf tmp

     ### make gridfile.txt

     echo "gridtype  = lonlat"          >& gridfile.txt
     echo "gridsize  = $npts"           >> gridfile.txt
     echo "xsize     = $nlon"           >> gridfile.txt
     echo "ysize     = $nlat"           >> gridfile.txt
     echo "xname     = lon"             >> gridfile.txt
     echo "xlongname = longitude"       >> gridfile.txt
     echo "xunits    = degrees_east"    >> gridfile.txt
     echo "yname     = lat"             >> gridfile.txt
     echo "ylongname = latitude"        >> gridfile.txt
     echo "yunits    = degrees_north"   >> gridfile.txt
     echo "xfirst    = $lon1"           >> gridfile.txt
     echo "xinc      = $dlon"           >> gridfile.txt
     echo "yfirst    = $lat1"           >> gridfile.txt
     echo "yinc      = $dlat"           >> gridfile.txt


################################ end of script ##################################### 
