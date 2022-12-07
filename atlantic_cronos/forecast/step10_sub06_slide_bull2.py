# 
# 
# This script create all the figures to be used in the bulletin_template.
# 
# 
# fsobral - Mar 2021
# updated - May 4th, 2021
# 
# ================================================================================ 

import xarray as xr
import pandas as pd
import windrose as wr
import os, sys, seaborn, cartopy
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import cartopy.crs as ccrs
import matplotlib.pyplot as plt
import matplotlib.colors as colors
from matplotlib import offsetbox
from mpl_toolkits.axes_grid1 import make_axes_locatable
from glob import glob

plt.rcParams['figure.dpi']     = 96
plt.rcParams['figure.figsize'] = [12,9]
# plt.rcParams['savefig.bbox']   = 'tight'
plt.rcParams['font.size']      = 14

# =============================================================================

# Finding and rounding the max value
ymx = lambda ymx: np.ceil(np.nanmax(hs.values)) + np.nanstd(hs.values)

# =============================================================================
# 
# 
# 
# 
# =============================================================================
# 
# ----------------------------------- WW3 -------------------------------------
# 
# =============================================================================

yesterday = os.getenv('yesterday')
sto = os.path.join(os.getenv('stodir'), yesterday)
__dir = os.getenv('__dir')

NM = sys.argv[1]
longname = sys.argv[2]
land = sys.argv[3]

FLS = glob('*nc')


ww3flP = [FLS[enu] for enu, vv in enumerate(FLS) if 'point' in vv and 'ww3' in vv and f'{NM}' in vv]
ww3flA = [FLS[enu] for enu, vv in enumerate(FLS) if 'area' in vv and 'ww3' in vv and f'{NM}' in vv]
area = NM
flP = xr.open_dataset(ww3flP[0])
flA = xr.open_dataset(ww3flA[0])
plon = flP.longitude.values
plat = flP.latitude.values


# Getting variables reducing the number of point to clean visually the plot
hs    = flP.hs[::3]
phs0  = flP.phs0[::3]
phs1  = flP.phs1[::3]
phs2  = flP.phs2[::3]

tp    = flP.fp[::3] #this fp really means tp, I did 1/fp on step10_sub01
ptp0  = flP.ptp0[::3]
ptp1  = flP.ptp1[::3]
ptp2  = flP.ptp2[::3]

dp    = flP.dp[::3]
pdir0 = flP.pdir0[::3]
pdir1 = flP.pdir1[::3]
pdir2 = flP.pdir2[::3]


# Transforming nautical coordinates to cartesian and translating it
# to indicate the right direction of the wave (from where it's coming)
# at the cartesian system.
ku = np.cos((270 - dp)*np.pi/180)
kv = np.sin((270 - dp)*np.pi/180)

ku0 = np.cos((270 - pdir0)*np.pi/180)
kv0 = np.sin((270 - pdir0)*np.pi/180)

ku1 = np.cos((270 - pdir1)*np.pi/180)
kv1 = np.sin((270 - pdir1)*np.pi/180)

ku2 = np.cos((270 - pdir2)*np.pi/180)
kv2 = np.sin((270 - pdir2)*np.pi/180)

# 
# ----------------------------------------------------------------------------
# 
# ------------------------------- SEASTATE -----------------------------------
# ---------------- LINE PLOT FOR THE HS/TP/DP FORECAST (POINT) ---------------
# 
# ----------------------------------------------------------------------------
# 

plt.close('all')
plt.figure(figsize=(12,3))

plt.quiver(phs0.time.values, phs0.values, ku0.values, kv0.values, ptp0.values, scale=30, width=0.002, clim=(2,16), cmap=plt.cm.turbo)
plt.quiver(phs1.time.values, phs1.values, ku1.values, kv1.values, ptp1.values, scale=30, width=0.002, clim=(2,16), cmap=plt.cm.turbo)
plt.quiver(phs2.time.values, phs2.values, ku2.values, kv2.values, ptp2.values, scale=30, width=0.002, clim=(2,16), cmap=plt.cm.turbo)

