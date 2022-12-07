        ##### Define model inputs
 
        wnd='$wnd'
        ice='$ice'
        lvl='$lvl'    
        cur='$cur'
 
        ##### Define model grids

        grds='atl1.00 sao0.25 bca0.05'

        gnames=(              'atl1.00'             'sao0.25'              'bca0.05'                    'gfs'                 'points')
        gsizes=(              '112 146'             '141 193'              '151 131'                '720 361'                '  5   5')
        gsteps=('3600. 1700. 1800. 30.' '1200. 400. 600. 30.'   '400. 100. 200. 10.'  '3600. 1800. 1800. 30.'  '3600. 1800. 1800. 30.')
        gtitle=(       'Atlantic Ocean' 'West South Atlantic'         'Campos Basin'             'GFS Global'   'Spectral data points')
        gzeroc=(            '-81. -80.'           '-60. -38.'          '-44.5 -27.5'                 '0. -90'               '-1.  -1.')
        grefin=(                  '1.0'                 '4.0'                 '20.0'                    '2.0'                    '1.0')
        gtptns=(                  '999'                 '999'                  '999'                 '259920'                     '25')


