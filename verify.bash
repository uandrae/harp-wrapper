#!/bin/bash
#SBATCH --get-user-env
#SBATCH --qos=express
#SBATCH --job-name=v3_verify


date

# Modules
module load proj4
module load R/4.0.4

# Environment variables
export R_LIBS_USER=$HOME/lib/R

export FCTABLE_DIR="/scratch/ms/se/snh/harp/FCTABLE"
export OBSTABLE_DIR="/scratch/ms/se/snh/harp/OBSTABLE"
export VERIFTABLE_DIR="/scratch/ms/se/snh/harp/VERTABLE"

export START_DATE=2021052012
export   END_DATE=2021052812

export START_DATE=2021011312
export   END_DATE=2021012112

export FCST_FREQ=24h
export LEAD_TIME=48
export FCST_MODELS="c('heps_43h22_tg3','heps_43h211')"

# Run harp
export TZ="GMT"
R --no-save --no-restore --slave < ./verify_SYNOP.R
R --no-save --no-restore --slave < ./verify_TEMP.R

date
