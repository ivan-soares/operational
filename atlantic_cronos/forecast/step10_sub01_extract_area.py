# 
# WORK TO DO
# 1. HYDRO: instead of to find the nearest grid point, try to interpolate at plon plat.
# 1.1 HYDRO: for the first bulletin, we need an average of the field. 
# It has to be provided, however, the average has to be only of one day I guess.
# Currently, the average is for the whole forecast of 7 days. (check this)
# 2. WW3: check if the point can be obtained in higher resolution grid
# 3. ALL: have to create a line to see if the AREA derived from the POINT
#  fits enterily in the working grid or has to used a bigger grid. This 
#  is linked with n.2.
# 
# 
# This script will replace the former used script "step10_sub02_extract_data.sh"
# as a trial to save time and to improve the hability to subset easier
# many areas of interest. As well as to select points to colect profilers.
# 
# fsobral - Apr 27, 2021
# 
# ################################################################################


import xarray as xr
import numpy as np
import os, sys


# ===============================================================================

yesterday = os.getenv('yesterday')
ogcmfile  = os.getenv('ogcmfile')
ogcm      = os.getenv('ogcm')
__dir     = os.getenv('__dir')
sto       = os.path.join(os.getenv('stodir'), yesterday)

romsfile = sys.argv[1]
sat1file = sys.argv[2]
plon     = float(sys.argv[3])
plat     = float(sys.argv[4])
W        = float(sys.argv[5])
E        = float(sys.argv[6])
S        = float(sys.argv[7])
N        = float(sys.argv[8])
name     = sys.argv[9]


fls = [romsfile, ogcmfile, sat1file]

