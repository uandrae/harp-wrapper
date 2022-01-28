library(harpIO)
library(harpPoint)

params          <- c("Z","Q","T","S","RH","Td")

thresholds <- list(

  "T"=c(-30,-20,-10,-5,0,5,10,15,20,25,30),
  "Td"=c(-30,-20,-10,-5,0,5,10,15,20,25,30),
  "S"=c(5,10,15,20,25,30,35,50),
  "RH"=c(30,40,50,60,70,80,90)
)

quantiles       <- c(0.25, 0.5, 0.75, 0.9, 0.95)


fctable_dir     <- Sys.getenv("FCTABLE_DIR")
obstable_dir    <- Sys.getenv("OBSTABLE_DIR")
veriftable_dir  <- Sys.getenv("VERIFTABLE_DIR")
start_date      <- Sys.getenv("START_DATE")
end_date        <- Sys.getenv("END_DATE")
fcst_freq       <- Sys.getenv("FCST_FREQ")


fcst_models <- eval(parse(text=Sys.getenv("FCST_MODELS")))


lead_times <- seq(0,48,6)


for ( param in params ) {

 param_sym <- rlang::sym(param)

 fcst <- read_point_forecast(
          vertical_coordinate="pressure",
          start_date=start_date,end_date=end_date,by=fcst_freq,
          lead_time=lead_times,
          fcst_model=fcst_models,
          fcst_type="eps",parameter=param,
          file_path=fctable_dir,file_template = "fctable_eps_all_leads"
         ) 

 fcst <- common_cases(fcst,p)

 dt <- as.Date(end_date,format = "%Y%m%d%H")
 dt <- dt+2
 end_date_obs <- format(dt,"%Y%m%d%H")

 obs <- read_point_obs(
          vertical_coordinate="pressure",
          start_date=start_date, end_date=end_date_obs,
          parameter=param, obs_path=obstable_dir)

 fcst <- join_to_fcst(fcst, obs) %>% check_obs_against_fcst(param)

 if ( ! is.null(thresholds[[param]]) ) {
  thresholds_=thresholds[[param]]
 } else {
  thresholds_=quantile(obs[[param]],quantiles)
 }
 
 verify <- ens_verify(fcst,!!param_sym,
            groupings = c("leadtime","p"),thresholds=thresholds_ )

 save_point_verif(verify,verif_path = veriftable_dir )

}

