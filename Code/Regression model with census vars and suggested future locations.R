#This new file has a few new variables from the US Census American Community Survey (ACS).
#The census data goes down to the level of census tracts, which are approximately neighborhood-sized, and I was able to map the latitude/longitude onto those census tracts.
#For us, the important variables were median household income (median_hincome) and population density (ppsm = people per square mile).
#A final variable is the number of different combinations of locations, days, and hours that a rideshare was requested in a given census tract, represented by the "n_var" variable.
#This variable is a little tricky to interpret, but I think it speaks to the fact that some areas of the city have not only higher demand for transportation, but more varied demand, and those areas tend to have stronger public transportation use.
#When I grouped the data by census tract, then, instead oflat/long pair, it gave us a useful amount of aggregation - more specific than a 5x5 grid, but less granular than lat/long.


master_data <- read.csv("master_data_file_with_census_vars.csv")

master_data$passgrs_per_ppsm <- master_data$passgrs/master_data$ppsm

master_grp <- master_data %>%
  group_by(tract, ppsm, median_hincome) %>%
  summarise(start_dist_from_bus = mean(start_dist_from_bus, na.rm=TRUE), passgrs = sum(passgrs, na.rm=TRUE), rides_on = sum(rides_on, na.rm=TRUE), passgrs_per_ppsm = sum(passgrs, na.rm=TRUE)/mean(ppsm, na.rm=TRUE), n_var = n())   #n_var represents variety in use of ridesharing (locations, times of day, and days of week)

linreg_dow_hour_grp <- lm(rides_on~passgrs + ppsm + median_hincome + n_var, master_grp)
summary(linreg_dow_hour_grp)

#The new model is a better predictor of public transportation use, with R2 value of 0.525.
#Yes, rideshares and public transportation are positively correlated, but the model is still useful in predicting which locations would be best suited for expanding public transportation options.
#Basically, this model says that we should look for areas that have high rideshare demand, that are densely populated, with lower median income, and with more varied rideshare use (i.e., at many hours of day, days of week, and different lat/long points).


#We can use this model to suggest the best location(s) for new expansion:
#This gives us a list of locations with no current public transportation use, and predicts the number of public transportation rides that could be gained per six-month period if we expanded into that area.
possible_loc <- master_grp %>% filter(rides_on == 0)
possible_loc$pred <- ifelse(predict(linreg_dow_hour_grp, possible_loc)<0, 0, predict(linreg_dow_hour_grp, possible_loc))

#This model would suggest that the best candidate is a neighborhood on the north boundary of CapMetro's service area, an area called Round Rock.
#I think it's a reasonable suggestion because it's continguous to the current (as of Jan. 2017) service area, and it's right next several college campuses, like Texas A&M and Austin Comm. College.
#In fact, in March 2017, right after the period that this dataset represents, CapMetro did decide to expand into this area with four new routes, which is a nice confirmation of our analysis.
#Here's the article: https://cbsaustin.com/news/local/round-rock-to-get-capmetro-bus-service-in-august