# 
# =================================================================================
# 
# ====================================== ROMS =====================================
# 
# =================================================================================
# 
for FLS in fls:

    # Reading model
    with xr.open_dataset(FLS) as fl:

        if FLS == romsfile:
            lon  = fl.lon_rho[0, :].values
            lat  = fl.lat_rho[:, 0].values
            temp = fl.temp
            salt = fl.salt
            uo   = fl.u_eastward
            vo   = fl.v_northward
            zeta = fl.zeta
            csr  = fl.Cs_r 
            h    = fl.h 

        elif FLS == ogcmfile:
            if ogcm == 'nemo':
                lon  = fl.longitude.values
                lat  = fl.latitude.values
                temp = fl.thetao
                salt = fl.so
                uo   = fl.uo
                vo   = fl.vo
                zeta = fl.zos
                TIME = np.arange(0, 2) # 00 12 next day

            elif ogcm == 'glby':
                lon  = fl.lon.values
                lat  = fl.lat.values
                temp = fl.water_temp
                salt = fl.salinity
                uo   = fl.water_u
                vo   = fl.water_v
                zeta = fl.surf_el
                TIME = np.arange(0, 5) # 00 06 12 18 24 next day
        
        # To simplification reasons, ug, vg and sla will be names as uo, vo, zeta, even 
        # if the meaning is not exactly the same.
        elif FLS == sat1file:
            lon  = fl.longitude.values
            lat  = fl.latitude.values
            uo   = fl.ugos
            vo   = fl.vgos
            zeta = fl.sla


        # ---------------------------------- FINDING INDEX --------------------------------
        # If WESN and POINT exist, finding indexes to slice below
        if ~np.isnan(W) and ~np.isnan(plon):
            xi_bg  = np.argsort(np.abs(np.abs(lon) - np.abs(W)))[0]
            xi_nd  = np.argsort(np.abs(np.abs(lon) - np.abs(E)))[0]
            eta_bg = np.argsort(np.abs(np.abs(lat) - np.abs(S)))[0]
            eta_nd = np.argsort(np.abs(np.abs(lat) - np.abs(N)))[0]
            # 
            xi_P    = np.argsort(np.abs(np.abs(lon) - np.abs(plon)))[0]
            eta_P   = np.argsort(np.abs(np.abs(lat) - np.abs(plat)))[0]

            # To be used into the models that has to use value not index
            p_lon = lon[xi_P]
            p_lat = lat[eta_P]


        # When WESN doesn't exist but POINT do exist. Select an default area around it.
        # Square area of 5° each side
        elif np.isnan(W) and ~np.isnan(plon):
            W = plon - 5
            E = plon + 5
            S = plat - 5
            N = plat + 5
            
            xi_bg  = np.argsort(np.abs(np.abs(lon) - np.abs(W)))[0]
            xi_nd  = np.argsort(np.abs(np.abs(lon) - np.abs(E)))[0]
            eta_bg = np.argsort(np.abs(np.abs(lat) - np.abs(S)))[0]
            eta_nd = np.argsort(np.abs(np.abs(lat) - np.abs(N)))[0]
            # 
            xi_P    = np.argsort(np.abs(np.abs(lon) - np.abs(plon)))[0]
            eta_P   = np.argsort(np.abs(np.abs(lat) - np.abs(plat)))[0]

            # To be used into the models that has to use value not index
            p_lon = lon[xi_P]
            p_lat = lat[eta_P]

        # When POINT doesn't exist but WESN do. 
        # Find a point in the most approximate centered position.
        elif np.isnan(plon) and ~np.isnan(W):

            xi_bg  = np.argsort(np.abs(np.abs(lon) - np.abs(W)))[0]
            xi_nd  = np.argsort(np.abs(np.abs(lon) - np.abs(E)))[0]
            eta_bg = np.argsort(np.abs(np.abs(lat) - np.abs(S)))[0]
            eta_nd = np.argsort(np.abs(np.abs(lat) - np.abs(N)))[0]
            # 
            idx_lon = int((xi_nd + xi_bg)/2)
            idx_lat = int((eta_nd + eta_bg)/2)
            
            p_lon = lon[idx_lon]
            p_lat = lat[idx_lat]
                
            xi_P    = np.argsort(np.abs(np.abs(lon) - np.abs(p_lon)))[0]
            eta_P   = np.argsort(np.abs(np.abs(lat) - np.abs(p_lat)))[0]
        

        # ---------------------------------- SUBSETTING --------------------------------
        # AREA
        if FLS == romsfile:
            layers = -1 #np.arange(-4, 0)
            uA   = uo.sel(xi_rho=slice(xi_bg, xi_nd), eta_rho=slice(eta_bg, eta_nd)).isel(ocean_time=np.arange(0, 24), s_rho=layers)
            vA   = vo.sel(xi_rho=slice(xi_bg, xi_nd), eta_rho=slice(eta_bg, eta_nd)).isel(ocean_time=np.arange(0, 24), s_rho=layers)
            tA   = temp.sel(xi_rho=slice(xi_bg, xi_nd), eta_rho=slice(eta_bg, eta_nd)).isel(ocean_time=np.arange(0, 24), s_rho=layers)
            sA   = salt.sel(xi_rho=slice(xi_bg, xi_nd), eta_rho=slice(eta_bg, eta_nd)).isel(ocean_time=np.arange(0, 24), s_rho=layers)
            zA   = zeta.sel(xi_rho=slice(xi_bg, xi_nd), eta_rho=slice(eta_bg, eta_nd)).isel(ocean_time=np.arange(0, 24))
            hA   = h.sel(xi_rho=slice(xi_bg, xi_nd), eta_rho=slice(eta_bg, eta_nd))
            csrA = csr.isel(s_rho=layers)

            area = xr.merge([uA, vA, tA, sA, zA, hA, csrA])


        elif FLS == ogcmfile:

            layers = 0 #np.arange(0, 10)
            if ogcm == 'nemo':
                uA = uo.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=TIME, depth=layers)
                vA = vo.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=TIME, depth=layers)                
                tA = temp.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=TIME, depth=layers)
                sA = salt.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=TIME, depth=layers)
                zA = zeta.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=TIME)
            else:
                uA = uo.sel(lon=slice(W, E), lat=slice(S, N)).isel(time=TIME, depth=layers)
                vA = vo.sel(lon=slice(W, E), lat=slice(S, N)).isel(time=TIME, depth=layers)                
                tA = temp.sel(lon=slice(W, E), lat=slice(S, N)).isel(time=TIME, depth=layers)
                sA = salt.sel(lon=slice(W, E), lat=slice(S, N)).isel(time=TIME, depth=layers)
                zA = zeta.sel(lon=slice(W, E), lat=slice(S, N)).isel(time=TIME)

            area = xr.merge([uA, vA, tA, sA, zA])

        elif FLS == sat1file:
            uA = uo.sel(longitude=slice(W, E), latitude=slice(S, N))
            vA = vo.sel(longitude=slice(W, E), latitude=slice(S, N))
            zA = zeta.sel(longitude=slice(W, E), latitude=slice(S, N))

            area = xr.merge([uA, vA, zA])
        
        # POINT PROFILE
        if FLS == romsfile:
            uP   = uo.isel(xi_rho=xi_P , eta_rho=eta_P, ocean_time=np.arange(0, 24))
            vP   = vo.isel(xi_rho=xi_P, eta_rho=eta_P, ocean_time=np.arange(0, 24))
            tP   = temp.isel(xi_rho=xi_P , eta_rho=eta_P, ocean_time=np.arange(0, 24))
            sP   = salt.isel(xi_rho=xi_P, eta_rho=eta_P, ocean_time=np.arange(0, 24))
            zP   = zeta.isel(xi_rho=xi_P, eta_rho=eta_P, ocean_time=np.arange(0, 24))
            hP   = h.isel(xi_rho=xi_P, eta_rho=eta_P)

            point = xr.merge([uP, vP, tP, sP, hP, zP, csr])

        elif FLS == ogcmfile:
            if ogcm == 'nemo':
                uP = uo.sel(longitude=p_lon, latitude=p_lat).isel(time=TIME)
                vP = vo.sel(longitude=p_lon, latitude=p_lat).isel(time=TIME)
                tP = temp.sel(longitude=p_lon , latitude=p_lat).isel(time=TIME)
                sP = salt.sel(longitude=p_lon, latitude=p_lat).isel(time=TIME)
            else:
                uP = uo.sel(lon=p_lon, lat=p_lat).isel(time=TIME)
                vP = vo.sel(lon=p_lon, lat=p_lat).isel(time=TIME)
                tP = temp.sel(lon=p_lon , lat=p_lat).isel(time=TIME)
                sP = salt.sel(lon=p_lon, lat=p_lat).isel(time=TIME)

            point = xr.merge([uP, vP, tP, sP])

        
        # Choosing the right name
        if FLS == romsfile:
            Afullname = f'area_roms+{ogcm}_{name}_{yesterday}.nc'
            Pfullname = f'point_roms+{ogcm}_{name}_{yesterday}.nc'                        

        elif FLS == ogcmfile:
            Afullname = f'area_{ogcm}_{name}_{yesterday}.nc'
            Pfullname = f'point_{ogcm}_{name}_{yesterday}.nc'
                        
        elif FLS == sat1file:
            Afullname = f'area_sat1_{name}_{yesterday}.nc'

        # SAVING netcdf files
        area.to_netcdf(Afullname, 'w')

        if FLS != sat1file:
            point.to_netcdf(Pfullname, 'w')