pc = plt.scatter(phs0.time.values, phs0.values, c=ptp0, s=75, cmap=plt.cm.turbo, vmin=2, vmax=16)
plt.scatter(phs1.time.values, phs1.values, c=ptp1, s=75, cmap=plt.cm.turbo, vmin=2, vmax=16)
plt.scatter(phs2.time.values, phs2.values, c=ptp2, s=75, cmap=plt.cm.turbo, vmin=2, vmax=16)
plt.tick_params(axis='x', rotation=45)

cbar = plt.colorbar(pc)
cbar.ax.set_ylabel('Wave Period (s)')

inf = hs.time[0].values - np.timedelta64(2, 'h')
sup = hs.time[-1].values + np.timedelta64(2, 'h')
plt.xlim([inf, sup])

# Giving a value better rounded. 
ymx_rd = (np.ceil(ymx(hs)) + np.floor(ymx(hs)))/2

plt.ylim([0, ymx_rd])
plt.grid()
plt.ylabel('Significant wave height (m)')
plt.xlabel('Time')
plt.title(f"Sea state 7 day forecast from {hs.time[0].values.astype('datetime64[D]')}\nLon: {plon} Lat: {plat} ", fontsize=14)

plt.savefig(f'frcst_seastate_{yesterday}_{area}.png', bbox_inches='tight')
plt.close()

# 
# ----------------------------------------------------------------------------------
#
# ------------------------- Hs and SEASTATE (subplot) (POINT) ----------------------
# 
# ----------------------------------------------------------------------------------
# 

plt.close('all')
fig, ax = plt.subplots(figsize=(12,8), ncols=1, nrows=2)

ax[0].plot(hs.time, hs, '--k', linewidth=2)
ax[0].set_xlim([hs.time[0].values,hs.time[-1].values])
ax[0].set_ylim([0, ymx_rd])
ax[0].set_ylabel('Hs (m)')
ax[0].grid(True)
divider = make_axes_locatable(ax[0])
cax = divider.append_axes("right", size="3%", pad=0.5)
cax.axis('off')


ax[1].quiver(phs0.time.values, phs0.values, ku0.values, kv0.values, ptp0.values, scale=30, width=0.002, clim=(2,16), cmap=plt.cm.turbo)
ax[1].quiver(phs1.time.values, phs1.values, ku1.values, kv1.values, ptp1.values, scale=30, width=0.002, clim=(2,16), cmap=plt.cm.turbo)
ax[1].quiver(phs2.time.values, phs2.values, ku2.values, kv2.values, ptp2.values, scale=30, width=0.002, clim=(2,16), cmap=plt.cm.turbo)

pc = ax[1].scatter(phs0.time.values, phs0.values, c=ptp0, s=75, cmap=plt.cm.turbo, vmin=2, vmax=16)
ax[1].scatter(phs1.time.values, phs1.values, c=ptp1, s=75, cmap=plt.cm.turbo, vmin=2, vmax=16)
ax[1].scatter(phs2.time.values, phs2.values, c=ptp2, s=75, cmap=plt.cm.turbo, vmin=2, vmax=16)
divider = make_axes_locatable(ax[1])
cax2 = divider.append_axes("right", size="3%", pad=0.5)

cbar = plt.colorbar(pc, cax=cax2)
cbar.ax.set_ylabel('Wave Period (s)')

ax[1].set_xlim([inf, sup])
ax[1].set_ylim([0, ymx_rd])
ax[1].grid(True)
ax[1].set_ylabel('Significant wave height (m)')
ax[1].set_xlabel('Time')
ax[1].set_title(f"Sea state 7 day forecast from {hs.time[0].values.astype('datetime64[D]')}\nLon: {plon} Lat: {plat} ", fontsize=14)

plt.tight_layout()

plt.savefig(f'frcst_hs_seastate_{yesterday}_{area}.png', bbox_inches='tight')
plt.close()


# 
# -----------------------------------------------------------------------------
#
# ---------------------------- HS Hour FIELD plot (AREA)-------------------
# 
# -----------------------------------------------------------------------------
# 

