library(harpPoint)

thresholds <- list(

  Pmsl = c(960, 970, 980, 990, 1000, 1010, 1020),

  T2m  = c(-20, -10, -5, 0, 5, 10, 15, 20, 25, 30),
  Td2m = c(-20, -10, -5, 0, 5, 10, 15, 20, 25, 30),
  Tmin = c(-20, -10, -5, 0, 5, 10, 15, 20, 25, 30),
  Tmax = c(-20, -10, -5, 0, 5, 10, 15, 20, 25, 30),

  Q2m  = c(2, 4, 6, 8, 10, 12),
  RH2m = c(50, 60, 70, 80, 90),

  S10m = c(5, 10, 15, 20, 25, 30, 35),
  Gmax = c(5, 10, 15, 20, 25, 30, 35),

  AccPcp1h  = c(0.1, 0.3, 0.5, 1, 2, 4, 7, 10, 15, 20),
  AccPcp3h  = c(0.1, 0.3, 0.5, 1, 2, 4, 7, 10, 15, 20),
  AccPcp6h  = c(0.1, 0.3, 0.5, 1, 2, 4, 7, 10, 15, 20),
  AccPcp12h = c(0.1, 0.3, 0.5, 1, 2, 4, 7, 10, 15, 20),

  CCtot = c(0, 1, 2, 3, 4, 5, 6, 7, 8),
  CClow = c(0, 1, 2, 3, 4, 5, 6, 7, 8),
  Cbase = c(25, 50, 75, 100, 200, 500, 1000, 2000, 3000, 4000, 5000),

  vis = c(100, 1000, 5000, 10000, 20000, 40000, 50000)

)

params <- names(thresholds)

fctable_dir    <- Sys.getenv("FCTABLE_DIR")
obstable_dir   <- Sys.getenv("OBSTABLE_DIR")
veriftable_dir <- Sys.getenv("VERIFTABLE_DIR")
start_date     <- Sys.getenv("START_DATE")
end_date       <- Sys.getenv("END_DATE")
fcst_freq      <- Sys.getenv("FCST_FREQ")
fcst_models    <- strsplit(gsub("\\s", "", Sys.getenv("FCST_MODELS")), ",")
max_lead       <- Sys.getenv("LEAD_TIME")

fre_lead <- 1

for (param in params) {

  lead_times <- switch(
    param,
    "AccPcp12h" = seq(12, max_lead, 6),
    "AccPcp6h"  = seq(6, max_lead, 6),
    "AccPcp3h"  = seq(3, max_lead, 3),
    "AccPcp1h"  = seq(1, max_lead, 1),
    "Tmin"      = ,
    "Tmax"      = seq(18, 18, 6),
    "Gmax"      = seq(3, max_lead, fre_lead),
    seq(0, max_lead, fre_lead)
  )

  switch(
    param,
    "T2m"  = ,
    "Tmin" = ,
    "Tmax" = ,
    "Td2m" = {
      fcst_scales <- list(scale_factor = -273.15, new_units = "degC")
      obs_scales  <- list(scale_factor = -273.15, new_units = "degC")
    },
    "Q2m" = {
      fcst_scales <- list(scale_factor = 1000, new_units = "g/kg", multiplicative = TRUE)
      obs_scales  <- list(scale_factor = 1000, new_units = "g/kg", multiplicative = TRUE)
    },
    "Cbase" = {
      fcst_scales <- list(scale_factor = 0, new_units = "m")
      obs_scales  <- list(scale_factor = 0, new_units = "m")
    },
    {
      fcst_scales <- NULL
      obs_scales  <- NULL
    }
  )

  if (!is.null(fcst_scales)) {
    fcst_scales <- sapply(fcst_models, function(x) fcst_scales, simplify = FALSE)
  }

  verif_val <- ens_read_and_verify(
    num_iterations        = 2,
    start_date            = start_date,
    end_date              = end_date,
    parameter             = param,
    by                    = fcst_freq,
    fcst_model            = fcst_models,
    fcst_path             = fctable_dir,
    fctable_file_template = "fctable",
    obs_path              = obstable_dir,
    lead_time             = lead_times,
    thresholds            = thresholds[[param]],
    scale_fcst            = fcst_scales,
    scale_obs             = obs_scales,
    verif_path            = veriftable_dir
  )

}
