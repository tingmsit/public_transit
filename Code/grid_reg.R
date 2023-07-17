rm(list = ls())
library(dplyr)
library(ggplot2)
library(gridExtra)
library(plotly)
library(tidyverse)
library(lubridate)

master_df <- read.csv("../Data/master_data_file.csv")

# master_group <- master_df %>%
#   group_by(start_grid_cell, weekday, workhours) %>%
#   summarise(dist = mean(start_dist_from_bus), ride_share = sum(passgrs, na.rm=TRUE),
#     bus = sum(rides_on, na.rm=TRUE)) %>% filter(start_grid_cell == "2-C")

master_group <- master_df %>% filter(start_grid_cell == "2-D")
lm_reg <- lm(passgrs ~ rides_on + weekday + workhours + start_dist_from_bus, data=master_group)
summary(lm_reg)