# =================================================================================
#
#
# ====================================== WW3 =====================================
#
#
# =================================================================================

# WW3 we use needed point/area to find which file will be used, to 
# try the best resolution output (three grid with != resol.).
# The opposite than hidrodynamic loop above.

lon_bca = np.arange(-48.4, -35.475004, 0.025)
lat_bca = np.arange(-25.4, -19.475   , 0.025)
lon_sao = np.arange(-60  , -24.975   , 0.125)
lat_sao = np.arange(-38  , 10.125    , 0.125)
lon_atl = np.arange(-81  , 30.5      , 0.5  )
lat_atl = np.arange(-80  , 65.5      , 0.5  )


# Checking on where plon plat is best located in the three WW3 grids available
# Starting from the highest to the lowest (bca>sao>atl) resolution grid.

# If AREA is provided...
if ~np.isnan(W):
    if W >= lon_bca[0] and E <= lon_bca[-1] and S >= lat_bca[0]  and N <= lat_bca[-1]:
        ww3file = os.path.join(sto, f'ww3_his_bca0.025_{yesterday}.nc')
        lon = lon_bca
        lat = lat_bca
    else:
        if W >= lon_sao[0] and E <= lon_sao[-1] and S >= lat_sao[0] and N <= lat_sao[-1]:
            ww3file = os.path.join(sto, f'ww3_his_sao0.125_{yesterday}.nc')
            lon = lon_sao
            lat = lat_sao
        else:
            if W >= lon_atl[0] and E <= lon_atl[-1] and S >= lat_atl[0] and N <= lat_atl[-1]:
                ww3file = os.path.join(sto, f'ww3_his_atl0.500_{yesterday}.nc')
                lon = lon_atl
                lat = lat_atl
            else:
                print('Error... AREA is out of bound.')

