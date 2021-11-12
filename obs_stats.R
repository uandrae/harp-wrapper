library(harpIO)
library(harpData)
library(meteogrid)
library(dplyr)
library(ggplot2)
library(RColorBrewer)

# Assume get_map.R is in the current working directory. Add full path if necessary
source("get_map.R")

# Define domain
meps_proj4  <- "+proj=lcc +lat_0=63.3 +lon_0=15 +lat_1=63.3 +lat_2=63.3 +R=6371000"
meps_domain <- structure(
  list(
    projection = proj4.str2list(meps_proj4),
    nx         = 949L,
    ny         = 1069L,
    SW         = c(0.2782807, 50.3196164),
    NE         = c(54.24126, 71.57601),
    dx         = 2500,
    dy         = 2500
  ),
  class = "geodomain"
)

# Read observations (You will need to add your own path here -
# I'm using example data from the harpData package)
oo <- harpData_info("obstable")

param <- "AccPcp1h"

obs <- read_point_obs(
  oo$start_date,
  oo$end_date,
  param,
  obs_path = oo$dir
)

# Remove stations outside domain and reproject
obs <- cbind(obs, point.index(meps_domain, obs$lon, obs$lat)) %>%
  filter(if_all(c(i, j), ~!is.na(.x))) %>%
  cbind(project(.$lon, .$lat, meps_domain$projection))

# Plot number of stations per time
ggplot(obs, aes(validdate)) +
  geom_bar(fill = "steelblue") +
  scale_x_datetime(date_breaks = "3 hours") +
  labs(x = NULL, y = "Number of stations") +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5))

# to save use:
# ggsave("filename.png")

# Plot stations on a map
map_poly  <- get_map(dom = meps_domain)
obs_count <- summarize(group_by(obs, SID, x, y), Count = n())
ggplot(obs_count, aes(x, y)) +
  geom_polygon(
    aes(group = group), map_poly,
    fill = "grey90", colour = "grey50"
  ) +
  geom_point(aes(colour = Count)) +
  scale_colour_stepsn(
    colors = brewer.pal(9, "YlOrRd"),
    breaks = pretty(obs_count$Count, 10)
  ) +
  coord_equal(
    xlim = c(DomainExtent(meps_domain)$x0, DomainExtent(meps_domain)$x1),
    ylim = c(DomainExtent(meps_domain)$y0, DomainExtent(meps_domain)$y1),
    expand = FALSE
  ) +
  theme_bw() +
  theme(
    axis.title = element_blank(),
    axis.text  = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  ) +
  labs(
    title    = paste("Number of observations for", param),
    subtitle = paste(range(obs$validdate), collapse = " - ")
  )

# to save use:
# ggsave("filename.png")

