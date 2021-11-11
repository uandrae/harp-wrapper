library(harpPoint)

thresholds <- list(

  T  = c(-30, -20, -10, -5, 0, 5, 10, 15, 20, 25, 30),
  Td = c(-30, -20, -10, -5, 0, 5, 10, 15, 20, 25, 30),
  S  = c(5, 10, 15, 20, 25, 30, 35, 50),
  RH = c(30, 40, 50, 60, 70, 80, 90),
  Z  = NULL,
  Q  = NULL
)

params <- names(thresholds)

quantiles <- c(0.25, 0.5, 0.75, 0.9, 0.95)

fctable_dir    <- Sys.getenv("FCTABLE_DIR")
obstable_dir   <- Sys.getenv("OBSTABLE_DIR")
veriftable_dir <- Sys.getenv("VERIFTABLE_DIR")
start_date     <- Sys.getenv("START_DATE")
end_date       <- Sys.getenv("END_DATE")
fcst_freq      <- Sys.getenv("FCST_FREQ")
fcst_models    <- strsplit(gsub("\\s", "", Sys.getenv("FCST_MODELS")), ",")

lead_times <- seq(0, 48, 6)

for (param in params) {

  fcst <- read_point_forecast(
    start_date          = start_date,
    end_date            = end_date,
    by                  = fcst_freq,
    fcst_model          = fcst_models,
    fcst_type           = "eps",
    parameter           = param,
    lead_time           = lead_times,
    file_path           = fctable_dir,
    vertical_coordinate = "pressure"
  )

  fcst <- common_cases(fcst, p)

  obs <- read_point_obs(
    start_date          = first_validdate(fcst),
    end_date            = last_validdate(fcst),
    parameter           = param,
    obs_path            = obstable_dir,
    vertical_coordinate = "pressure"
  )

  fcst <- join_to_fcst(fcst, obs) %>%
    check_obs_against_fcst({{param}})

  thresholds_ <- thresholds[[param]]

  if (is.null(thresholds_)) {
    thresholds_ <- quantile(fcst[[1]][[param]], quantiles)
  }

  verify <- ens_verify(
    fcst,
    {{param}},
    groupings  = c("leadtime", "p"),
    thresholds = thresholds_
  )

  save_point_verif(verify, verif_path = veriftable_dir)

}

