library(harpIO)


first_obs      <- 2021051900
last_obs       <- 2021060100
vobs_path      <- "/scratch/ms/se/snh/vobs/heps_43h22_tg3/"

first_obs      <- 2021011300
last_obs       <- 2021020100
vobs_path      <- "/scratch/ms/spsehlam/hlam/vobs/heps_43h22_tg3/"

obs_freq       <- "3h"
sqlite_path    <- "/scratch/ms/se/snh/harp/OBSTABLE"

read_obs_convert(
  start_date  = first_obs,
  end_date    = last_obs,
  obs_path    = vobs_path,
  by          = obs_freq,
  sqlite_path = sqlite_path
)
