############################ *** importing libraries *** ##########################################

#!/usr/bin/python

import os.path, gc, sys
home = os.path.expanduser('~')
sys.path.append(home + '/scripts/python/')

import numpy as np
import time as tempo

from netCDF4 import Dataset

############################ *** introdu *** ######################################################

print(' ')
print(' +++> STARTING python program to write NEMO 3dinst vars all together <+++ ')
print(' ')

start_time = tempo.time()

############################ *** file names *** ###################################################

in1 = str(sys.argv[1])
in2 = str(sys.argv[2])
out = str(sys.argv[3])

infile1 = Dataset(in1,'r')
infile2 = Dataset(in2,'r')
outfile = Dataset(out,'r+')

############### *** read from inpfile & write on outfile *** ######################################

outfile.variables['time'] [:] = infile1.variables['time'][:]
outfile.variables['latitude'] [:] = infile1.variables['latitude'] [:]
outfile.variables['longitude'] [:] = infile1.variables['longitude'] [:]
outfile.variables['depth'] [:]  = infile1.variables['depth'] [:]

outfile.variables['thetao'] [:]  = infile1.variables['thetao'] [:]
outfile.variables['so'] [:]  = infile1.variables['so'] [:]
outfile.variables['uo'] [:]  = infile1.variables['uo'] [:]
outfile.variables['vo'] [:]  = infile1.variables['vo'] [:]
outfile.variables['zos'] [:]  = infile2.variables['zos'] [:]

infile1.close()
infile2.close()
outfile.close()

print(' ')
print(' +++> END of python program to write NEMO 3dinst vars all together <+++ ')
print(' ')

#####################################################################################################


