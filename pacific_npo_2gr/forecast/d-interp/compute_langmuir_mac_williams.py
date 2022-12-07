###########################################################################################

import os.path, gc, sys, math
home = os.path.expanduser('~')
sys.path.append(home + '/scripts/python/')

import numpy as np

from netCDF4 import Dataset
from datetime import datetime, timedelta
from romstools import get_sigma_level_depths

import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

# Turn interactive plotting off
plt.ioff()

#import pylab as plt

from matplotlib.colors import BoundaryNorm
from matplotlib.ticker import MaxNLocator

###################### *** input files *** #############################################

print(' ')
print(' +++ Starting python code to compute Langmuir parameter +++')
print(' ')

wavefile = str(sys.argv[1])
langfile = str(sys.argv[2])

wave = Dataset(wavefile,'r')
lang = Dataset(langfile,'r+')

print(' ... will read from ww3 file ' + wavefile)
print(' ... will write on file ' + langfile)
print(' ')


############################ *** read/write ROMS grid vars *** #########################

lon = wave.variables['lon'][:]
lat = wave.variables['lat'][:]
msk = wave.variables['MAPSTA'][:]
prf = wave.variables['dpt'][:]

#### the output fiel already has lon/lat
#### we wrote them when we computed MLD

#lang.variables['lon'] [:] = lon
#lang.variables['lat'] [:] = lat
#lang.variables['mask_rho'] [:] = msk

nj, ni = msk.shape

############################# *** general parameters *** #############################

small = 0.000001
drag = 1.3e-3 # (non-dimensional)
rho_air = 1.2754 # (kg/m3)
rho_sea = 1027.0 # (km/m3)

#################### *** nu_t turbulent viscosity *** #################################

indx = [ 12, 36, 60, 84,  108,  132, 156]
tzero = wave.variables['time'][0]; 
time = wave.variables['time'][indx]
time = (time - tzero)*24.
ntime = len(time)

print( ' ')
print( ' ... time =  ' + str(time))
print( ' ... nlon is ' + str(ni))
print( ' ... nlat is ' + str(nj))
print( ' ')

#### read wind velocity components

uwind = wave.variables['uwnd'] [indx,:,:]
vwind = wave.variables['vwnd']  [indx,:,:]
uwind[np.where(uwind.mask == True)] = 0.
vwind[np.where(vwind.mask == True)] = 0.

#### read surface Stokes drift

uuss = wave.variables['uuss'] [indx,:,:]
vuss = wave.variables['vuss'] [indx,:,:]
uuss[np.where(uuss.mask == True)] = 0.
vuss[np.where(vuss.mask == True)] = 0.

#### compute new vars

sdrift = np.sqrt(uuss**2 + vuss**2) 

wvel = np.sqrt(uwind**2 + vwind**2)
wtau = np.sqrt(drag) * wvel
ustar = np.sqrt(wtau/rho_sea)

#### compute Langmuir

langm = np.sqrt(ustar/sdrift) 
langm[np.where(langm >= 1. )] = 1.
### write out

lang.variables['time'][:] = time
lang.variables['langmuir'][:] = langm
   
lang.close()
 
print(' ')
print(' ... end of program')
print(' ')

##########################################################################################

