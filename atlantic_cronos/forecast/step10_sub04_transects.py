'''
TO-DO LIST

- Fixar os ticks e ticklabels da colorbar para padronizar (ver como é no contourf...)
- Pode ser incluido o rotacionamento do transect.
- se esta for uma função, poderia ter a opção de trocar o colormap sem ter que abrir o script

'''


''' ========================================================================='''
# import matplotlib
# matplotlib.use('Agg')

import os, sys
import numpy as np
from netCDF4 import Dataset
import matplotlib.pyplot as plt
from matplotlib import rcParams, cm
import cmocean as cmo
from datetime import date, timedelta
from scipy.interpolate import griddata


rcParams['font.size'] = 10
rcParams['font.weight'] = 'bold'

''' ========================================================================='''


'''------------------------- begin aux_function -----------------------------'''
def transp_calc(file, lati):
        '''
            return(lat, dist, prof, vel, Sv)

        '''
        if 'roms+nemo' in file or 'roms+glby' in file:
            lat   = 'lat'
            lon   = 'lon'
            depth = 'depth'
            temp  = 'temp'
            salt  = 'salt'
            vo    = 'v'
        elif 'nemo' in file:
            lat   = 'latitude'
            lon   = 'longitude'
            depth = 'depth'
            salt  = 'so'
            temp  = 'thetao'
            vo    = 'vo'
        elif 'glby' in file:
            lat   = 'lat'
            lon   = 'lon'
            depth = 'depth'
            salt  = 'salinity'
            temp  = 'water_temp'
            vo    = 'water_v'

        lat  = Dataset(file)[lat][:]
        lon  = Dataset(file)[lon][:]  ; nlon = len(lon)
        dpth = Dataset(file)[depth][:]; ndep = len(dpth)
        
        salt = (Dataset(file)[salt][:]).squeeze()
        temp = (Dataset(file)[temp][:]).squeeze()
        vel  = (Dataset(file)[vo][:]).squeeze()
        dist = np.array([lon] * ndep)
        prof = np.transpose([-dpth] * nlon)

        # Selecting BC's area on the transect
        cond1 = dist >= bc[0]
        cond2 = dist <= bc[1]
        cond3 = prof >= bc[2]
        cond4 = prof <= bc[3]
        xbc =  cond1 & cond2 & cond3 & cond4

        dx = 0.05 * twopir * np.cos(lat * np.pi/180.)/360.
        dz, tmp = np.gradient(prof)
        vzao = -vel * dx * dz

        if lati == '07S' or lati == '11S':
            vzao[vzao < 0] = 0
            vzao[np.isnan(vzao)] = 0
        else:
            vzao[vzao > 0] = 0
            vzao[np.isnan(vzao)] = 0

        transp1 = np.sum(vzao[xbc])

        Sv = "%5.3f" % (np.round(transp1 * 1.e2) / 1.e8) +' Sv'

        return(lat, dist, prof, vel, Sv, salt, temp)
    
''' ------------------------------ end aux_function --------------------------------'''

# 
# 
# 
# 
# ======================================================================================
#
#
#
#

print(' ... Creating transect figures')

yesterday = os.getenv('yesterday')

#colormap you want the plots (cm.get_cmap('jet') another option we use)
cmp1 = cmo.cm.balance
cmp2 = [cmo.cm.haline, cmo.cm.thermal]

LATI = ['07S', '11S', '22S', '23S', '25S', '28S']

