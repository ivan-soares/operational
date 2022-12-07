netcdf glby_brz0.08_20200721 {
dimensions:
	time = UNLIMITED ; // (5 currently)
	lon = 364 ;
	lat = 1051 ;
	depth = 40 ;
variables:
	double time(time) ;
		time:standard_name = "time" ;
		time:long_name = "Forecast time for ForecastModelRunCollection" ;
		time:units = "hours since 2020-07-16 12:00:00.000 UTC" ;
		time:calendar = "proleptic_gregorian" ;
		time:axis = "T" ;
	double lon(lon) ;
		lon:standard_name = "longitude" ;
		lon:long_name = "Longitude" ;
		lon:units = "degrees_east" ;
		lon:axis = "X" ;
	double lat(lat) ;
		lat:standard_name = "latitude" ;
		lat:long_name = "Latitude" ;
		lat:units = "degrees_north" ;
		lat:axis = "Y" ;
	double depth(depth) ;
		depth:standard_name = "depth" ;
		depth:long_name = "Depth" ;
		depth:units = "m" ;
		depth:positive = "down" ;
		depth:axis = "Z" ;
		depth:NAVO_code = 5 ;
		depth:_CoordinateAxisType = "Height" ;
		depth:_CoordinateZisPositive = "down" ;
	float surf_el(time, lat, lon) ;
		surf_el:standard_name = "sea_surface_elevation" ;
		surf_el:long_name = "Water Surface Elevation" ;
		surf_el:units = "m" ;
		surf_el:_FillValue = -9999.f ;
		surf_el:missing_value = -9999.f ;
		surf_el:_CoordinateAxes = "time_run time lat lon" ;
		surf_el:NAVO_code = 32 ;
	float salinity(time, depth, lat, lon) ;
		salinity:standard_name = "sea_water_salinity" ;
		salinity:long_name = "Salinity" ;
		salinity:units = "psu" ;
		salinity:_FillValue = -9999.f ;
		salinity:missing_value = -9999.f ;
		salinity:_CoordinateAxes = "time_run time depth lat lon" ;
		salinity:NAVO_code = 16 ;
	float water_temp(time, depth, lat, lon) ;
		water_temp:standard_name = "sea_water_temperature" ;
		water_temp:long_name = "Water Temperature" ;
		water_temp:units = "degC" ;
		water_temp:_FillValue = -9999.f ;
		water_temp:missing_value = -9999.f ;
		water_temp:_CoordinateAxes = "time_run time depth lat lon" ;
		water_temp:NAVO_code = 15 ;
		water_temp:comment = "in-situ temperature" ;
	float water_u(time, depth, lat, lon) ;
		water_u:standard_name = "eastward_sea_water_velocity" ;
		water_u:long_name = "Eastward Water Velocity" ;
		water_u:units = "m/s" ;
		water_u:_FillValue = -9999.f ;
		water_u:missing_value = -9999.f ;
		water_u:_CoordinateAxes = "time_run time depth lat lon" ;
		water_u:NAVO_code = 17 ;
	float water_v(time, depth, lat, lon) ;
		water_v:standard_name = "northward_sea_water_velocity" ;
		water_v:long_name = "Northward Water Velocity" ;
		water_v:units = "m/s" ;
		water_v:_FillValue = -9999.f ;
		water_v:missing_value = -9999.f ;
		water_v:_CoordinateAxes = "time_run time depth lat lon" ;
		water_v:NAVO_code = 18 ;

// global attributes:
		:CDI = "Climate Data Interface version 1.9.9rc2 (https://mpimet.mpg.de/cdi)" ;
		:source = "HYCOM archive file" ;
		:institution = "Fleet Numerical Meteorology and Oceanography Center" ;
		:Conventions = "CF-1.4, NAVO_netcdf_v1.1" ;
		:classification_level = "UNCLASSIFIED" ;
		:distribution_statement = "Approved for public release. Distribution unlimited." ;
		:downgrade_date = "not applicable" ;
		:classification_authority = "not applicable" ;
		:history = "Wed Jul 22 19:04:51 2020: cdo -setmissval,-9999. tmp2 glby_brz0.08_20200721.nc\nWed Jul 22 19:04:29 2020: cdo -setmissval,NaN tmp1 tmp2\nWed Jul 22 19:04:10 2020: cdo -s -w mergetime glby_20200721.nc glby_20200722.nc tmp1\nWed Jul 22 19:03:07 2020: cdo -s -w mergetime glby_20200721-000000Z.nc glby_20200721-060000Z.nc glby_20200721-120000Z.nc glby_20200721-180000Z.nc glby_20200721.nc\nWed Jul 22 19:00:33 2020: ncap2 -O -s where(lon>180) lon=lon-360 tmp.nc glby_20200721-000000Z.nc\narchv2ncdf2d ;\nFMRC Best Dataset" ;
		:comment = "p-grid" ;
		:field_type = "instantaneous" ;
		:cdm_data_type = "GRID" ;
		:featureType = "GRID" ;
		:location = "Proto fmrc:GLBy0.08_930_FMRC" ;
		:History = "Translated to CF-1.0 Conventions by Netcdf-Java CDM (CFGridWriter2)\nOriginal Dataset = GLBy0.08/latest; Translation Date = 2020-07-22T18:59:54.310Z" ;
		:geospatial_lat_min = -31. ;
		:geospatial_lat_max = 11. ;
		:geospatial_lon_min = -53.0400390625 ;
		:geospatial_lon_max = -24. ;
		:NCO = "netCDF Operators version 4.7.5 (Homepage = http://nco.sf.net, Code = http://github.com/nco/nco)" ;
		:nco_openmp_thread_number = 1 ;
		:CDO = "Climate Data Operators version 1.9.9rc2 (https://mpimet.mpg.de/cdo)" ;
}