# limits = [flA.longitude.min(), 
#             flA.longitude.max(),
#             flA.latitude.min(),
#             flA.latitude.max()]

# Index hours
idx = [0, 3, 6, 12]

alon = flA.longitude.values
alat = flA.latitude.values

for ii in idx:

    hs = flA.hs[ii, :]
    dp = flA.dp[ii, :]

    plt.close('all')
    plt.style.use("dark_background")
    
    # subplot_kw = dict(projection=ccrs.PlateCarree())
    fig, ax = plt.subplots(figsize=(12, 9))#, subplot_kw=subplot_kw)

    shpfile = cartopy.io.shapereader.gshhs('i')
    coast = cartopy.io.shapereader.Reader(shpfile)

    shpfile = cartopy.io.shapereader.natural_earth(resolution='50m',name='rivers_lake_centerlines')
    rivers = cartopy.io.shapereader.Reader(shpfile)
    coast_geom = [c for c in coast.geometries()]

    # ax.set_extent(limits)#, crs=ccrs.PlateCarree())

    # gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=False, color='k', alpha=0.5, linestyle='--')
    # gl = ax.gridlines(draw_labels=False, color='k', alpha=0.5, linestyle='--')
    # ax.add_geometries(coast_geom, ccrs.PlateCarree(), edgecolor='none', facecolor='k')
    # ax.add_geometries(coast_geom, edgecolor='none', facecolor='k')

    bounds = np.linspace(0, np.round(np.max(hs)), 30)
    norm = colors.BoundaryNorm(boundaries=bounds, ncolors=256)

    # 
    # >>
    pch = ax.contourf(alon, alat, hs, 
                        levels=30,
                        norm=norm,
                        cmap=plt.cm.turbo)
                        # transform=ccrs.PlateCarree())

    ax.grid(True)
    ax.set_xticklabels([])
    ax.set_yticklabels([])

    # Point Position
    plt.plot(plon, plat, 'om', markersize=20)

    # Arrows for the Dp
    x, y = np.meshgrid(alon, alat)
    # dp = dp.values
    ku = np.cos((270 - dp) * np.pi / 180)
    kv = np.sin((270 - dp) * np.pi / 180)

    spacing = 10
    ax.quiver(alon[::spacing], alat[::spacing], 
                ku[::spacing, ::spacing], kv[::spacing, ::spacing], 
                scale=15, 
                width=0.004, 
                color='k') 
                # transform=ccrs.PlateCarree())
    # <<
    # 
    # COLORBAR
    if land == 'NW':
        x0 = ax.get_position().x0 + 0.02
        y0 = ax.get_position().y1 - 0.09
        cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
        ob = offsetbox.AnchoredText(f'WW3 {longname}\n{ii} h', loc='upper left',
                                borderpad=0,
                                frameon=False,
                                prop=dict(color='w', size=15))
        ax.add_artist(ob)
        

    elif land == 'SW':
        x0 = ax.get_position().x0 + 0.02
        y0 = ax.get_position().y0 + 0.09
        cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
        ob = offsetbox.AnchoredText(f'WW3 {longname}\n{ii} h', loc='lower left',
                                    borderpad=0,
                                    frameon=False,                                
                                    prop=dict(color='w', size=15))
        ax.add_artist(ob)

    elif land == 'W':
        x0 = ax.get_position().x0 + 0.02
        y0 = ax.get_position().y1 - 0.33
        cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
        ob = offsetbox.AnchoredText(f'WW3 {longname}\n{ii} h', loc='center left',
                                    borderpad=0,
                                    frameon=False,
                                    prop=dict(color='w', size=14))
        ax.add_artist(ob)


    cbh = plt.colorbar(pch, cax=cbaxes, orientation='horizontal')
    cbh.set_ticks(np.arange(0, ymx_rd, 0.5))
    cbaxes.tick_params(labelsize=10)
    if land == 'NW':
        cbaxes.set_xlabel('Hs (m)', color='w')
    elif land in ('W', 'SW'):
        cbaxes.set_title('Hs (m)')

    # ax.text(alon.min()+0.1, alat.max()-0.5, f'{ii} h', color='w', fontsize=26, fontweight='bold')

    plt.savefig(f'frcst_sfc_hsdp_{ii}h_{yesterday}_{area}.png', bbox_inches='tight')
    plt.close()

