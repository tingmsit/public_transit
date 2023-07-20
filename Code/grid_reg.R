rm(list = ls())
library(dplyr)
library(ggplot2)
library(gridExtra)
library(plotly)
library(tidyverse)
library(lubridate)
library(fuzzyjoin)

# Ride share data processing

df <- read.csv("../Data/RideAustin_Weather.csv")

summary(df)
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


rideshare_gp <- rideshare %>%
  group_by(dow, hour) %>%
  summarise(ride_vol = n() * 1.4)


rideshare_gp$wkd_end <- ifelse((rideshare_gp$dow == "Sun" | rideshare_gp$dow ==
  "Sat"), "weekend", "weekday")
rideshare_gp$hr_cat <- ifelse((rideshare_gp$hour < 6), "darkout",
  ifelse((rideshare_gp$hour >= 6 & rideshare_gp$hour < 12),
    "rush_hour", ifelse((rideshare_gp$hour >= 12 & rideshare_gp$hour <
      18), "work_hour", "evening")))


summary(lm(ride_vol ~ wkd_end + hr_cat, data = rideshare_gp))

# K-S Test
fog_count <- rideshare %>%
  group_by(Fog) %>%
  summarise(n = n()) %>%
  filter(Fog == 1)
thunder_count <- rideshare %>%
  group_by(Thunder) %>%
  summarise(n = n()) %>%
  filter(Thunder == 1)

set.seed(123)
no_fog <- rideshare %>%
  filter(Fog == 0) %>%
  sample_n(size = fog_count$n) %>%
  group_by(dow) %>%
  summarize(n = n())
fog <- rideshare %>%
  filter(Fog == 1) %>%
  group_by(dow) %>%
  summarize(n = n())
ks.test(no_fog$n, fog$n)

no_thunder <- rideshare %>%
  filter(Thunder == 0) %>%
  sample_n(size = thunder_count$n) %>%
  group_by(dow) %>%
  summarize(n = n())
thunder <- rideshare %>%
  filter(Thunder == 1) %>%
  group_by(dow) %>%
  summarize(n = n())
ks.test(no_thunder$n, thunder$n)

# Bus ride dataset

capmetro <- read.csv("../Data/CapMetro ridership all by latlong dow hour.csv")
capmetro$dow <- substr(weekdays(as.Date("2017-01-01") + capmetro$start_time_dayofwk),
  1, 3)
capmetro_gp <- capmetro %>%
  group_by(dow, start_time_hour) %>%
  summarize(bus_vol = sum(rides_on))
capmetro_gp$wkd_end <- ifelse((capmetro_gp$dow == "Sat" | capmetro_gp$dow ==
  "Sun"), "weekend", "weekday")
capmetro_gp$hr_cat <- ifelse((capmetro_gp$start_time_hour < 6),
  "darkout", ifelse((capmetro_gp$start_time_hour >= 6 & capmetro_gp$start_time_hour <
    12), "rush_hour", ifelse((capmetro_gp$start_time_hour >=
    12 & capmetro_gp$start_time_hour < 18), "work_hour",
    "evening")))


final_df <- merge(rideshare_gp, capmetro_gp, by.x = c("wkd_end",
  "hr_cat", "dow", "hour"), by.y = c("wkd_end", "hr_cat", "dow",
  "start_time_hour"))

cor.test(final_df$bus_vol, final_df$ride_vol)

reg <- lm(ride_vol ~ bus_vol + wkd_end + hr_cat, data = final_df)
summary(reg)

# adding grid to both rideshare and capmetro dataset
grid_map <- read.csv("../Data/master_data_file.csv")
grid <- unique(grid_map[, c("start_location_lat", "start_location_long",
                            "start_grid_cell")])

# Note some trips will be dropped as they fall outside the 5x5 grid
rideshare_1 <- merge(rideshare, grid, by = c("start_location_long",
  "start_location_lat"))


rideshare_1_gp <- rideshare_1 %>%
  group_by(dow, hour, start_grid_cell) %>%
  summarise(ride_vol = n() * 1.4)


rideshare_1_gp$wkd_end <- ifelse((rideshare_1_gp$dow == "Sun" |
  rideshare_1_gp$dow == "Sat"), "weekend", "weekday")
rideshare_1_gp$hr_cat <- ifelse((rideshare_1_gp$hour < 6), "darkout",
  ifelse((rideshare_1_gp$hour >= 6 & rideshare_1_gp$hour <
    12), "rush_hour", ifelse((rideshare_1_gp$hour >= 12 &
    rideshare_1_gp$hour < 18), "work_hour", "evening")))

capmetro_1 <- capmetro
capmetro_1 <- merge(capmetro, grid, by.x = c("veh_lat_rnd", "veh_long_rnd"),
  by.y = c("start_location_lat", "start_location_long"))
capmetro_1_gp <- capmetro_1 %>%
  group_by(dow, start_time_hour, start_grid_cell) %>%
  summarize(bus_vol = sum(rides_on))
capmetro_1_gp$wkd_end <- ifelse((capmetro_1_gp$dow == "Sat" |
  capmetro_1_gp$dow == "Sun"), "weekend", "weekday")
capmetro_1_gp$hr_cat <- ifelse((capmetro_1_gp$start_time_hour <
  6), "darkout", ifelse((capmetro_1_gp$start_time_hour >= 6 &
  capmetro_1_gp$start_time_hour < 12), "rush_hour", ifelse((capmetro_1_gp$start_time_hour >=
  12 & capmetro_1_gp$start_time_hour < 18), "work_hour", "evening")))
final_df_1 <- merge(rideshare_1_gp, capmetro_1_gp, by.x = c("wkd_end",
  "hr_cat", "dow", "hour", 'start_grid_cell'), by.y = c("wkd_end", "hr_cat", "dow",
  "start_time_hour", 'start_grid_cell'))

reg_1 <- lm(ride_vol ~ bus_vol + wkd_end + hr_cat + start_grid_cell, data = final_df_1)
summary(reg_1)


