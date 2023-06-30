rm(list = ls())
library(dplyr)
library(ggplot2)
library(plotly)
library(tidyverse)
library(lubridate)
library(chron)

df <- read.csv('../Data/RideAustin_Weather.csv')

summary(df)
str(df_filter)
df_filter <- df %>% filter(distance_travelled < 20000)
df_filter$dist_km <- df_filter$distance_travelled/1000
df_filter$dow <- wday(ymd(df_filter$Date), label=TRUE)
df_filter$mo <- month(ymd(df_filter$Date), label=TRUE)
df_filter$start_ts <- as.POSIXct(df_filter$started_on, tz=Sys.timezone())
df_filter$end_ts <- as.POSIXct(df_filter$completed_on, tz=Sys.timezone())

df_filter$ts_travel <- difftime(df_filter$end_ts, df_filter$start_ts, units='mins')
df_filter$hour <- df_filter$start_ts %>% hour()

df_ts <- df_filter %>% filter(ts_travel >0 & ts_travel < 120)

dist_tr <- ggplot(df_filter, aes(dist_km)) + geom_histogram(binwidth = 1)
dist_tr


dist_ts <- ggplot(df_ts, aes(ts_travel)) + stat_ecdf(geom = 'step')
dist_ts

str(df_filter)
day_count <- ggplot(df_filter, aes(x = dow)) + geom_bar()
day_count             

weather_cond <- day_count + facet_grid(vars(Fog), vars(Thunder))
weather_cond


#month_count <- ggplot(df_filter, aes(x = mo)) + geom_bar()
#month_count 


hour_count <- ggplot(df_filter, aes(x = hour)) + geom_bar()
hour_count

#df_filter$start_loc <- paste("(", as.character(df_filter$start_location_long) ,",", as.character(df_filter$start_location_lat),")")
#df_filter$end_loc <- paste("(", as.character(df_filter$end_location_long) ,",", as.character(df_filter$end_location_lat),")")
#df_filter$from_to <- paste("(", as.character(df_filter$start_loc) ,",", as.character(df_filter$end_loc),")")

