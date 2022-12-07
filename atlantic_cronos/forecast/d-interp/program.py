import os.path, gc, sys
home = os.path.expanduser('~')
sys.path.append(home + '/scripts/python/')
import numpy as np
from netCDF4  import Dataset
 
grd = Dataset('etopogrid.nc',  'r')
inp = Dataset('glby_mask.tpt', 'r')
out = Dataset('glby_mask.nc',  'r+')
 
lon = inp.variables['lon'] [:]; nlons = len(lon)
lat = inp.variables['lat'] [:]; nlats = len(lat)
eta = inp.variables['water_temp'] [0, 0, :, :]
 
msk = np.ones([nlats,nlons])
msk_nan = (inp.variables['water_temp'].__getattribute__('missing_value'))
msk[np.where(eta == msk_nan)] = 0
 
lon, lat = np.meshgrid(lon, lat)
 
h = -grd.variables['z'] [:]
h[np.where(h < 10.)] = 10.
h = h*msk
h = h+0.01
 
out_lon = out.variables['lon_rho']
out_lat = out.variables['lat_rho']
out_msk = out.variables['mask_rho']
out_sph = out.variables['spherical']
out_h01 = out.variables['h']
out_h02 = out.variables['hraw']
 
out_sph[:] = 1
out_lon[:] = lon
out_lat[:] = lat
out_msk[:] = msk
out_h01[:] = h
out_h02[0,:,:] = h
 
