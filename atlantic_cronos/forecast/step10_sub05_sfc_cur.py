#
# WORK TO DO
# 1. automatic colorbar location adjustment w/ diferent fig sizes
# 2. automatic optimum colorbar scalling
# 3. 
# 
# 
# fsobral - Feb 2021
# 
# =======================================================================

import numpy as np
import xarray as xr
from datetime import date, timedelta
import glob, os, sys
import cartopy
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import matplotlib.colors as colors
from matplotlib import offsetbox
from matplotlib.patches import Polygon
from matplotlib.collections import PatchCollection
from matplotlib.animation import ImageMagickWriter
from cmocean import cm as cmo
from pycurvec.curvec import curvec

import cmap_odyssea
ody = cmap_odyssea.create_cmap()


# ----

plt.rcParams['figure.dpi']     = 96
plt.rcParams['figure.figsize'] = [12,9]
plt.rcParams['savefig.bbox']   = 'tight'
plt.rcParams['font.size']      = 14


# ================================================================================= #

print(' ... creating surface currents fancy figures')

yesterday = os.getenv('yesterday')
__dir = os.getenv('__dir')

shpfile = cartopy.io.shapereader.gshhs('i')
coast = cartopy.io.shapereader.Reader(shpfile)

shpfile = cartopy.io.shapereader.natural_earth(resolution='50m',name='rivers_lake_centerlines')
rivers = cartopy.io.shapereader.Reader(shpfile)
coast_geom = [c for c in coast.geometries()]
river_geom = [r for r in rivers.geometries()]


area     = sys.argv[1]
land     = sys.argv[2]
longname = sys.argv[3]


# Giving some limits. This part has to be rethink to automate this process.
if area == 'bsc':
    vv_mn   = 0
    vv_mx   = 1
    sal_mn  = 33
    sal_mx  = 37.5
    temp_mn = 20
    temp_mx = 27
elif area == 'bam':
    vv_mn   = 0
    vv_mx   = 1.5
    sal_mn  = 30.5
    sal_mx  = 37.5
    temp_mn = 26
    temp_mx = 30  
elif area == 'alg':
    vv_mn   = 0
    vv_mx   = 1.5
    sal_mn  = 32.5
    sal_mx  = 37.5
    temp_mn = 27
    temp_mx = 29    
elif area == 'flp':
    vv_mn   = 0
    vv_mx   = 1
    sal_mn  = 33
    sal_mx  = 37.5
    temp_mn = 20
    temp_mx = 26
elif area == 'bts':
    vv_mn   = 0
    vv_mx   = 1
    sal_mn  = 35.5
    sal_mx  = 38.5
    temp_mn = 25
    temp_mx = 28
    
lim_mn = [vv_mn, sal_mn, temp_mn]
lim_mx = [vv_mx, sal_mx, temp_mx]

spacing1 = [20, 60, 60]
spacing2 = [.3, 1, 1]

# Velocity, salinity and temperature
cmp = [plt.cm.turbo, ody, cmo.thermal]

# 
# 
# 
# ======================================================================================
# 
# --------------------------------------FIG 1 SAT --------------------------------------
# 
# ======================================================================================
# 
# 
# 
ncfile = f'area_sat1_{area}_{yesterday}.nc'
fig_nm = ncfile.split('/')[-1].split('_')[1]

ds = xr.open_dataset(ncfile)
limits = [ds.longitude.min(),ds.longitude.max(),ds.latitude.min(),ds.latitude.max()]

dsm = ds.mean('time')
vel = (dsm.ugos**2 + dsm.vgos**2)**0.5

plt.style.use("dark_background")

fig = plt.figure()
ax = plt.axes(projection=ccrs.PlateCarree())

bounds = np.linspace(lim_mn[0], lim_mx[0], spacing1[0])
norm = colors.BoundaryNorm(boundaries=bounds, ncolors=256)

pch = ax.pcolormesh(vel.longitude,vel.latitude,vel,norm=norm,
                    cmap=plt.cm.turbo)