for lati in LATI:

    f1 = 'across-shelf_' + lati +  '_' + yesterday +  '_roms+nemo.nc'
    f2 = 'across-shelf_' + lati +  '_' + yesterday +  '_roms+glby.nc'
    f3 = 'across-shelf_' + lati +  '_' + yesterday +  '_nemo.nc'
    f4 = 'across-shelf_' + lati +  '_' + yesterday +  '_glby.nc'

    if lati == '07S':
        dp     = [-33.75, -50.0];              # local do texto do Sv
        bc     = [-34.5, -33.75, -500., 0.]    # area to calculate BC
        axis01 = [-34.8, -33, -500, 0]         # First subplot delimiting axis
        axis02 = [-34.8, -33, -3000, -500]     # Second subplot delimiting axis

    elif lati == '11S':
        dp     = [-35.5, -50.0];
        bc     = [-36.5, -35.0, -500., 0.]
        axis01 = [-37, -33.2, -500, 0]
        axis02 = [-37, -33.2, -3000, -500]

    elif lati == '22S':
        dp     = [-40.0, -50.0];
        bc     = [-40.5, -39.0, -500., 0.]
        axis01 = [-41, -37.5, -500, 0]
        axis02 = [-41, -37.5, -3000, -500]

    elif lati == '23S':
        dp     = [-40.75, -50.0]
        bc     = [-41.5, -39.0, -500., 0.]
        axis01 = [-42.5, -37.5, -500, 0]
        axis02 = [-42.5, -37.5, -3000, -500]

    elif lati == '25S':
        dp     = [-44.75, -50.0]
        bc     = [-46.0, -43.0, -500., 0.]
        axis01 = [-48.5, -37.5, -500, 0]
        axis02 = [-48.5, -37.5, -3000, -500]

    elif lati == '28S':
        dp     = [-46.0, -50.0];
        bc     = [-48.5, -44.0, -500., 0.]
        axis01 = [-48.7, -37.5, -500 , 0]
        axis02 = [-48.7, -37.5, -3000, -500]

    else:
        print('wrong latitude')

    # Earth's circunference
    twopir = 2 * np.pi * 6.37e6


    #--------------------------- ROMS+NEMO

    lat1, dist1, prof1, vel1, Sv1, salt1, temp1 = transp_calc(f1, lati)

    # -------------------------------------- ROMS+GLBY

    lat2, dist2, prof2, vel2, Sv2, salt2, temp2 = transp_calc(f2, lati)
    
    # -------------------------------------- NEMO

    lat3, dist3, prof3, vel3, Sv3, salt3, temp3 = transp_calc(f3, lati)
    
    # -------------------------------------- GLBY

    lat4, dist4, prof4, vel4, Sv4, salt4, temp4 = transp_calc(f4, lati)
    
    
    # To remove the mysterious gaps in nemo data with the same resolution of glby   
    veld = vel3.data
    veld[veld == vel3.fill_value] = np.nan

    x    = ~np.isnan(veld)
    veld = veld[x]

    togr = np.array([dist3[x].ravel(), prof3[x].ravel()]).transpose(1, 0)
    vel3b = griddata(togr, veld, (dist4.ravel(), prof4.ravel())).reshape(dist4.shape)
    vel3b[np.isnan(vel4)] = np.nan

    vel3b[np.isnan(vel3b)] = -9999
    vel3 = np.ma.masked_where(vel3b == -9999, vel3b)
    np.ma.set_fill_value(vel3, -9999)

    
    # --------------------------------- making figures
    plt.close('all')
    
    # Nemo now has Glby dimensions, so has to use them    
    DIST = [dist1, dist2, 
            dist4, dist4]  
           
    PROF = [prof1, prof2, 
            prof4, prof4]  

    VEL  = [vel1, vel2, 
            vel3, vel4]

    SV   = [Sv1, Sv2, 
            Sv3, Sv4]
    
    
    TITLE = ['ROMS+NEMO V  at latitude ' + str(lat1[0]),
             'ROMS+GLBY V at latitude  ' + str(lat2[0]),
             'NEMO V at latitude  '      + str(lat3[0]),
             'GLBY V at latitude  '      + str(lat4[0])]

    OUT = ['across_vo_' + lati + '_roms+nemo_' + yesterday + '.png',
           'across_vo_' + lati + '_roms+glby_' + yesterday + '.png',
           'across_vo_' + lati + '_nemo_'      + yesterday + '.png',
           'across_vo_' + lati + '_glby_'      + yesterday + '.png']


    for dd, pp, vv, sv, tt, out  in zip(DIST, PROF, VEL, SV, TITLE, OUT):
        #
        fig, ax = plt.subplots(2, 1, figsize=(7, 8))
                
        im = ax[0].contourf(dd, pp, vv, levels=100, cmap=cmp1)
        ax[0].contour(dd, pp, vv, levels=2, colors='k')
        
        # Making land as gray
        msk = vv.mask
        vv_ma = np.ma.array(vv.data, mask=~msk)
        ax[0].contourf(dd, pp, vv_ma, cmap='gray')
    
        ax[0].set_xlim(axis01[0], axis01[1])
        ax[0].set_ylim(axis01[2], axis01[3])
        ax[0].set_xticklabels([])
        ax[0].set_yticks([-500, -400, -300, -200, -100, 0])
        ax[0].set_yticklabels([' ' ,400, 300, 200, 100, 0]) #putting depth as positive
        ax[0].set_title(tt)
        ax[0].set_ylabel('Depth (m)')
        ax[0].text(dp[0], dp[1], sv, color='r')
        
        gpos0 = ax[0].get_position()
        ax[0].set_position([gpos0.xmin+0.05, gpos0.ymin-0.11, gpos0.width-0.1, gpos0.height+0.1])
        
        cbar_ax = fig.add_axes([0.126, 0.08, 0.775, 0.025])

        if lati == '07S':
            cbar = fig.colorbar(im, cax=cbar_ax, orientation='horizontal')
            cbar.mappable.set_clim(-1.3, 1.3)
        elif lati == '11S':
            cbar = fig.colorbar(im, cax=cbar_ax, orientation='horizontal')
            cbar.mappable.set_clim(-1, 1)
        else:
            cbar = fig.colorbar(im, cax=cbar_ax, orientation='horizontal')
            cbar.mappable.set_clim(-0.5, 0.5)
            
        #
        # Second subplot
        #
        im1 = ax[1].contourf(dd, pp, vv, levels=100, cmap=cmp1) 
        ax[1].contour(dd, pp, vv, levels=2, colors='k')

        # Making land as gray
        msk = vv.mask
        vv_ma = np.ma.array(vv.data, mask=~msk)
        ax[1].contourf(dd, pp, vv_ma, cmap='gray')
        
        ax[1].set_xlim(axis02[0], axis02[1])
        
        # Adjusting colorbar xtick
        if lati == '07S':
            cbar = fig.colorbar(im1, cax=cbar_ax, orientation='horizontal')
            cbar.mappable.set_clim(-1.3, 1.3)
            ax[1].set_xticks(np.arange(axis02[0], axis02[1], 0.5))
            
        elif lati in ['11S', '22S', '23S']:
            cbar = fig.colorbar(im1, cax=cbar_ax, orientation='horizontal')
            cbar.mappable.set_clim(-1, 1)
            ax[1].set_xticks(np.arange(axis02[0], axis02[1], 1))
            
        elif lati in ['25S', '28S']:
            cbar = fig.colorbar(im1, cax=cbar_ax, orientation='horizontal')
            cbar.mappable.set_clim(-0.5, 0.5)
            ax[1].set_xticks(np.arange(axis02[0], axis02[1], 2))
            
            
        ax[1].set_ylim(axis02[2], axis02[3])
        ax[1].set_yticks([-3000, -2500, -2000, -1500, -1000, -500])
        ax[1].set_yticklabels([3000, 2500, 2000, 1500, 1000, 500])
        
        gpos1 = ax[1].get_position()
        ax[1].set_position([gpos1.xmin+0.05, gpos1.ymin+0.05, gpos1.width-0.1, gpos1.height-0.1])
        #

        if lati == '07S':
            cbar.mappable.set_clim(-1.3, 1.3)
        elif lati == '11S':
            cbar.mappable.set_clim(-1, 1)
        else:
            cbar.mappable.set_clim(-0.5, 0.5)

        cbar.set_label('Speed (m/s)', fontsize=12, fontweight='bold')
        

        # Saving figure
        fig.savefig(out, bbox_inches='tight')
        plt.close(fig)
        
        
    #
    # -------------------------- Temperature and Salinity Figures ---------------
    #

    DIST = [dist1, dist2, 
            dist3, dist4]  
           
    PROF = [prof1, prof2, 
            prof3, prof4]  
    
    SALT = [salt1, salt2, salt3, salt4]
    TEMP = [temp1, temp2, temp3, temp4]
    
    vrb     = [  'sal',         'temp']
    vrb_unt = ['(psu)', '$(^\circ C)$']  
    
    nms = ['ROMS+NEMO', 'ROMS+GLBY', 'NEMO', 'GLBY']
    
    
    for ENU, VRB in enumerate([SALT, TEMP]):
        for enu, (dd, pp, vv)  in enumerate(zip(DIST, PROF, VRB)):
            #
            fig, ax = plt.subplots(2, 1, figsize=(7, 8))
                        
            im = ax[0].contourf(dd, pp, vv, levels=100, cmap=cmp2[ENU])
            ax[0].contour(dd, pp, vv, levels=10, colors='k')

            # Making land as gray
            msk = vv.mask
            vv_ma = np.ma.array(vv.data, mask=~msk)
            ax[0].contourf(dd, pp, vv_ma, cmap='gray')

            ax[0].set_xlim(axis01[0], axis01[1])
            ax[0].set_ylim(axis01[2], axis01[3])
            ax[0].set_xticklabels([])
            ax[0].set_yticks([-500, -400, -300, -200, -100, 0])
            ax[0].set_yticklabels([' ' ,400, 300, 200, 100, 0]) #putting depth as positive
            ax[0].set_ylabel('Depth (m)')

            tt = f'{nms[enu]} {vrb[ENU]}  at latitude {lati}'
            ax[0].set_title(tt)
            

            gpos0 = ax[0].get_position()
            ax[0].set_position([gpos0.xmin+0.05, gpos0.ymin-0.11, gpos0.width-0.1, gpos0.height+0.1])

            cbar_ax = fig.add_axes([0.126, 0.08, 0.775, 0.025])

            cbar = fig.colorbar(im, cax=cbar_ax, orientation='horizontal')
