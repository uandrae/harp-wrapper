library(harpIO)



vfld_path       <- "/scratch/ms/spsehlam/hlam/vfld"
first_fcst      <- 2021011312
last_fcst       <- 2021012112

vfld_path       <- "/scratch/ms/se/snh/vfld"
first_fcst      <- 2021051912
last_fcst       <- 2021052812

sqlite_path     <- "/scratch/ms/se/snh/harp/FCTABLE"
sqlite_template <- "{eps_model}/{YYYY}/{MM}/FCTABLE_{parameter}_{YYYY}{MM}_{HH}.sqlite"

fcst_freq       <- "24h"

fcst_models     <- c("heps_43h22_tg3","heps_43h211")
fcst_members    <- list()
for ( model in fcst_models ) {
 fcst_members <- append(fcst_members,list(seq(0,6,1)))
}
names(fcst_members) <- fcst_models

fcst_lead_times <- seq(0, 48, 3)

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
