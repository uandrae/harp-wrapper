library(harpIO)

vfld_path       <- "/scratch/ms/se/snh/vfld"
sqlite_path     <- "/scratch/ms/se/snh/harp/FCTABLE"
sqlite_template <- "{eps_model}/{YYYY}/{MM}/FCTABLE_{parameter}_{YYYY}{MM}_{HH}.sqlite"

first_fcst      <- 2021052012
last_fcst       <- 2021052612

fcst_freq       <- "24h"
fcst_models     <- c("heps_43h211")
fcst_members    <- list(heps_43h211 = c(0,1,2,3,4,5,6))
#fcst_lags       <- list(prod_SPP_defpert_43h2_2 =  paste0(c(0,0,0,0,0,0,0),"h"))
fcst_lead_times <- seq(0, 48, 1)

read_eps_interpolate(
 start_date=first_fcst,
 end_date=last_fcst,
 eps_model = fcst_models,
 parameter=NULL,
 by=fcst_freq,
 lead_time=fcst_lead_times,
 members_in=fcst_members,
 file_path=vfld_path,
 vertical_coordinate = "pressure",
 sqlite_path=sqlite_path,
 sqlite_template = sqlite_template
)
 #lags=fcst_lags,