#             if lati == '07S':
#                 cbar.mappable.set_clim(-1.3, 1.3)
                
#             elif lati == '11S':
#                 cbar.mappable.set_clim(-1, 1)
                
#             else:
#                 cbar.mappable.set_clim(-0.5, 0.5)

            #
            # Second subplot
            #
            im1 = ax[1].contourf(dd, pp, vv, levels=100, cmap=cmp2[ENU]) 
            ax[1].contour(dd, pp, vv, levels=10, colors='k')

            # Making land as gray
            msk = vv.mask
            vv_ma = np.ma.array(vv.data, mask=~msk)
            ax[1].contourf(dd, pp, vv_ma, cmap='gray')

            ax[1].set_xlim(axis02[0], axis02[1])

            cbar = fig.colorbar(im1, cax=cbar_ax, orientation='horizontal')
            
            # Adjusting colorbar xtick
            if lati == '07S':                
                ax[1].set_xticks(np.arange(axis02[0], axis02[1], 0.5))

            elif lati in ['11S', '22S', '23S']:
                ax[1].set_xticks(np.arange(axis02[0], axis02[1], 1))

            elif lati in ['25S', '28S']:
                ax[1].set_xticks(np.arange(axis02[0], axis02[1], 2))


            ax[1].set_ylim(axis02[2], axis02[3])
            ax[1].set_yticks([-3000, -2500, -2000, -1500, -1000, -500])
            ax[1].set_yticklabels([3000, 2500, 2000, 1500, 1000, 500])

            gpos1 = ax[1].get_position()
            ax[1].set_position([gpos1.xmin+0.05, gpos1.ymin+0.05, gpos1.width-0.1, gpos1.height-0.1])
            #

#             if lati == '07S':
#                 cbar.mappable.set_clim(-1.3, 1.3)
#             elif lati == '11S':
#                 cbar.mappable.set_clim(-1, 1)
#             else:
#                 cbar.mappable.set_clim(-0.5, 0.5)

            cbar.set_label(vrb_unt[ENU], fontsize=12, fontweight='bold')

            # Saving figure
            out = f'across_{vrb[ENU]}_{lati}_{nms[enu].lower()}_{yesterday}.png'            
            fig.savefig(out, bbox_inches='tight')
            plt.close(fig)

'''END'''