# if AREA is not provided, only POINT
else:
    if lon_bca[0] < plon < lon_bca[-1] and lat_bca[0] < plat < lat_bca[-1]:
        ww3file = os.path.join(sto, f'ww3_his_bca0.025_{yesterday}.nc')
        lon = lon_bca
        lat = lat_bca
    else:
        if lon_sao[0] < plon < lon_sao[-1] and lat_sao[0] < plat < lat_sao[-1]:
            ww3file = os.path.join(sto, f'ww3_his_sao0.125_{yesterday}.nc')
            lon = lon_sao
            lat = lat_sao
        else:
            if lon_atl[0] < plon < lon_atl[-1] and lat_atl[0] < plat < lat_atl[-1]:
                ww3file = os.path.join(sto, f'ww3_his_atl0.500_{yesterday}.nc')
                lon = lon_atl
                lat = lat_atl
            else:
                print('Error... POINT is out of bound.')


# # ---------------------------------- FINDING INDEX --------------------------------
# When WESN doesn't exist but POINT do exist. Select an default area around it.
# Square area of 5° each side
if np.isnan(W) and ~np.isnan(plon):
    W = plon - 5
    E = plon + 5
    S = plat - 5
    N = plat + 5
    
# When POINT doesn't exist but WESN do. 
# Find a point in the most approximate centered position.
elif np.isnan(plon) and ~np.isnan(W):

    ln_bg = np.argsort(np.abs(np.abs(lon) - np.abs(W)))[0]
    ln_nd = np.argsort(np.abs(np.abs(lon) - np.abs(E)))[0]
    lt_bg = np.argsort(np.abs(np.abs(lat) - np.abs(S)))[0]
    lt_nd = np.argsort(np.abs(np.abs(lat) - np.abs(N)))[0]
    # 
    idx_lon = int((ln_nd + ln_bg)/2)
    idx_lat = int((lt_nd + lt_bg)/2)
    
    plon = lon[idx_lon]
    plat = lat[idx_lat]

