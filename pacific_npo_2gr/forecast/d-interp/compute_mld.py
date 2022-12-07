#######################################################################################################################

import os.path, gc, sys
home = os.path.expanduser('~')
sys.path.append(home + '/scripts/python/')

import numpy as np

from netCDF4 import Dataset
from datetime import datetime, timedelta
from romstools import get_sigma_level_depths
#from interp_data_v1 import find_mld

import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt

# Turn interactive plotting off
plt.ioff()

#import pylab as plt

from matplotlib.colors import BoundaryNorm
from matplotlib.ticker import MaxNLocator


################################# define subroutines ###################################################################

def find_mld(ogcm):

    time = ogcm.variables['time'][:]; ntime = len(time);  
    print(' '); print(' ... OGCM file has ' + str(ntime) + ' time steps')
    print(' '); print(time); print(' ')
    
    temp0 = ogcm.variables['temp'] [0,0,:,:]; nlat, nlon = temp0.shape
    mask = np.ones((nlat, nlon)); mask[np.where(temp0 < -100.)] = 0.
    del temp0

    depth = ogcm.variables['depth'][:]; ndep = len(depth)

    temp = ogcm.variables['temp'];

    mld = np.ones((ntime,nlat,nlon)) * 10.
    dt  = np.zeros((ndep,nlat,nlon))

    small = 1.0e-10

    for nt in range(ntime):

        print(' '); print(' ... doing time step ' + str(time[nt]))
	
        tpt = np.squeeze(temp[nt,:,:,:])

        for nz in range(ndep):
            dt[nz,:,:] = abs(tpt[nz,:,:] - tpt[0,:,:])

        for r in range(nlat):
            for c in range(nlon):
                if mask[r,c] == 1.:
                   mixlayer = np.where(dt[:,r,c] < 0.2 )
                   try:
                     m0 = np.amax(mixlayer)
                   except ValueError:  #raised if `y` is empty.
                     pass  
              
                   if (m0 >= ndep-1):
                       mld[nt,r,c] = abs(depth[m0])
                   else:
                       m1 = m0 + 1
                       z0 = abs(depth[m0])
                       z1 = abs(depth[m1])
                       z = z0 + (0.2-dt[m0,r,c]) *(z1 - z0)/(dt[m1,r,c]-dt[m0,r,c] + small)
                       # NEMO has a few spots of very deep MLD because of errors in CDO horizontal interp.
                       # These errors are caused by singularities in the interpolation process, because the 0.0833 NEMO grid 
                       # is very similar to but not equal to 0.08 ROMS grid. So, we limit z to 250.
                       if z >= 250.0:
                          z  = 250.0
                       mld[nt,r,c] = z
    return(time, mld)
    del time, temp, temp0, tpt, dz

################################## end of definitions ###############################################################

print(' ')
print(' +++ Starting python code to compute thermocline depth +++')
print(' ')

romsfile = str(sys.argv[1]);  roms = Dataset(romsfile,'r') ; print(' ... will read roms file ' + romsfile)
glbyfile = str(sys.argv[2]);  glby = Dataset(glbyfile,'r') ; print(' ... will read glby file ' + glbyfile)
nemofile = str(sys.argv[3]);  nemo = Dataset(nemofile,'r') ; print(' ... will read nemo file ' + nemofile)
mldfile  = str(sys.argv[4]);  tmld = Dataset(mldfile,'r+') ; print(' ... will write on file  ' + mldfile )

################# *** read lon, lat, dep from romsfile *** #########################################################

print(' ')
lon  = roms.variables['lon'] [:];    nlon = len(lon) ;  print( ' ... nlon  is ' + str(nlon))
lat  = roms.variables['lat'] [:];    nlat = len(lat) ;  print( ' ... nlat  is ' + str(nlat))
dep  = roms.variables['depth'] [:];  ndep = len(dep) ;  print( ' ... ndep  is ' + str(ndep))
print(' ')

tmld.variables['lon'] [:] = lon
tmld.variables['lat'] [:] = lat
tmld.variables['depth'] [:] = dep


######################### *** compute MLD for each file *** #############################################################################


print(' '); print(' ... doing ROMS');  time1, mld_roms = find_mld(roms)
print(' '); print(' ... doing HYCOM'); time2, mld_glby = find_mld(glby)
print(' '); print(' ... doing NEMO');  time3, mld_nemo = find_mld(nemo)

nt = len(time1)

tmld.variables['time'] [:] = time1
tmld.variables['mld_roms']  [:] = mld_roms [0:nt,:,:]
tmld.variables['mld_hycom'] [:] = mld_glby [0:nt,:,:]
tmld.variables['mld_nemo']  [:] = mld_nemo [0:nt,:,:]

tmld.close()

################################################################################################################## 

print(' ')
print(' +++ End of python code +++')
print(' ')

####################################################################################################################