# COLORBAR
if land == 'NW':
    x0 = ax.get_position().x0 + 0.01
    y0 = ax.get_position().y1 - 0.07
    cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
    ob = offsetbox.AnchoredText(f'CMEMS SLA {longname}', loc='upper left',
                            borderpad=0,
                            frameon=False,
                            prop=dict(color='w', size=15))
    ax.add_artist(ob)
    

elif land == 'SW':
    x0 = ax.get_position().x0 + 0.01
    y0 = ax.get_position().y0 + 0.07
    cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
    ob = offsetbox.AnchoredText(f'CMEMS SLA {longname}', loc='lower left',
                                borderpad=0,
                                frameon=False,                                
                                prop=dict(color='w', size=15))
    ax.add_artist(ob)

elif land == 'W':
    x0 = ax.get_position().x0 + 0.01
    y0 = ax.get_position().y1 - 0.33
    cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
    ob = offsetbox.AnchoredText(f'CMEMS SLA {longname}', loc='center left',
                                borderpad=0,
                                frameon=False,
                                prop=dict(color='w', size=14))
    ax.add_artist(ob)
        


cbaxes.tick_params(labelsize=10)
cbh = plt.colorbar(pch, cax=cbaxes, orientation='horizontal')
cbh.set_ticks(np.arange(lim_mn[0], lim_mx[0], spacing2[0]))

if land == 'NW':
    cbaxes.set_xlabel('Velocity (m/s)', color='w')
elif land in ('W', 'SW'):
    cbaxes.set_title('Velocity (m/s)')

x, y = np.meshgrid(dsm.longitude.values,dsm.latitude.values)
u = dsm.ugos.values
v = dsm.vgos.values
mag = (u**2+v**2)**0.5
pos = np.array([])

polx,poly,xax,yax,veclen,pos = curvec(x, y, u/mag**0.8, v/mag**0.8,              \
                                    length=86400,dx=111000*0.3,timestep=6*3600, \
                                    lifespan=15,iopt=1,position=pos)

arrows = []
for i in range(polx.shape[0]):
    arrow = Polygon(np.array([polx[i],poly[i]]).T, True)
    arrows.append(arrow)
patches = PatchCollection(arrows, alpha=0.5, edgecolor='none', facecolor='k')

ax.set_extent(limits, crs=ccrs.PlateCarree())

ax.add_collection(patches)

gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=False, color='k', alpha=0.5, linestyle='--')

ax.add_geometries(coast_geom, ccrs.PlateCarree(), edgecolor='none', facecolor='k')
ax.add_geometries(river_geom, ccrs.PlateCarree(), alpha=0.5, edgecolor='lightblue', facecolor='none')

plt.savefig(f"{fig_nm}_sfc_averaged_currents_{area}.png")
plt.close()
# ----

