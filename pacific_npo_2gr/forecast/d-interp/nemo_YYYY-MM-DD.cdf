netcdf nemo_20210627-120000Z {
dimensions:
	time =  UNLIMITED ; // (4 currently);
	depth = 50 ;
	latitude = NLAT ;
	longitude = NLON ;
variables:
	float depth(depth) ;
		depth:valid_min = 0.494025f ;
		depth:valid_max = 5727.917f ;
		depth:units = "m" ;
		depth:positive = "down" ;
		depth:unit_long = "Meters" ;
		depth:long_name = "Depth" ;
		depth:standard_name = "depth" ;
		depth:axis = "Z" ;
		depth:_CoordinateAxisType = "Height" ;
		depth:_CoordinateZisPositive = "down" ;
	float latitude(latitude) ;
		latitude:valid_min = -29.f ;
		latitude:valid_max = -22.f ;
		latitude:step = 0.08333588f ;
		latitude:units = "degrees_north" ;
		latitude:unit_long = "Degrees North" ;
		latitude:long_name = "Latitude" ;
		latitude:standard_name = "latitude" ;
		latitude:axis = "Y" ;
		latitude:_CoordinateAxisType = "Lat" ;
	short vo(time, depth, latitude, longitude) ;
		vo:long_name = "Northward velocity" ;
		vo:standard_name = "northward_sea_water_velocity" ;
		vo:units = "m s-1" ;
		vo:unit_long = "Meters per second" ;
		vo:_FillValue = -32767s ;
		vo:add_offset = 0. ;
		vo:scale_factor = 0.000610370188951492 ;
		vo:cell_methods = "area: mean" ;
	short thetao(time, depth, latitude, longitude) ;
		thetao:long_name = "Temperature" ;
		thetao:standard_name = "sea_water_potential_temperature" ;
		thetao:units = "degrees_C" ;
		thetao:unit_long = "Degrees Celsius" ;
		thetao:_FillValue = -32767s ;
		thetao:add_offset = 21. ;
		thetao:scale_factor = 0.000732444226741791 ;
		thetao:cell_methods = "area: mean" ;
	short uo(time, depth, latitude, longitude) ;
		uo:long_name = "Eastward velocity" ;
		uo:standard_name = "eastward_sea_water_velocity" ;
		uo:units = "m s-1" ;
		uo:unit_long = "Meters per second" ;
		uo:_FillValue = -32767s ;
		uo:add_offset = 0. ;
		uo:scale_factor = 0.000610370188951492 ;
		uo:cell_methods = "area: mean" ;
	float time(time) ;
		time:long_name = "Time (hours since 1950-01-01)" ;
		time:standard_name = "time" ;
		time:calendar = "gregorian" ;
		time:units = "hours since 1950-01-01 00:00:00" ;
		time:axis = "T" ;
		time:_CoordinateAxisType = "Time" ;
		time:valid_min = 626652.f ;
		time:valid_max = 626652.f ;
	short so(time, depth, latitude, longitude) ;
		so:long_name = "Salinity" ;
		so:standard_name = "sea_water_salinity" ;
		so:units = "1e-3" ;
		so:unit_long = "Practical Salinity Unit" ;
		so:_FillValue = -32767s ;
		so:add_offset = -0.00152592547237873 ;
		so:scale_factor = 0.00152592547237873 ;
		so:cell_methods = "area: mean" ;
	float longitude(longitude) ;
		longitude:valid_min = -49.f ;
		longitude:valid_max = -39.f ;
		longitude:step = 0.08332825f ;
		longitude:units = "degrees_east" ;
		longitude:unit_long = "Degrees East" ;
		longitude:long_name = "Longitude" ;
		longitude:standard_name = "longitude" ;
		longitude:axis = "X" ;
		longitude:_CoordinateAxisType = "Lon" ;
	short zos(time, latitude, longitude) ;
		zos:long_name = "Sea surface height" ;
		zos:standard_name = "sea_surface_height_above_geoid" ;
		zos:units = "m" ;
		zos:unit_long = "Meters" ;
		zos:add_offset = 0. ;
		zos:scale_factor = 0.000305185094475746 ;
		zos:_FillValue = -32767s ;
		zos:cell_methods = "area: mean" ;

// global attributes:
		:title = "daily mean fields from Global Ocean Physics Analysis and Forecast updated Daily" ;
		:easting = "longitude" ;
		:northing = "latitude" ;
		:history = "2021/06/28 00:07:44 MERCATOR OCEAN Netcdf creation" ;
		:source = "MERCATOR PSY4QV3R1" ;
		:institution = "MERCATOR OCEAN" ;
		:references = "http://www.mercator-ocean.fr" ;
		:comment = "CMEMS product" ;
		:Conventions = "CF-1.4" ;
		:domain_name = "GL12" ;
		:FROM_ORIGINAL_FILE__field_type = "mean" ;
		:field_date = "2021-07-07 00:00:00" ;
		:field_julian_date = 26120.f ;
		:julian_day_unit = "days since 1950-01-01 00:00:00" ;
		:forecast_range = "9-day_forecast" ;
		:forecast_type = "forecast" ;
		:bulletin_date = "2021-06-28 00:00:00" ;
		:bulletin_type = "operational" ;
		:FROM_ORIGINAL_FILE__longitude_min = -180.f ;
		:FROM_ORIGINAL_FILE__longitude_max = 179.9167f ;
		:FROM_ORIGINAL_FILE__latitude_min = -80.f ;
		:FROM_ORIGINAL_FILE__latitude_max = 90.f ;
		:z_min = 0.494025f ;
		:z_max = 5727.917f ;
		:_CoordSysBuilder = "ucar.nc2.dataset.conv.CF1Convention" ;
}
