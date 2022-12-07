	##### Define model inputs

	wnd='gfs'
	ice='no'
	lvl='no'
	cur='no'

	##### Define model grids

	grds='pac1.00 npo0.33'

	gnames=(              'pac1.00'             'npo0.33'                  'cfsr'                 'points')
	gsizes=(             '177  144'            '211  154'              '421  351'                '  3   3')
	gsteps=('3600. 1700. 1800. 30.' '1800. 900. 900. 30.' '3600. 1700. 1800. 30.'  '3600. 1700. 1800. 30.')
	gtitle=(        'Pacific Ocean'   'Northeast Pacific'     'CFSR Quasi-Global'   'Spectral data points')
	gzeroc=(            '120. -80.'           '190.  10.'             '95. -87.5'               '-1.  -1.')
	grefin=(                 ' 1.0'                ' 3.0'                   '2.0'                    '1.0')
	gtptns=(                  '999'                 '999'                '147771'                    '  9')


