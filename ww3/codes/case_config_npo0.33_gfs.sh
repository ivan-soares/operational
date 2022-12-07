	##### Define model inputs

	wnd='gfs'
	ice='no'
	lvl='no'
	cur='no'

	##### Define model grids

	grds='npo0.33'

	gnames=(            'npo0.33'                   'gfs'                 'points')
	gsizes=(           '211  154'              '720  361'                '  3   3')
	gsteps=('1800. 900. 900. 30.' '3600. 1700. 1800. 30.'  '3600. 1700. 1800. 30.')
	gtitle=(  'Northeast Pacific'  'GFS Global 0.5 x 0.5'   'Spectral data points')
	gzeroc=(          '190.  10.'               '0. -90.'               '-1.  -1.')
	grefin=(               ' 3.0'                   '2.0'                    '1.0')
	gtptns=(                '999'                '259920'                    '  9')


