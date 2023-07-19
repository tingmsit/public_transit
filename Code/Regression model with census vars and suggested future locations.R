
master_data <- read.csv("master_data_file_with_census_vars.csv")

master_data$passgrs_per_ppsm <- master_data$passgrs/master_data$ppsm

#Keep only columns needed
#master_short <- subset(master_data, select = c(X, passgrs, rides_on, start_dist_from_bus, start_location_lat, start_location_long, start_grid_cell, ppsm, median_hincome, pctpt, tract, passgrs_per_ppsm))
#rownames(master_short) = NULL

master_grp <- master_data %>%
  group_by(tract, ppsm, median_hincome) %>%
  summarise(start_dist_from_bus = mean(start_dist_from_bus, na.rm=TRUE), passgrs = sum(passgrs, na.rm=TRUE), rides_on = sum(rides_on, na.rm=TRUE), passgrs_per_ppsm = sum(passgrs, na.rm=TRUE)/mean(ppsm, na.rm=TRUE), n_var = n())   #n_var represents variety in use of ridesharing (locations, times of day, and days of week)

linreg_dow_hour_grp <- lm(rides_on~passgrs + ppsm + median_hincome + n_var, master_grp)
summary(linreg_dow_hour_grp)

#Find locations with no current public transportation use, and predict number of trips per six-month period
possible_loc <- master_grp %>% filter(rides_on == 0)
possible_loc$pred <- ifelse(predict(linreg_dow_hour_grp, possible_loc)<0, 0, predict(linreg_dow_hour_grp, possible_loc))
