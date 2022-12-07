netcdf glby_brz0.08_20200721 {
dimensions:
	time = UNLIMITED ; // (5 currently)
	lon = NLON ;
	lat = NLAT ;
	depth = NDEP ;
variables:
	double time(time) ;
		time:standard_name = "time" ;
		time:long_name = "Forecast time for ForecastModelRunCollection" ;
		time:units = "seconds since YYYY-MM-DD 00:00:00.000 UTC" ;
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
		depth:_CoordinateAxisType = "Height" ;
		depth:_CoordinateZisPositive = "down" ;
	float zeta(time, lat, lon) ;
		zeta:standard_name = "sea_surface_elevation" ;
		zeta:long_name = "Water Surface Elevation" ;
		zeta:units = "m" ;
		zeta:_FillValue = -9999.f ;
		zeta:missing_value = -9999.f ;
		zeta:_CoordinateAxes = "time lat lon" ;
	float salt(time, depth, lat, lon) ;
		salt:standard_name = "sea_water_salt" ;
		salt:long_name = "Salinity" ;
		salt:units = "psu" ;
		salt:_FillValue = -9999.f ;
		salt:missing_value = -9999.f ;
		salt:_CoordinateAxes = "time depth lat lon" ;
	float temp(time, depth, lat, lon) ;
		temp:standard_name = "sea_temperature" ;
		temp:long_name = "Water Temperature" ;
		temp:units = "degC" ;
		temp:_FillValue = -9999.f ;
		temp:missing_value = -9999.f ;
		temp:_CoordinateAxes = "time depth lat lon" ;
	float u(time, depth, lat, lon) ;
		u:standard_name = "eastward_sea_velocity" ;
		u:long_name = "Eastward Water Velocity" ;
		u:units = "m/s" ;
		u:_FillValue = -9999.f ;
		u:missing_value = -9999.f ;
		u:_CoordinateAxes = "time depth lat lon" ;
	float v(time, depth, lat, lon) ;
		v:standard_name = "northward_sea_velocity" ;
		v:long_name = "Northward Water Velocity" ;
		v:units = "m/s" ;
		v:_FillValue = -9999.f ;
		v:missing_value = -9999.f ;
		v:_CoordinateAxes = "time depth lat lon" ;

// global attributes:
		:CDI = "Climate Data Interface version 1.9.9rc2 (https://mpimet.mpg.de/cdi)" ;
		:NCO = "netCDF Operators version 4.7.5 (Homepage = http://nco.sf.net, Code = http://github.com/nco/nco)" ;
		:CDO = "Climate Data Operators version 1.9.9rc2 (https://mpimet.mpg.de/cdo)" ;
}
