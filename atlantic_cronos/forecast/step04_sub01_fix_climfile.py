###################################################################################################

#   program make_river_files.py  : computes river sources to be used in ROMS
#
#                                                          by IDS @ ADAC/Atlantech, Ctba 2018

############################ *** importing libraries *** ##########################################

#!/usr/bin/python

import os.path, gc, sys
newpath = os.path.join(os.path.dirname(os.path.realpath(__file__)),'..','..','scripts','python')
sys.path.append(os.path.abspath(newpath))

import numpy as np
import time as tempo
#import netCDF4 as nc
#import subprocess as sp

from my_tools import *
from netCDF4  import Dataset

#import matplotlib.pyplot as plt
#from matplotlib.colors import BoundaryNorm
#from matplotlib.ticker import MaxNLocator
#from plot_ogcm import contour_ogcm


############################ *** introdu *** ######################################################

start_time = tempo.time()

print(' ')
print(' ===> STARTING PYTHON program to fix river T/S in clim files <=== ')
print(' ')

######################## *** define file names *** ################################################

grdfile = str(sys.argv[1])
clmfile = str(sys.argv[2])
outfile = clmfile + '2'  


grd = Dataset(grdfile, 'r')
clm = Dataset(clmfile, 'r')
out = Dataset(outfile, 'r+')


### positions of sources

# amazon
# i = 80:134
# j = 54:116

# tucurui
# i = 137:145
# j =  54:110

# mearim
# i = 225:238
# j =  68: 86

print(' ')
print(' ... FIX salt & temp at river mouth')
print(' ')

#read vars

mask = grd.variables['mask_rho'][:,:]

clm_salt = clm.variables['salt'][:,:,:,:]
clm_temp = clm.variables['temp'][:,:,:,:]



#amazon river box
clm_salt[:, :, 546:584, 7:38 ] = 2.5
clm_temp[:, :, 546:584, 7:38 ] = clm_temp[0,29,614,44]
#amazon mouth
clm_salt[:, :, 584:621, 7:40 ] = 2.5
clm_temp[:, :, 584:621, 7:40 ] = clm_temp[0,29,614,44]

#tucurui river box
clm_salt[:, :, 546:584, 39:46 ] =  5.1
clm_temp[:, :, 546:584, 39:46 ] = clm_temp[0,29,592,74]
#tucurui mouth
clm_salt[:, :, 546:584, 46:77 ] = 10.01
clm_temp[:, :, 546:584, 46:77 ] = clm_temp[0,29,592,74]

#mearim river box
clm_salt[:, :, 524:536, 147:159] = 10.0
clm_salt[:, :, 536:539, 147:159] = 15.0
clm_salt[:, :, 539:542, 147:159] = 20.0
clm_salt[:, :, 542:544, 147:159] = 25.0
clm_salt[:, :, 544:547, 147:159] = 30.0

clm_temp[:, :, 524:547, 147:159] = clm_temp[0,29,550,151]

#sao chico river box
#clm_salt[:, :, 388:395, 310:313 ] =  5.1
#clm_temp[:, :, 388:395, 310:313 ] = clm_temp[0,29,387,310]

#jequitinhonha river box
#clm_salt[:, :, 282:285, 261:263 ] =  5.1
#clm_temp[:, :, 282:285, 261:263 ] = clm_temp[0,29,282,263]

#rio doce river box
#clm_salt[:, :, 207:211, 242:244 ] =  5.1
#clm_temp[:, :, 207:211, 242:244 ] = clm_temp[0,29,206,244]

#paraiba river box
#clm_salt[:, :, 169:171, 217:221 ] = 5.1
#clm_temp[:, :, 169:171, 217:221 ] = clm_temp[0,29,170,222]

# BTS
#clm_salt[:, :, 340:349, 264:271 ] = 25.1
#clm_temp[:, :, 340:349, 264:271 ] = 29.65

### mask

print(' '); print(' ... MASK LAND POINTS'); print(' ')

nt  = clm_temp.shape[0]
ns  = clm_temp.shape[1]
nla = clm_temp.shape[2] 
nlo = clm_temp.shape[3]

for n in range(nt):
    for m in range(ns):
            clm_temp[n,m,:,:] = np.squeeze(clm_temp[n,m,:,:])*mask
            clm_salt[n,m,:,:] = np.squeeze(clm_salt[n,m,:,:])*mask

### write fixed values

print(' '); print(' ... write fixed T/S'); print(' ')

out_salt = out.variables['salt']
out_temp = out.variables['temp']
out_salt[:,:,:,:] = clm_salt
out_temp[:,:,:,:] = clm_temp

out_sst = out.variables['SST']
out_sss = out.variables['SSS']
out_sst[:,:,:] = clm_temp[:,ns-1,:,:]
out_sss[:,:,:] = clm_salt[:,ns-1,:,:]

#nc_varput(clm2,'salt',salt)
#nc_varput(clm2,'temp',temp)
#nc_varput(clm2,'SSS',np.squeeze(salt[:,nsig-1,:,:]))
#nc_varput(clm2,'SST',np.squeeze(temp[:,nsig-1,:,:]))

clm.close()
out.close()

#   the end