# ----------------------------------------------------------------------------------
#
# ------------------------------ WAVE ROSE (POINT) ---------------------------------
# 
# ----------------------------------------------------------------------------------

hs = flP.hs
dp = flP.dp
tp = flP.fp

plt.style.use("default")

# HS
fig = plt.figure(figsize=(8,6), dpi=100)
ax = wr.WindroseAxes.from_ax(fig=fig, rmax=60, theta_labels=['E','NE','N','NW','W','SW','S','SE'])
ax.bar(dp, hs, normed=True, nsector=16, opening=0.95, bins=np.arange(0.5, ymx_rd, 0.5))
ax.set_legend()
ax.set_title('Significant Wave Height')
plt.savefig(f'waverose_hs_{yesterday}_{area}.png', bbox_inches='tight')

# TP
fig = plt.figure(figsize=(8,6), dpi=100)
ax = wr.WindroseAxes.from_ax(fig=fig, rmax=60, theta_labels=['E','NE','N','NW','W','SW','S','SE'])
ax.bar(dp, tp, normed=True, nsector=16, opening=0.95, bins=np.arange(2, np.ceil(tp.values.max()), 2))
ax.set_legend()
ax.set_title('Wave Peak Period')
plt.savefig(f'waverose_tp_{yesterday}_{area}.png', bbox_inches='tight')
plt.close()

# 
# ----------------------------------------------------------------------------------
#
# ------------------ PROBABILITY DENSITY DISTRIBUTION (POINT) ----------------------
# 
# ----------------------------------------------------------------------------------
# 

df = pd.DataFrame(columns=['Hs (m)', 'Tp (s)', 'Dp (°N)'])
df['Hs (m)']  = flP.hs
df['Tp (s)']  = flP.fp
df['Dp (°N)'] = flP.dp


fig, ax = plt.subplots(figsize=(12, 7), ncols=3, nrows=1)
# 
# 
kdeplot=seaborn.kdeplot(x=df['Hs (m)'], y=df["Tp (s)"], ax=ax[0], fill=True, thresh=0, levels=100, cmap="turbo", cbar=True, 
                    cbar_kws= {'shrink':0.35,}
                    )
# get the current colorbar ticks
cbar_ticks = kdeplot.figure.axes[-1].get_yticks()
# get the maximum value of the colorbar
_, cbar_max = kdeplot.figure.axes[-1].get_ylim()
# change the labels (not the ticks themselves) to a percentage
kdeplot.figure.axes[-1].set_yticklabels([f'{t / cbar_max * 100:.1f} %' for t in cbar_ticks])

ax[0].set_box_aspect(1)
# 
# 
kdeplot = seaborn.kdeplot(x=df['Hs (m)'], y=df["Dp (°N)"], ax=ax[1], fill=True, thresh=0, levels=100, cmap="turbo", cbar=True, 
                    cbar_kws= {'shrink':0.35,}
                    )

# get the current colorbar ticks
cbar_ticks = kdeplot.figure.axes[-1].get_yticks()
# get the maximum value of the colorbar
_, cbar_max = kdeplot.figure.axes[-1].get_ylim()
# change the labels (not the ticks themselves) to a percentage
kdeplot.figure.axes[-1].set_yticklabels([f'{t / cbar_max * 100:.1f} %' for t in cbar_ticks])

ax[1].set_box_aspect(1)
# 
# 
kdeplot=seaborn.kdeplot(x=df['Dp (°N)'], y=df["Tp (s)"], ax=ax[2], fill=True, thresh=0, levels=100, cmap="turbo", cbar=True, 
                    cbar_kws= {'shrink':0.35,}
                    )
