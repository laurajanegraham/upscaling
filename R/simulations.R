library(raster)
library(NLMR)
library(landscapetools)
library(grainchanger)
library(furrr)
library(tidyverse)

plan(multiprocess)

# 1. Create the landscapes and calculate LS and MW measures 
# Set up spatial autocorrelation parameters
system.time(df <- bind_rows(
  tibble(sa_scenario = "No spatial autocorrelation", sa_values = rep(0.1, 100)),
  tibble(sa_scenario = "Low, varied autocorrelation", sa_values = seq(0.1, 0.5, length.out = 100)),
  tibble(sa_scenario = "Varied spatial autocorrelation", sa_values = seq(0.1, 1, length.out = 100)),
  tibble(sa_scenario = "High, varied spatial autocorrelation", sa_values = seq(0.5, 1, length.out = 100)),
  tibble(sa_scenario = "High spatial autocorrelation", sa_values = rep(1, 100))
) %>% 
  # create the continuous and categorical landscapes
  mutate(cont_ls = map(sa_values, function(x) nlm_fbm(ncol = 65, nrow = 65, fract_dim = x)),
         # the categorical map has a random proportion between landscapes for each landscape
         cat_ls = map(cont_ls, function(x) util_classify(x, weighting = diff(c(0, sort(runif(4)), 1)))), # need to change code to save the weights
         # calculate LSM
         cont_lsm = map_dbl(cont_ls, function(x) x %>% raster::values() %>% var),
         cat_lsm = map_dbl(cat_ls, function(x) diversity(x, lc_class = 0:4))) %>% 
  crossing(window = c(1, 4, 7, 17, 27)) %>% 
  mutate(cont_ls_pad = map2(cont_ls, window, create_torus),
         cat_ls_pad = map2(cat_ls, window, create_torus),
         # calculate MWM
         cont_mwm = future_map2_dbl(cont_ls_pad, window, function(ls, w) winmove(ls, radius = w, type = "rectangle", fn = "var") %>% trim %>% raster::values() %>% mean),
         cat_mwm = future_map2_dbl(cat_ls_pad, window, function(ls, w) winmove(ls, radius = w, type = "rectangle", fn = "diversity", lc_class = 0:4) %>% trim %>% raster::values() %>% mean)
  )
)