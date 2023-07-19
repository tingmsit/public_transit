rm(list = ls())
library(dplyr)
library(ggplot2)
library(gridExtra)
library(plotly)
library(tidyverse)
library(lubridate)
library(fuzzyjoin)

grid_map <- read.csv("../Data/master_data_file.csv")
grid <- unique(grid_map[, c("start_location_lat", "start_location_long",
  "start_grid_cell")])


# Ride share data processing

df <- read.csv("../Data/RideAustin_Weather.csv")
rideshare <- df %>%
  filter(distance_travelled < 15000) %>%
  mutate(dist_km = distance_travelled/1000, dow = wday(ymd(Date),
    label = TRUE))

rideshare$start_ts <- as.POSIXct(rideshare$started_on, tz = Sys.timezone())
rideshare$end_ts <- as.POSIXct(rideshare$completed_on, tz = Sys.timezone())
rideshare$ts <- difftime(rideshare$end_ts, rideshare$start_ts,
  units = "mins")
rideshare <- rideshare %>%
  filter(ts > 0 & ts < 120)

rideshare$hour <- rideshare$started_on %>%
  as.POSIXct(tz = Sys.timezone()) %>%
  hour()

rideshare$wkd <- ifelse((rideshare$dow == "Sun" | rideshare$dow ==
  "Sat"), "weekend", "weekday")
rideshare$hr_cat <- ifelse((rideshare$hour >= 6 & rideshare$hour <
  18), "workhour", "offpeak")

rideshare_gp <- rideshare %>%
  group_by(start_location_long, start_location_lat, wkd, hr_cat) %>%
  summarise(ride_vol = n() * 1.4)
rideshare_gp$ride_vol_norm <- ifelse(rideshare_gp$wkd == "weekend",
  rideshare_gp$ride_vol/2, rideshare_gp$ride_vol/5)
rideshare_final <- merge(rideshare_gp, grid, by = c("start_location_long",
  "start_location_lat"))


# Bus ride dataset

capmetro <- read.csv("../Data/CapMetro ridership all by latlong dow hour.csv")
capmetro$wkd <- ifelse((capmetro$start_time_dayofwk == 6 | capmetro$start_time_dayofwk ==
  7), "weekend", "weekday")
capmetro$hr_cat <- ifelse((capmetro$start_time_hour >= 6 & capmetro$start_time_hour <
  18), "workhour", "offpeak")

capmetro_gp <- capmetro %>%
  group_by(veh_lat_rnd, veh_long_rnd, wkd, hr_cat) %>%
  summarize(bus_vol = sum(rides_on))
capmetro_gp$bus_vol_norm <- ifelse(capmetro_gp$wkd == "weekend",
  capmetro_gp$bus_vol/2, capmetro_gp$bus_vol/5)
capmetro_final <- merge(capmetro_gp, grid, by.x = c("veh_lat_rnd",
  "veh_long_rnd"), by.y = c("start_location_lat", "start_location_long"))

final_df <- merge(rideshare_final, capmetro_final, by.x = c("start_location_long",
  "start_location_lat", 'wkd', 'hr_cat', 'start_grid_cell'), by.y = c("veh_long_rnd", "veh_lat_rnd", 'wkd', 'hr_cat', 'start_grid_cell'))

reg <- lm(ride_vol_norm ~ bus_vol_norm + wkd + hr_cat + start_grid_cell, data = final_df)
summary(reg)

spec_reg <- final_df %>% filter(start_grid_cell %in% c('3-A', '3-B'))
summary(lm(ride_vol_norm ~ bus_vol_norm + hr_cat , data = spec_reg))