# get the current colorbar ticks
cbar_ticks = kdeplot.figure.axes[-1].get_yticks()
# get the maximum value of the colorbar
_, cbar_max = kdeplot.figure.axes[-1].get_ylim()
# change the labels (not the ticks themselves) to a percentage
kdeplot.figure.axes[-1].set_yticklabels([f'{t /cbar_max * 100:.1f} %' for t in cbar_ticks])

ax[2].set_box_aspect(1)
fig.tight_layout()

plt.savefig(f'wave_density_{yesterday}_{area}.png', bbox_inches='tight')
plt.close()

# 
# 
# 
#==============================================================================================
# 
# ----------------------------------------- ROMS PLOT -----------------------------------------
#  
# =============================================================================================
# 
# 
# 
mdl = 'roms+nemo'
romsflP = [FLS[enu] for enu, vv in enumerate(FLS) if 'point' in vv and mdl in vv and f'{NM}' in vv]
romsflA = [FLS[enu] for enu, vv in enumerate(FLS) if 'area' in vv and mdl in vv and f'{NM}' in vv]

flP = xr.open_dataset(romsflP[0])
flA = xr.open_dataset(romsflA[0])

alat = flA.lat_rho
alon = flA.lon_rho

# SURFACE PLOT
for ii in idx:
    uo = flA.u_eastward[ii ]
    vo = flA.v_northward[ii]
    uv = (uo**2 + vo**2)**(0.5)

    plt.close('all')
    plt.style.use("dark_background")

    shpfile = cartopy.io.shapereader.gshhs('i')
    coast = cartopy.io.shapereader.Reader(shpfile)

    shpfile = cartopy.io.shapereader.natural_earth(resolution='50m',name='rivers_lake_centerlines')
    rivers = cartopy.io.shapereader.Reader(shpfile)
    coast_geom = [c for c in coast.geometries()]

    # Bounds sets the ranges for the currents and color range respectivelly.
    bounds = np.linspace(0, np.max(uv), 30)
    norm = colors.BoundaryNorm(boundaries=bounds, ncolors=256)

    # subplot_kw = dict(projection=ccrs.PlateCarree())

    # 
    # >>>
    fig, ax = plt.subplots(figsize=(12, 9))#, subplot_kw=subplot_kw)

    # LIMITS are defined as the ww3 coordinates limits above.
    # ax.set_extent(limits)#, crs=ccrs.PlateCarree())

    # gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=False, color='k', alpha=0.5, linestyle='--')
    # ax.add_geometries(coast_geom, ccrs.PlateCarree(), edgecolor='none', facecolor='k')

    # Currents
    pch = ax.contourf(alon, alat, uv, 
                        levels=30,
                        norm=norm,
                        cmap=plt.cm.turbo)
                        # transform=ccrs.PlateCarree())

    ax.grid(True)
    ax.set_xticklabels([])
    ax.set_yticklabels([])

    # Point position
    plt.plot(plon, plat, 'om', markersize=20)
    
    # Arrows
    spacing = 10
    ax.quiver(alon[::spacing, ::spacing], alat[::spacing, ::spacing], 
            uo[::spacing, ::spacing], vo[::spacing, ::spacing], 
            scale=10, 
            width=0.004, 
            color='k'), 
            # transform=ccrs.PlateCarree())
    # 
    # <<<

    # COLORBAR
    if land == 'NW':
        x0 = ax.get_position().x0 + 0.02
        y0 = ax.get_position().y1 - 0.09
        cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
        ob = offsetbox.AnchoredText(f'ROMS+NEMO {longname}\n{ii} h', loc='upper left',
                                borderpad=0,
                                frameon=False,
                                prop=dict(color='w', size=15))
        ax.add_artist(ob)
        

    elif land == 'SW':
        x0 = ax.get_position().x0 + 0.02
        y0 = ax.get_position().y0 + 0.09
        cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
        ob = offsetbox.AnchoredText(f'ROMS+NEMO {longname}\n{ii} h', loc='lower left',
                                    borderpad=0,
                                    frameon=False,                                
                                    prop=dict(color='w', size=15))
        ax.add_artist(ob)

    elif land == 'W':
        x0 = ax.get_position().x0 + 0.02
        y0 = ax.get_position().y1 - 0.33
        cbaxes = fig.add_axes([x0, y0, 0.18, 0.02])
        ob = offsetbox.AnchoredText(f'ROMS+NEMO {longname}\n{ii} h', loc='center left',
                                    borderpad=0,
                                    frameon=False,
                                    prop=dict(color='w', size=14))
        ax.add_artist(ob)

    cbh = plt.colorbar(pch, cax=cbaxes, orientation='horizontal')
    cbh.set_ticks(np.arange(0, np.round(np.max(uv)), .5))
    cbaxes.tick_params(labelsize=10)

    if land == 'NW':
        cbaxes.set_xlabel('Velocity (m/s)', color='w')
    elif land in ('W', 'SW'):
        cbaxes.set_title('Velocity (m/s)')

    # ax.text(alon.min()+0.1, alat.max()-0.5, f'{ii} h', color='w', fontsize=26, fontweight='bold')

    plt.savefig(f'{mdl}_frcst_sfc_currents_{ii}h_{yesterday}_{area}.png', bbox_inches='tight')
    plt.close()

