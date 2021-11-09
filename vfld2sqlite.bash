#!/bin/bash
#SBATCH --get-user-env
#SBATCH --qos=normal
#SBATCH --job-name=v3_vfld2sqlite

date 

# Modules
module load proj4
module load R/4.0.4

# Environment variables
export R_LIBS_USER=$HOME/lib/R
export HARP_HOME=$HOME/harpv3


# Run harp
R --no-save --no-restore --slave < ${HARP_HOME}/vfld2sqlite.R

date 