# 
# 
# ----- Loop to the models
# 
# 
mdls = ['nemo' , 'glby']
for OGCM in mdls:

    # 
    # ==============================================================================================
    # 
    # ------------------------------------------- FIG 2 OGCM ---------------------------------------
    # 
    # ==============================================================================================
    # 
    ncfile = f'area_{OGCM}_{area}_{yesterday}.nc'
    fig_nm = ncfile.split('/')[-1].split('_')[1]

    ds = xr.open_dataset(ncfile)

    # This average is using the file with one day only (created by step10_sub01)
    dsm = ds.mean('time')  
    
    if OGCM == 'nemo':
        vel    = (dsm.uo**2 + dsm.vo**2)**0.5
        sal    = (dsm.so)
        temp   = (dsm.thetao)
    else:
        vel = (dsm.water_u**2 + dsm.water_v**2)**0.5
        sal  = (dsm.salinity)
        temp = (dsm.water_temp)

        
    vrb    = [vel, sal, temp]
    vrb_nm = ['Velocity (m/s)', 'Salinity (psu)', 'Temperature ($^\circ C$)']
    fgnm   = ['currents', 'sal', 'temp']
    
    # Loop over variables (vel, sal and temp)
    for ENU, (VRB, VRBNM, FIGNM) in enumerate(zip(vrb, vrb_nm, fgnm)):
        plt.style.use("dark_background")

        fig = plt.figure()
        ax = plt.axes(projection=ccrs.PlateCarree())



        bounds = np.linspace(lim_mn[ENU], lim_mx[ENU], spacing1[ENU])           
        norm = colors.BoundaryNorm(boundaries=bounds, ncolors=256)

        if OGCM == 'nemo':
            pch = ax.pcolormesh(vel.longitude, vel.latitude, VRB, norm=norm,
                                cmap=cmp[ENU],transform=ccrs.PlateCarree())
        else:
            pch = ax.pcolormesh(vel.lon, vel.lat, VRB, norm=norm,
                                cmap=cmp[ENU],transform=ccrs.PlateCarree())


        # COLORBAR
        if land == 'NW':
            x0 = ax.get_position().x0 + 0.02
            y0 = ax.get_position().y1 - 0.07
            cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
            ob = offsetbox.AnchoredText(f'{OGCM.upper()} {longname}', loc='upper left',
                                    borderpad=0,
                                    frameon=False,
                                    prop=dict(color='w', size=15))
            ax.add_artist(ob)
            

        elif land == 'SW':
            x0 = ax.get_position().x0 + 0.02
            y0 = ax.get_position().y0 + 0.07
            cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
            ob = offsetbox.AnchoredText(f'{OGCM.upper()} {longname}', loc='lower left',
                                        borderpad=0,
                                        frameon=False,                                
                                        prop=dict(color='w', size=15))
            ax.add_artist(ob)

        elif land == 'W':
            x0 = ax.get_position().x0 + 0.02
            y0 = ax.get_position().y1 - 0.33
            cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
            ob = offsetbox.AnchoredText(f'{OGCM.upper()} {longname}', loc='center left',
                                        borderpad=0,
                                        frameon=False,
                                        prop=dict(color='w', size=14))
            ax.add_artist(ob)


        cbaxes.tick_params(labelsize=10)
        cbh = plt.colorbar(pch, cax=cbaxes, orientation='horizontal')
        if land == 'NW':
            cbaxes.set_xlabel(VRBNM, color='w')
        elif land in ('W', 'SW'):
            cbaxes.set_title(VRBNM)
        

        cbh.set_ticks(np.arange(lim_mn[ENU], lim_mx[ENU], spacing2[ENU]))

        if OGCM == 'nemo':
            x, y = np.meshgrid(dsm.longitude.values,dsm.latitude.values)
            u = dsm.uo.values
            v = dsm.vo.values
        else:
            x, y = np.meshgrid(dsm.lon.values,dsm.lat.values)
            u = dsm.water_u.values
            v = dsm.water_v.values

        mag = (u**2+v**2)**0.5
        pos = np.array([])

        polx,poly,xax,yax,veclen,pos = curvec(x, y, u/mag**0.8, v/mag**0.8,              \
                                            length=86400,dx=111000*0.3,timestep=6*3600, \
                                            lifespan=15,iopt=1,position=pos)

        arrows = []
        for i in range(polx.shape[0]):
            arrow = Polygon(np.array([polx[i],poly[i]]).T, True)
            arrows.append(arrow)
        patches = PatchCollection(arrows, alpha=0.5, edgecolor='none', facecolor='k')

        ax.set_extent(limits, crs=ccrs.PlateCarree())

        ax.add_collection(patches)

        gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=False, color='k', alpha=0.5, linestyle='--')

        ax.add_geometries(coast_geom, ccrs.PlateCarree(), edgecolor='none', facecolor='k')
        ax.add_geometries(river_geom, ccrs.PlateCarree(), alpha=0.5, edgecolor='lightblue', facecolor='none')

        plt.savefig(f"{fig_nm}_sfc_averaged_{FIGNM}_{area}.png")
        plt.close()
        # ----

    # 
    # ====================================================================================================
    # 
    # ----------------------------------------- FIG 3 ROMS+OGCM ------------------------------------------
    # 
    # ====================================================================================================
    # 
    ncfile = f'area_roms+{OGCM}_{area}_{yesterday}.nc'
    fig_nm = ncfile.split('/')[-1].split('_')[1]

    ds = xr.open_dataset(ncfile)

    # This average is using the file with one day only (created by step10_sub01)
    dsm = ds.mean('ocean_time')
    
    
    vel  = (dsm.u_eastward**2 + dsm.v_northward**2)**0.5
    sal  = dsm.salt
    temp = dsm.temp

    vrb    = [vel, sal, temp]
    vrb_nm = ['Velocity (m/s)', 'Salinity (psu)', 'Temperature ($^\circ C$)']
    fgnm   = ['currents', 'sal', 'temp']
    
    for ENU, (VRB, VRBNM, FIGNM) in enumerate(zip(vrb, vrb_nm, fgnm)):
        plt.style.use("dark_background")

        fig = plt.figure()
        ax = plt.axes(projection=ccrs.PlateCarree())

        bounds = np.linspace(lim_mn[ENU], lim_mx[ENU], spacing1[ENU])

        norm = colors.BoundaryNorm(boundaries=bounds, ncolors=256)

        pch = plt.pcolormesh(vel.lon_rho, vel.lat_rho, VRB,norm=norm,
                            cmap=cmp[ENU],transform=ccrs.PlateCarree())

        # COLORBAR
        if land == 'NW':
            x0 = ax.get_position().x0 + 0.02
            y0 = ax.get_position().y1 - 0.07
            cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
            ob = offsetbox.AnchoredText(f'ROMS+{OGCM.upper()} {longname}', loc='upper left',
                                    borderpad=0,
                                    frameon=False,
                                    prop=dict(color='w', size=15))
            ax.add_artist(ob)
            

        elif land == 'SW':
            x0 = ax.get_position().x0 + 0.02
            y0 = ax.get_position().y0 + 0.07
            cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
            ob = offsetbox.AnchoredText(f'ROMS+{OGCM.upper()} {longname}', loc='lower left',
                                        borderpad=0,
                                        frameon=False,                                
                                        prop=dict(color='w', size=15))
            ax.add_artist(ob)

        elif land == 'W':
            x0 = ax.get_position().x0 + 0.02
            y0 = ax.get_position().y1 - 0.33
            cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
            ob = offsetbox.AnchoredText(f'ROMS+{OGCM.upper()} {longname}', loc='center left',
                                        borderpad=0,
                                        frameon=False,
                                        prop=dict(color='w', size=14))
            ax.add_artist(ob)


        cbaxes.tick_params(labelsize=10)
        cbh = plt.colorbar(pch, cax=cbaxes, orientation='horizontal')
        if land == 'NW':
            cbaxes.set_xlabel(VRBNM, color='w')
        elif land in ('W', 'SW'):
            cbaxes.set_title(VRBNM)


        cbh.set_ticks(np.arange(lim_mn[ENU], lim_mx[ENU], spacing2[ENU]))

        x = dsm.lon_rho.values
        y = dsm.lat_rho.values
        u = dsm.u_eastward.values
        v = dsm.v_northward.values
        mag = (u**2+v**2)**0.5
        pos = np.array([])

        polx,poly,xax,yax,veclen,pos = curvec(x, y, u/mag**0.8, v/mag**0.8,              \
                                            length=86400,dx=111000*0.3,timestep=6*3600, \
                                            lifespan=15,iopt=1,position=pos)

        arrows = []
        for i in range(polx.shape[0]):
            arrow = Polygon(np.array([polx[i],poly[i]]).T, True)
            arrows.append(arrow)
        patches = PatchCollection(arrows, alpha=0.5, edgecolor='none', facecolor='k')

        ax.set_extent(limits, crs=ccrs.PlateCarree())

        ax.add_collection(patches)

        gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=False, color='k', alpha=0.5, linestyle='--')

        ax.add_geometries(coast_geom, ccrs.PlateCarree(), edgecolor='none', facecolor='k')
        ax.add_geometries(river_geom, ccrs.PlateCarree(), alpha=0.5, edgecolor='lightblue', facecolor='none')


        plt.savefig(f"{fig_nm}_sfc_averaged_{FIGNM}_{area}.png")
        plt.close()
        # ----


##########################################################################################################
# END
##########################################################################################################