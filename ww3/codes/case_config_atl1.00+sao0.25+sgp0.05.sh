        ##### Define model inputs
 
        wnd='$wnd'
        ice='$ice'
        lvl='$lvl'    
        cur='$cur'
 
        ##### Define model grids

        grds='$grids'

        gnames=(              'atl1.00'              'sao0.25'               'sgp0.05'                    'cfsr'                 'points')
        gsizes=(              '112 146'              '141 193'                '111 81'                '1440 721'                 '10  10')
        gsteps=('3600. 1700. 1800. 30.' '1200. 400. 600. 30.'    '400. 100. 200. 10.'   '3600. 1700. 1800. 30.'  '3600. 1700. 1800. 30.')
        gtitle=(       'Atlantic Ocean'      'South Atlantic'   'Plat. Cont. Sergipe' 'CFSR Global 0.25 x 0.25'   'Spectral data points')
        gzeroc=(            '-81. -80.'           '-60. -38.'            '-38.5 -13.'                 '0. -90.'               '-1.  -1.')
        grefin=(                  '1.0'                 '4.0'                  '20.0'                     '4.0'                    '1.0')
        gtptns=(                  '999'                 '999'                   '999'                 '1038240'                    '100')
 

