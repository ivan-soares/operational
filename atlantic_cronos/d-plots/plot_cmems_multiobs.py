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
vint = int(sys.argv[4])

lat = inpfile.variables['latitude'] [:]
lon = inpfile.variables['longitude'] [:]

u = inpfile.variables['uo'][dtime,0,:,:]
v = inpfile.variables['vo'][dtime,0,:,:]

lon, lat = np.meshgrid(lon, lat)
vel = np.sqrt(u**2 + v**2)

dx = 0.5
dy = 0.5
#vint = 1

x = lon[::vint, ::vint]
y = lat[::vint, ::vint]
u = u[::vint, ::vint]
v = v[::vint, ::vint]

tit = 'MULTIOBS surface currents on ' + today
fig = 'multiobs_sfc_vels_' + today + '.png'

coastfile = "costa_leste_brasil.mat"
coast = sio.loadmat(coastfile)
wesn = [-47, -39, -27, -22]
units = 'm/s'

levels = MaxNLocator(nbins=10).tick_values(0., 1.)
cmap = plt.get_cmap('bwr')

plt.figure()
cf = plt.contourf(lon, lat, vel, levels=levels, cmap=cmap, alpha = 0.85)
cbar = plt.colorbar(cf); cbar.ax.set_ylabel(units)
plt.quiver(x,y,u,v,scale=10.0)
plt.title(tit); plt.xlabel('Longitude'); plt.ylabel('Latitude')
plt.plot(coast['lon'],coast['lat'],'k')
plt.axis((wesn[0], wesn[1], wesn[2], wesn[3]))
plt.savefig(fig,dpi=100)
plt.close()



