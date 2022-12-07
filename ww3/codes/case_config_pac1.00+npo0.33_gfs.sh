	##### Define model inputs

	wnd='gfs'
	ice='no'
	lvl='no'
	cur='no'

	##### Define model grids

	grds='pac1.00 npo0.33'

	gnames=(              'pac1.00'             'npo0.33'                   'gfs'                 'points')
	gsizes=(             '177  144'            '211  154'               '720 361'                '  3   3')
	gsteps=('3600. 1700. 1800. 30.' '1800. 900. 900. 30.' '3600. 1700. 1800. 30.'  '3600. 1700. 1800. 30.')
	gtitle=(        'Pacific Ocean'   'Northeast Pacific'  'GFS Global 0.5 x 0.5'   'Spectral data points')
	gzeroc=(            '120. -80.'           '190.  10.'             '0. -90.0'               '-1.  -1.')
	grefin=(                 ' 1.0'                ' 3.0'                   '2.0'                    '1.0')
	gtptns=(                  '999'                 '999'                '259920'                    '  9')