# Reading WW3 file
with xr.open_dataset(ww3file) as fl:

    # AREA 
    hsA = fl.hs.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=np.arange(0,24))
    fpA = fl.fp.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=np.arange(0,24))
    dpA = fl.dp.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=np.arange(0,24))

    area = xr.merge([hsA, fpA, dpA])

    # POINT SPECIFIC (!INTERPOLATING!)
    # time_spacing = 3

    # Interpolating HS at the plon plat.
    hsP   = fl.hs.interp(longitude=plon,latitude=plat)#[::time_spacing]
    phs0P = fl.phs0.interp(longitude=plon,latitude=plat)#[::time_spacing]
    phs1P = fl.phs1.interp(longitude=plon,latitude=plat)#[::time_spacing]
    phs2P = fl.phs2.interp(longitude=plon,latitude=plat)#[::time_spacing]

    tpP   = 1/fl.fp.interp(longitude=plon,latitude=plat)#[::time_spacing]
    ptp0P = fl.ptp0.interp(longitude=plon,latitude=plat)#[::time_spacing]
    ptp1P = fl.ptp1.interp(longitude=plon,latitude=plat)#[::time_spacing]
    ptp2P = fl.ptp2.interp(longitude=plon,latitude=plat)#[::time_spacing]

    dpP   = fl.dp.interp(longitude=plon,latitude=plat)#[::time_spacing]
    pdir0P = fl.pdir0.interp(longitude=plon,latitude=plat)#[::time_spacing]
    pdir1P = fl.pdir1.interp(longitude=plon,latitude=plat)#[::time_spacing]
    pdir2P = fl.pdir2.interp(longitude=plon,latitude=plat)#[::time_spacing]

    point = xr.merge([hsP, phs0P, phs1P, phs2P, tpP, ptp0P, ptp1P, ptp2P, dpP, pdir0P, pdir1P, pdir2P])
    
# Choosing the right name
_nm = ww3file.split('/')[-1].split('_')[-2]
Afullname = f'area_ww3_{_nm}_{name}_{yesterday}.nc'
Pfullname = f'point_ww3_{_nm}_{name}_{yesterday}.nc'
                

# SAVING netcdf files
area.to_netcdf(Afullname, 'w')
point.to_netcdf(Pfullname, 'w')



# ################################################################################
#
#
# ====================================== GFS =====================================
#
#
# ################################################################################


lon_glo = np.arange(0, 360, 0.5)
lat_glo = np.arange(-90, 90.5, 0.5)
lon_brz = np.arange(-53, -23.5, 0.5)
lat_brz = np.arange(-31, 11.5, 0.5)

# OBS: For GFS it has to be in 0-360° longitude (only global, brz is negative). This script only works for negative 
#      longitude values given!!! 
plon_brz = plon
plon_glo = 360 + plon
W_brz = W
E_brz = E
W_glo = 360 + W
E_glo = 360 + E


#                       >>>> CHECKING WHICH FILE WILL BE USED <<<<<
# Checking on where plon plat is best located in the three GFS grids available
# Starting from the highest to the lowest (brz>glo) resolution grid.

# If AREA is provided...
if ~np.isnan(W_brz):
    if W_brz >= lon_brz[0] and E_brz <= lon_brz[-1] and S >= lat_brz[0] and N <= lat_brz[-1]:
        gfsfile = os.path.join(sto, f'gfs_brz0.50_{yesterday}.nc')
        lon = lon_brz
        lat = lat_brz
        plon = plon_brz
        E = E_brz
        W = W_brz
    else:
        if W_glo >= lon_glo[0] and E_glo <= lon_glo[-1] and S >= lat_glo[0] and N <= lat_glo[-1]:
            gfsfile = os.path.join(sto, f'gfs_{yesterday}.nc')
            lon = lon_glo
            lat = lat_glo
            plon = plon_glo
            E = E_glo
            W = W_glo                
        else:
            print('Error... AREA is out of bound.')

