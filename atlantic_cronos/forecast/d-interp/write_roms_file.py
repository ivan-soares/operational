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
print(' +++ STARTING python program to write roms vars in z coord file +++ ')
print(' ')

start_time = tempo.time()

############################ *** file names *** ###################################################

inp = str(sys.argv[1])
out = str(sys.argv[2])

inpfile = Dataset(inp,'r')
outfile = Dataset(out,'r+')

############### *** read from inpfile & write on outfile *** ######################################

time = inpfile.variables['ocean_time'][:]
time = (time - time[0])/3600

lon = inpfile.variables['lon_rho'] [0,:]
lat = inpfile.variables['lat_rho'] [:,0]
prf = inpfile.variables['depth'] [0,:,0,0]

eta = inpfile.variables['zeta'] [:]
tpt = inpfile.variables['temp'] [:]
sal = inpfile.variables['salt'] [:]
u3d = inpfile.variables['u'] [:]
v3d = inpfile.variables['v'] [:]

print(' ')
print(' ... time = ' + str(time))
print(' ')


outfile.variables['time'][:]  = time
outfile.variables['depth'][:] = prf

outfile.variables['lat'][:] = lat
outfile.variables['lon'][:] = lon

outfile.variables['zeta'][:] = eta
outfile.variables['temp'][:] = tpt
outfile.variables['salt'][:] = sal

outfile.variables['u'][:] = u3d
outfile.variables['v'][:] = v3d

inpfile.close()
outfile.close()

#####################################################################################################



