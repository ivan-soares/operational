netcdf glby_brz0.08_20200721 {
dimensions:
	time = UNLIMITED ; // (5 currently)
	lon = NLON ;
	lat = NLAT ;
	depth = NDEP ;
variables:
	double time(time) ;
		time:standard_name = "time" ;
		time:long_name = "Forecast time" ;
		time:units = "hours since YYYY-MM-DD 00:00:00.000 UTC" ;
		time:calendar = "proleptic_gregorian" ;
		time:axis = "T" ;
	double lon(lon) ;
		lon:standard_name = "longitude" ;
		lon:long_name = "Longitude eastward" ;
		lon:units = "degrees_east" ;
		lon:axis = "X" ;
	double lat(lat) ;
		lat:standard_name = "latitude" ;
		lat:long_name = "Latitude northward" ;
		lat:units = "degrees_north" ;
		lat:axis = "Y" ;
	double depth(depth) ;
		depth:standard_name = "depth" ;
		depth:long_name = "Depth from surface" ;
		depth:units = "m" ;
		depth:positive = "down" ;
		depth:axis = "Z" ;
        float mld_roms(time, lat, lon) ;
                mld_roms:long_name = "depth of thermocline below 10 m" ;
                mld_roms:units = "meter" ;
                mld_roms:coordinates = "time lat lon" ;
                mld_roms:_FillValue = 1.e+37f ;
                mld_roms:missing_value = 1.e+37f ;
        float mld_hycom(time, lat, lon) ;
                mld_hycom:long_name = "depth of thermocline below 10 m" ;
                mld_hycom:units = "meter" ;
                mld_hycom:coordinates = "time lat lon" ;
                mld_hycom:_FillValue = 1.e+37f ;
                mld_hycom:missing_value = 1.e+37f ;
        float mld_nemo(time, lat, lon) ;
                mld_nemo:long_name = "depth of thermocline below 10 m" ;
                mld_nemo:units = "meter" ;
                mld_nemo:coordinates = "time lat lon" ;
                mld_nemo:_FillValue = 1.e+37f ;
                mld_nemo:missing_value = 1.e+37f ;
        float langmuir(time, lat, lon) ;
                langmuir:long_name = "Langmuir" ;
                langmuir:units = "non dimensional" ;
                langmuir:coordinates = "time lat lon" ;
                langmuir:_FillValue = 1.e+37f ;
			langmuir:missing_value = 1.e+37f ;
// global attributes:
		:CDI = "Climate Data Interface version 1.9.9rc2 (https://mpimet.mpg.de/cdi)" ;
		:NCO = "netCDF Operators version 4.7.5 (Homepage = http://nco.sf.net, Code = http://github.com/nco/nco)" ;
		:CDO = "Climate Data Operators version 1.9.9rc2 (https://mpimet.mpg.de/cdo)" ;
}
