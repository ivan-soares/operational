#!/usr/bin/env python

########################################################################################

#    compute 3D depths Prf = H*Zeta
#
#                                                          by IDS @ TOC, Ctba 2018

############################ *** importing libraries *** ###############################
import os.path, gc, sys
home = os.path.expanduser('~')
sys.path.append(home + '/scripts/python/')

import numpy as np
import time as tempo

from romstools import get_sigma_level_depths
from my_tools import *

from netCDF4  import Dataset
from io_tools_v0 import nc_varget, nc_varput

########################################################################################

print(' '); print(' ==> STARTING PYTHON SCRIPT make_sig2z_input_files_sr02 <==')
print(' '); print(' ... will write on files depths.nc & profs.nc')
print(' ')

error = ' ... ERROR, Wrong # of arguments, exiting !!!'

nargs = len(sys.argv)
if nargs != 14:
   sys.exit(error)

######### sigma params

class data:
      def __init__(self):
          pass

params = data

params.spheri = int(sys.argv[1])
params.vtrans = int(sys.argv[2])
params.vstret = int(sys.argv[3])
params.thetas = float(sys.argv[4])
params.thetab = float(sys.argv[5])
params.tcline = int(sys.argv[6])
params.hc = int(sys.argv[7])
params.ns = int(sys.argv[8])

### grid_info=" $nlon $nlat $nsig $ndep $lon1 $lat1 $dlon $dlat"

lon1 = float(sys.argv[9])
lon2 = float(sys.argv[10])
lat1 = float(sys.argv[11])
lat2 = float(sys.argv[12])
delt = float(sys.argv[13])

nsig = params.ns

grdfile = Dataset('grid.nc','r')
h = grdfile.variables['h'][:]

# this will return parameters sig.zr and sig.zw
# which are the depths at rho and w levels
sig = get_sigma_level_depths(h, params)

lon = np.arange(lon1,lon2,delt); nlon = len(lon)
lat = np.arange(lat1,lat2,delt); nlat = len(lat)

zz = [   0,    2,    4,    6,    8,   10,   12,   15,   20,   25,   30, \
        35,   40,   45,   50,   60,   70,   80,   90,  100,  125,  150, \
       200,  250,  300,  350,  400,  500,  600,  700,  800,  900, 1000, \
      1250, 1500, 2000, 2500, 3000, 4000, 5000 ]

nz = len(zz)

print('nlon = ' + str(nlon))
print('nlat = ' + str(nlat))
print('nsig = ' + str(nsig))
print('nz   = ' + str(nz))

z = np.zeros([nz, nlat, nlon])


for k in range(nz):
    z[k, :, :] = zz[k]


if isinstance('profs.nc', str):
   out = Dataset('profs.nc', 'r+')

if isinstance('depths.nc', str):
   out2 = Dataset('depths.nc', 'r+')

nc_varput(out,'sig',sig.cr)
nc_varput(out,'lon',lon)
nc_varput(out,'lat',lat)
nc_varput(out,'prof',sig.sr)

nc_varput(out2,'dep',zz)
nc_varput(out2,'lon',lon)
nc_varput(out2,'lat',lat)
nc_varput(out2,'depth',z)

##################################### THE END ##########################################
