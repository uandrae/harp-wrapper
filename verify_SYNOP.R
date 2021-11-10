library(harpIO)
library(harpPoint)

params          <- c("Pmsl","T2m","S10m","RH2m","vis","Q2m",
                     "CCtot","CClow","Cbase",
                     "Td2m",
                     #"Gmax","Tmax","Tmin","AccPcp1h",
                     "AccPcp3h","AccPcp6h","AccPcp12h")

thresholds <- list(
 
  "Pmsl"=c(960,970,980,990,1000,1010,1020),

  "T2m"=c(-20,-10,-5,0,5,10,15,20,25,30),
  "Td2m"=c(-20,-10,-5,0,5,10,15,20,25,30),
  "Tmin"=c(-20,-10,-5,0,5,10,15,20,25,30),
  "Tmax"=c(-20,-10,-5,0,5,10,15,20,25,30),

  "Q2m"=c(2,4,6,8,10,12),
  "RH2m"=c(50,60,70,80,90),

  "S10m"=c(5,10,15,20,25,30,35),
  "Gmax"=c(5,10,15,20,25,30,35),

 "AccPcp1h"=c(0.1,0.3,0.5,1,2,4,7,10,15,20),
 "AccPcp3h"=c(0.1,0.3,0.5,1,2,4,7,10,15,20),
 "AccPcp6h"=c(0.1,0.3,0.5,1,2,4,7,10,15,20),
 "AccPcp12h"=c(0.1,0.3,0.5,1,2,4,7,10,15,20),

 "CCtot"=c(0,1,2,3,4,5,6,7,8),
 "CClow"=c(0,1,2,3,4,5,6,7,8),
 "Cbase"=c(25,50,75,100,200,500,1000,2000,3000,4000,5000),

 "vis"=c(100,1000,5000,10000,20000,40000,50000)

)

fctable_dir     <- Sys.getenv("FCTABLE_DIR")
veriftable_dir  <- Sys.getenv("VERIFTABLE_DIR")
start_date      <- Sys.getenv("START_DATE")
end_date        <- Sys.getenv("END_DATE")
fcst_freq       <- Sys.getenv("FCST_FREQ")

fcst_models <- eval(parse(text=Sys.getenv("FCST_MODELS")))

max_lead <- Sys.getenv("LEAD_TIME")
fre_lead <- 1
lead_times      <- seq(0, max_lead, fre_lead)
sqlite_template <- "{eps_model}/{YYYY}/{MM}/FCTABLE_{parameter}_{YYYY}{MM}_{HH}.sqlite"

for ( param in params ) {

 if (param == "AccPcp12h") {
    lead_times <- seq(12, max_lead, 6)
 } else if (param == "AccPcp6h") {
    lead_times <- seq(6, max_lead, 6)
 } else if (param == "AccPcp3h") {
    lead_times <- seq(3, max_lead, 3)
 } else if (param == "AccPcp1h") {
    lead_times <- seq(1, max_lead, 1)
 } else if (param == "Tmin" | param == "Tmax" ) {
    lead_times <- seq(18, 18, 6)  
 } else if (param == "Gmax") {
    lead_times <- seq(3, max_lead, fre_lead)  
 } else {
    lead_times <- seq(0, max_lead,fre_lead)
 }

 obstable_dir <- Sys.getenv("OBSTABLE_DIR")


 thresholds_ <- NULL
 fcst_scales <- NULL
  obs_scales <- NULL

 if ( length(grep(pattern = '^(T2m|Tmin|Tmax|Td2m)$', x = param)) > 0 ) {
  fcst_scales <- list()
  for ( model in fcst_models ) {
    fcst_scales[[model]] = list(scale_factor = -273.15, new_units = "C", multiplicative = FALSE)
  }
  obs_scales <- list(scale_factor = -273.15, new_units = "C", multiplicative = FALSE)

 } else if ( length(grep(pattern = '^(Q|Q2m)$', x = param)) > 0 ) {
  fcst_scales <- list()
  for ( model in fcst_models ) {
    fcst_scales[[model]] = list(scale_factor = 1000., new_units = "g/kg", multiplicative = TRUE)
  }

  obs_scales <- list(scale_factor = 1000., new_units = "g/kg", multiplicative = TRUE)

 } else if (param == "Cbase") {

  fcst_scales <- list()
  for ( model in fcst_models ) {
    fcst_scales[[model]] = list(scale_factor = 1.00, new_units = "m", multiplicative = TRUE)
  }
  obs_scales <- list(scale_factor = 1.0, new_units = "m", multiplicative = TRUE)

 }

verif_val <- ens_read_and_verify(
  num_iterations = 2,
  start_date     = start_date,
  end_date       = end_date,
  parameter      = param,
  by             = fcst_freq,
  fcst_model     = fcst_models,
  fcst_path      = fctable_dir,
  fctable_file_template  = sqlite_template,
  obs_path       = obstable_dir,
  lead_time      = lead_times,
  thresholds     = thresholds[[param]],
  scale_fcst     = fcst_scales,
  scale_obs      = obs_scales,
  verif_path     = veriftable_dir
)

}
