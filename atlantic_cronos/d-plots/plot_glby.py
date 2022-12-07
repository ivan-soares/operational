#!/usr/bin/env python
#
# python make an animation of snap shots
#
import os.path, gc, sys
home = os.path.expanduser('~')
sys.path.append(home + '/operational/scripts/python/')


import math
import numpy as np
import scipy.io as sio

from netCDF4 import Dataset
from datetime import datetime, timedelta

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from matplotlib.colors import BoundaryNorm
from matplotlib.ticker import MaxNLocator

from plot_ogcm import *

import plotly.figure_factory as ff
import plotly.graph_objects as go

####################################################

inp = str(sys.argv[1])
inpfile=Dataset(inp,'r')

today = str(sys.argv[2])
dtime = int(sys.argv[3])
ogcm = str(sys.argv[4])
vint = int(sys.argv[5])
vint2 = int(sys.argv[6])

lat = inpfile.variables['lat'] [:]
lon = inpfile.variables['lon'] [:]
lon, lat = np.meshgrid(lon,lat)

u2d = inpfile.variables['water_u'][dtime,0,:,:]
v2d = inpfile.variables['water_v'][dtime,0,:,:]

#nt, nz, nlat, nlon = u2d.shape

vel = np.sqrt(u2d**2 + v2d**2)


coastfile = "costa_leste_brasil.mat"
coast = sio.loadmat(coastfile)
levels = MaxNLocator(nbins=10).tick_values(0., 1.)
cmap = plt.get_cmap('bwr')
units = 'm/s'

############## plot B. Campos

tit = 'HYCOM GLBy surface currents on ' + today
fig = 'glby_sfc_vels_' + today + '_bcampos.png'
wesn = [-47, -39, -27, -22]

x = lon[::vint, ::vint]
y = lat[::vint, ::vint]
u = u2d[::vint, ::vint]
v = v2d[::vint, ::vint]

plt.figure()
cf = plt.contourf(lon, lat, vel, levels=levels, cmap=cmap, alpha = 0.85)
cbar = plt.colorbar(cf); cbar.ax.set_ylabel(units)
plt.quiver(x,y,u,v,scale=10.0)
plt.title(tit); plt.xlabel('Longitude'); plt.ylabel('Latitude')
plt.plot(coast['lon'],coast['lat'],'k')
plt.axis((wesn[0], wesn[1], wesn[2], wesn[3]))
plt.savefig(fig,dpi=100)
plt.close()


############### plot Eq. Margin

tit = 'HYCOM GLBy surface currents on ' + today
fig = 'glby_sfc_vels_' + today + '_norte.png'
wesn = [-51.9, -37.5, -5.0, 9.5] 

x = lon[::vint2, ::vint2]
y = lat[::vint2, ::vint2]
u = u2d[::vint2, ::vint2]
v = v2d[::vint2, ::vint2]

plt.figure()
cf = plt.contourf(lon, lat, vel, levels=levels, cmap=cmap, alpha = 0.85)
cbar = plt.colorbar(cf); cbar.ax.set_ylabel(units)
plt.quiver(x,y,u,v,scale=20.0)
plt.title(tit); plt.xlabel('Longitude'); plt.ylabel('Latitude')
plt.plot(coast['lon'],coast['lat'],'k')
plt.axis((wesn[0], wesn[1], wesn[2], wesn[3]))
plt.savefig(fig,dpi=100)
plt.close()

