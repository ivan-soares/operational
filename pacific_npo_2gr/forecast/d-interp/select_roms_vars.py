############################ *** importing libraries *** ##########################################

#!/usr/bin/python

import os.path, gc, sys
home = os.path.expanduser('~')
sys.path.append(home + '/scripts/python/')

import numpy as np
import time as tempo

from netCDF4 import Dataset

############################ *** introdu *** ######################################################

print(' ')
print(' +++> STARTING python program to select ROMS vars <+++ ')
print(' ')

start_time = tempo.time()

############################ *** file names *** ###################################################

inp = str(sys.argv[1])
out = str(sys.argv[2])

inpfile = Dataset(inp,'r')
outfile = Dataset(out,'r+')

############### *** read from inpfile & write on outfile *** ######################################

outfile.variables['time'][:] = inpfile.variables['ocean_time'] [:]
outfile.variables['lat'][:] = inpfile.variables['lat_rho'] [:,0]
outfile.variables['lon'][:] = inpfile.variables['lon_rho'] [0,:]
outfile.variables['s_rho'][:] = inpfile.variables['s_rho'] [:]

outfile.variables['mask_rho'][:] = inpfile.variables['mask_rho'] [:]

outfile.variables['zeta'][:] = inpfile.variables['zeta'] [:]
outfile.variables['temp'][:] = inpfile.variables['temp'] [:]
outfile.variables['salt'][:] = inpfile.variables['salt'] [:]

outfile.variables['u_eastward'][:]  = inpfile.variables['u_eastward'] [:]
outfile.variables['v_northward'][:] = inpfile.variables['v_northward'] [:]

inpfile.close()
outfile.close()

print(' ')
print(' +++> END of python program  <+++ ')
print(' ')

#####################################################################################################