# if AREA is not provided, only POINT
else:
    if lon_brz[0] < plon_brz < lon_brz[-1] and lat_brz[0] < plat < lat_brz[-1]:
        gfsfile = os.path.join(sto, f'gfs_brz0.50_{yesterday}.nc')
        lon = lon_brz
        lat = lat_brz
        plon = plon_brz
        E = E_brz
        W = W_brz
    else:
        if lon_glo[0] < plon_glo < lon_glo[-1] and lat_glo[0] < plat < lat_glo[-1]:
            gfsfile = os.path.join(sto, f'gfs_{yesterday}.nc')
            lon = lon_glo
            lat = lat_glo
            plon = plon_glo
            E = E_glo
            W = W_glo
        else:
            print('Error... POINT is out of bound.')



# # ---------------------------------- FINDING INDEX --------------------------------
# When WESN doesn't exist but POINT do exist. Select an default area around it.
# Square area of 5° each side
if np.isnan(W) and ~np.isnan(plon):
    W = plon - 5
    E = plon + 5
    S = plat - 5
    N = plat + 5
    
# When POINT doesn't exist but WESN do. 
# Find a point in the most approximate centered position.
elif np.isnan(plon) and ~np.isnan(W):

    ln_bg  = np.argsort(np.abs(np.abs(lon) - np.abs(W)))[0]
    ln_nd  = np.argsort(np.abs(np.abs(lon) - np.abs(E)))[0]
    lt_bg = np.argsort(np.abs(np.abs(lat) - np.abs(S)))[0]
    lt_nd = np.argsort(np.abs(np.abs(lat) - np.abs(N)))[0]
    # 
    idx_lon = int((ln_nd + ln_bg)/2)
    idx_lat = int((lt_nd + lt_bg)/2)
    
    plon = lon[idx_lon]
    plat = lat[idx_lat]

# Reading WW3 file
with xr.open_dataset(gfsfile) as fl:

    # AREA 
    if 'brz' in gfsfile:
        pairA = fl.Pair.sel(lon=slice(W, E) , lat=slice(S, N)).isel(frc_time=np.arange(0,24))
        uwA   = fl.Uwind.sel(lon=slice(W, E), lat=slice(S, N)).isel(frc_time=np.arange(0,24))
        vwA   = fl.Vwind.sel(lon=slice(W, E), lat=slice(S, N)).isel(frc_time=np.arange(0,24))
    else:
        pairA = fl.PRMSL_meansealevel.sel(longitude=slice(W, E) , latitude=slice(S, N)).isel(time=np.arange(0,24))
        uwA   = fl.UGRD_10maboveground.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=np.arange(0,24))
        vwA   = fl.VGRD_10maboveground.sel(longitude=slice(W, E), latitude=slice(S, N)).isel(time=np.arange(0,24))
    

    area = xr.merge([pairA, uwA, vwA])

    # POINT SPECIFIC (!INTERPOLATING!)
    # Interpolating HS at the plon plat.
    if 'brz' in gfsfile:
        pairP = fl.Pair.interp(lon=plon ,lat=plat)
        uwP   = fl.Uwind.interp(lon=plon,lat=plat)
        vwP   = fl.Vwind.interp(lon=plon,lat=plat)
    else:
        pairP = fl.PRMSL_meansealevel.interp(longitude=plon ,latitude=plat)
        uwP   = fl.UGRD_10maboveground.interp(longitude=plon,latitude=plat)
        vwP   = fl.VGRD_10maboveground.interp(longitude=plon,latitude=plat)


    point = xr.merge([pairP, uwP, vwP])

    
# Choosing the right name
if 'brz' in gfsfile:
    _nm = gfsfile.split('/')[-1].split('_')[-2]
    Afullname = f'area_gfs_{_nm}_{name}_{yesterday}.nc'
    Pfullname = f'point_gfs_{_nm}_{name}_{yesterday}.nc'
else:
    Afullname = f'area_gfs_{name}_{yesterday}.nc'
    Pfullname = f'point_gfs_{name}_{yesterday}.nc'                    


# SAVING netcdf files
area.to_netcdf(Afullname, 'w')
point.to_netcdf(Pfullname, 'w')


##########################################################################################################
# END!
##########################################################################################################
