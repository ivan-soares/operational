netcdf nemo_brz0.08_20200721 {
dimensions:
	time = UNLIMITED ; // (3 currently)
	longitude = 349 ;
	latitude = 505 ;
	depth = 50 ;
variables:
	double time(time) ;
		time:standard_name = "time" ;
		time:long_name = "Time (hours since 1950-01-01)" ;
		time:units = "hours since 1950-01-01 00:00:00" ;
		time:calendar = "gregorian" ;
		time:axis = "T" ;
	float longitude(longitude) ;
		longitude:standard_name = "longitude" ;
		longitude:long_name = "Longitude" ;
		longitude:units = "degrees_east" ;
		longitude:axis = "X" ;
	float latitude(latitude) ;
		latitude:standard_name = "latitude" ;
		latitude:long_name = "Latitude" ;
		latitude:units = "degrees_north" ;
		latitude:axis = "Y" ;
	float depth(depth) ;
		depth:standard_name = "depth" ;
		depth:long_name = "Depth" ;
		depth:units = "m" ;
		depth:positive = "down" ;
		depth:axis = "Z" ;
		depth:unit_long = "Meters" ;
		depth:_CoordinateAxisType = "Height" ;
		depth:_CoordinateZisPositive = "down" ;
	short vo(time, depth, latitude, longitude) ;
		vo:standard_name = "northward_sea_water_velocity" ;
		vo:long_name = "Northward velocity" ;
		vo:units = "m s-1" ;
		vo:add_offset = 0.f ;
		vo:scale_factor = 0.0006103702f ;
		vo:_FillValue = -9999s ;
		vo:missing_value = -9999s ;
		vo:unit_long = "Meters per second" ;
		vo:cell_methods = "area: mean" ;
	short thetao(time, depth, latitude, longitude) ;
		thetao:standard_name = "sea_water_potential_temperature" ;
		thetao:long_name = "Temperature" ;
		thetao:units = "degrees_C" ;
		thetao:add_offset = 21.f ;
		thetao:scale_factor = 0.0007324442f ;
		thetao:_FillValue = -9999s ;
		thetao:missing_value = -9999s ;
		thetao:unit_long = "Degrees Celsius" ;
		thetao:cell_methods = "area: mean" ;
	short uo(time, depth, latitude, longitude) ;
		uo:standard_name = "eastward_sea_water_velocity" ;
		uo:long_name = "Eastward velocity" ;
		uo:units = "m s-1" ;
		uo:add_offset = 0.f ;
		uo:scale_factor = 0.0006103702f ;
		uo:_FillValue = -9999s ;
		uo:missing_value = -9999s ;
		uo:unit_long = "Meters per second" ;
		uo:cell_methods = "area: mean" ;
	short so(time, depth, latitude, longitude) ;
		so:standard_name = "sea_water_salinity" ;
		so:long_name = "Salinity" ;
		so:units = "1e-3" ;
		so:add_offset = -0.001525925f ;
		so:scale_factor = 0.001525925f ;
		so:_FillValue = -9999s ;
		so:missing_value = -9999s ;
		so:unit_long = "Practical Salinity Unit" ;
		so:cell_methods = "area: mean" ;
	short zos(time, latitude, longitude) ;
		zos:standard_name = "sea_surface_height_above_geoid" ;
		zos:long_name = "Sea surface height" ;
		zos:units = "m" ;
		zos:add_offset = 0.f ;
		zos:scale_factor = 0.0003051851f ;
		zos:_FillValue = -9999s ;
		zos:missing_value = -9999s ;
		zos:unit_long = "Meters" ;
		zos:cell_methods = "area: mean" ;

// global attributes:
		:CDI = "Climate Data Interface version 1.9.9rc2 (https://mpimet.mpg.de/cdi)" ;
		:Conventions = "CF-1.4" ;
		:source = "MERCATOR PSY4QV3R1" ;
		:institution = "MERCATOR OCEAN" ;
		:title = "daily mean fields from Global Ocean Physics Analysis and Forecast updated Daily" ;
		:easting = "longitude" ;
		:northing = "latitude" ;
		:history = "Wed Jul 22 16:08:35 2020: cdo -setmissval,-9999. tmp2 nemo_brz0.08_20200721.nc\n",
			"Wed Jul 22 16:08:29 2020: cdo -setmissval,NaN tmp1 tmp2\n",
			"Wed Jul 22 16:08:23 2020: cdo -s -w mergetime nemo_20200721-000000Z.nc nemo_20200721-120000Z.nc nemo_20200722-120000Z.nc tmp1\n",
			"Wed Jul 22 16:08:20 2020: cdo -s -w ensmean nemo_20200720-120000Z.nc nemo_20200721-120000Z.nc tmp1\n",
			"2020/07/22 01:30:19 MERCATOR OCEAN Netcdf creation" ;
		:references = "http://www.mercator-ocean.fr" ;
		:comment = "CMEMS product" ;
		:domain_name = "GL12" ;
		:FROM_ORIGINAL_FILE__field_type = "mean" ;
		:field_date = "2020-07-31 00:00:00" ;
		:field_julian_date = 25779.f ;
		:julian_day_unit = "days since 1950-01-01 00:00:00" ;
		:forecast_range = "9-day_forecast" ;
		:forecast_type = "forecast" ;
		:bulletin_date = "2020-07-22 00:00:00" ;
		:bulletin_type = "operational" ;
		:FROM_ORIGINAL_FILE__longitude_min = -180.f ;
		:FROM_ORIGINAL_FILE__longitude_max = 179.9167f ;
		:FROM_ORIGINAL_FILE__latitude_min = -80.f ;
		:FROM_ORIGINAL_FILE__latitude_max = 90.f ;
		:z_min = 0.494025f ;
		:z_max = 5727.917f ;
		:_CoordSysBuilder = "ucar.nc2.dataset.conv.CF1Convention" ;
		:CDO = "Climate Data Operators version 1.9.9rc2 (https://mpimet.mpg.de/cdo)" ;
}
