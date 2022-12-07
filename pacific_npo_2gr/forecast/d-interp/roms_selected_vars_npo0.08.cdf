netcdf roms_his_npo0.08_07e_20210701_glby {
dimensions:
	lon = 601 ;
	lat = 376 ;
	s_rho = 30 ;
	time = UNLIMITED ; // (169 currently)
variables:
	double s_rho(s_rho) ;
		s_rho:long_name = "S-coordinate at RHO-points" ;
		s_rho:valid_min = -1. ;
		s_rho:valid_max = 0. ;
		s_rho:positive = "up" ;
		s_rho:standard_name = "ocean_s_coordinate_g2" ;
		s_rho:formula_terms = "s: s_rho C: Cs_r eta: zeta depth: h depth_c: hc" ;
		s_rho:field = "s_rho, scalar" ;
	double lon(lon) ;
		lon:long_name = "longitude of RHO-points" ;
		lon:units = "degree_east" ;
		lon:standard_name = "longitude" ;
		lon:field = "lon, scalar" ;
	double lat(lat) ;
		lat:long_name = "latitude of RHO-points" ;
		lat:units = "degree_north" ;
		lat:standard_name = "latitude" ;
		lat:field = "lat, scalar" ;
	double mask_rho(lat, lon) ;
		mask_rho:long_name = "mask on RHO-points" ;
		mask_rho:flag_values = 0., 1. ;
		mask_rho:flag_meanings = "land water" ;
		mask_rho:grid = "grid" ;
		mask_rho:location = "face" ;
		mask_rho:coordinates = "lon lat" ;
	double time(time) ;
		time:long_name = "time since initialization" ;
		time:units = "seconds since 2000-01-01 00:00:00" ;
		time:calendar = "proleptic_gregorian" ;
		time:field = "time, scalar, series" ;
	float zeta(time, lat, lon) ;
		zeta:long_name = "free-surface" ;
		zeta:units = "meter" ;
		zeta:time = "time" ;
		zeta:grid = "grid" ;
		zeta:location = "face" ;
		zeta:coordinates = "lon lat time" ;
		zeta:field = "free-surface, scalar, series" ;
		zeta:_FillValue = 1.e+37f ;
	float u_eastward(time, s_rho, lat, lon) ;
		u_eastward:long_name = "eastward momentum component at RHO-points" ;
		u_eastward:units = "meter second-1" ;
		u_eastward:time = "time" ;
		u_eastward:standard_name = "eastward_sea_water_velocity" ;
		u_eastward:grid = "grid" ;
		u_eastward:location = "face" ;
		u_eastward:coordinates = "lon lat s_rho time" ;
		u_eastward:field = "u_eastward, scalar, series" ;
		u_eastward:_FillValue = 1.e+37f ;
	float v_northward(time, s_rho, lat, lon) ;
		v_northward:long_name = "northward momentum component at RHO-points" ;
		v_northward:units = "meter second-1" ;
		v_northward:time = "time" ;
		v_northward:standard_name = "northward_sea_water_velocity" ;
		v_northward:grid = "grid" ;
		v_northward:location = "face" ;
		v_northward:coordinates = "lon lat s_rho time" ;
		v_northward:field = "v_northward, scalar, series" ;
		v_northward:_FillValue = 1.e+37f ;
	float temp(time, s_rho, lat, lon) ;
		temp:long_name = "potential temperature" ;
		temp:units = "Celsius" ;
		temp:time = "time" ;
		temp:grid = "grid" ;
		temp:location = "face" ;
		temp:coordinates = "lon lat s_rho time" ;
		temp:field = "temperature, scalar, series" ;
		temp:_FillValue = 1.e+37f ;
	float salt(time, s_rho, lat, lon) ;
		salt:long_name = "salinity" ;
		salt:time = "time" ;
		salt:grid = "grid" ;
		salt:location = "face" ;
		salt:coordinates = "lon lat s_rho time" ;
		salt:field = "salinity, scalar, series" ;
		salt:_FillValue = 1.e+37f ;
	float Uwind(time, lat, lon) ;
		Uwind:long_name = "surface u-wind component" ;
		Uwind:units = "meter second-1" ;
		Uwind:time = "time" ;
		Uwind:grid = "grid" ;
		Uwind:location = "face" ;
		Uwind:coordinates = "lon lat time" ;
		Uwind:field = "u-wind, scalar, series" ;
		Uwind:_FillValue = 1.e+37f ;
	float Vwind(time, lat, lon) ;
		Vwind:long_name = "surface v-wind component" ;
		Vwind:units = "meter second-1" ;
		Vwind:time = "time" ;
		Vwind:grid = "grid" ;
		Vwind:location = "face" ;
		Vwind:coordinates = "lon lat time" ;
		Vwind:field = "v-wind, scalar, series" ;
		Vwind:_FillValue = 1.e+37f ;

// global attributes:
		:file = "/home/brunosr/oper/pacific_npo_2gr/forecast/d-temporary/roms_out/roms_his_1.nc" ;
		:format = "netCDF-4/HDF5 file" ;
		:Conventions = "CF-1.4, SGRID-0.3" ;
}