# 
# ----------------------------------------------------------------------------------
#
# ---------------------------- CURRENT PROFILE PLOT (POINT) ------------------------
# 
# ----------------------------------------------------------------------------------
# 

for ii in idx:
    uo = flP.u_eastward[ii,  :]
    vo = flP.v_northward[ii, :]
    uv = (uo**2 + vo**2)**(0.5)

    hc = 100.

    Zo_rho = (hc * flP.s_rho + flP.Cs_r * flP.h) / (hc + flP.h)

    z_rho = flP.zeta[ii] + (flP.zeta[ii] +flP.h) * Zo_rho
    depth = z_rho.values

    plt.close('all')
    plt.style.use("default")
    plt.plot(vo, depth, '-k', linewidth=2)
    plt.xlim([-1.5, 1.5])
    plt.xlabel('v velocity (m/s)')
    plt.ylabel('depth (m)')
    plt.grid(True)
    plt.text(-1.3, 0, f'{ii} h', verticalalignment='top', 
                                    color='r', fontsize=20, 
                                    fontweight='bold')

    plt.savefig(f'{mdl}_frcst_profile_currents_{ii}h_{yesterday}_{area}.png', bbox_inches='tight')
    plt.close()

# 
# 
# 
# =========================================================================================
# 
#------------------------------------------ GFS PLOT --------------------------------------
# 
# =========================================================================================
# 
# 
# 


gfsflP = [FLS[enu] for enu, vv in enumerate(FLS) if 'point' in vv and 'gfs' in vv and f'{NM}' in vv]
gfsflA = [FLS[enu] for enu, vv in enumerate(FLS) if 'area' in vv and 'gfs' in vv and f'{NM}' in vv]

flP = xr.open_dataset(gfsflP[0])
flA = xr.open_dataset(gfsflA[0])

plat = flP.lat
plon = flP.lon

atm_press = flP.Pair
uw        = flP.Uwind
vw        = flP.Vwind
uvw       = (uw**2 + vw**2)**(0.5)
time      = flP.frc_time


#---------------PLOT ATM
fig, ax1 = plt.subplots(figsize=(12,3))  

color = 'tab:red'
ax1.set_xlabel('Time')  
ax1.set_ylabel('Wind Speed (m/s)', color = color)  
ax1.plot(time, uvw, color = color)  
ax1.tick_params(axis ='y', labelcolor = color)  

# Adding Twin Axes to plot using dataset_2 
ax2 = ax1.twinx()  

color = 'tab:green'
ax2.set_ylabel('Atm Pressure (MSL)', color = color)  
ax2.plot(time, atm_press, color = color)  
ax2.tick_params(axis ='y', labelcolor = color) 

ax1.tick_params(axis='x', rotation=45)
plt.grid()

# plt.rcParams.update({'font.size': 14})
plt.savefig(f'wind_atm_{yesterday}_{area}.png', bbox_inches='tight')
plt.close()



##########################################################################################################
# END!
##########################################################################################################