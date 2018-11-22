library(raster)
library(NLMR)
library(landscapetools)
library(grainchanger)
library(tidyverse)
library(furrr)

plan(multiprocess)

# 1. Create the landscapes and calculate LS and MW measures 
# Set up spatial autocorrelation parameters

strt <- Sys.time()
res <- bind_rows(
  tibble(sa_scenario = "No spatial autocorrelation", sa_values = rep(0.1, 100)),
  tibble(sa_scenario = "Low, varied spatial autocorrelation", sa_values = seq(0.1, 0.5, length.out = 100)),
  tibble(sa_scenario = "Varied spatial autocorrelation", sa_values = seq(0.1, 1, length.out = 100)),
  tibble(sa_scenario = "High, varied spatial autocorrelation", sa_values = seq(0.5, 1, length.out = 100)),
  tibble(sa_scenario = "High spatial autocorrelation", sa_values = rep(1, 100))
) %>% 
  # create the continuous and categorical landscapes
  mutate(cont_ls = future_map(sa_values, function(x) nlm_fbm(ncol = 400, nrow = 400, resolution = 25, fract_dim = x)),
         # the categorical map has a random proportion between landscapes for each landscape
         cat_wt = future_map(sa_values, function(x) diff(c(0, sort(runif(4)), 1))),
         cat_ls = future_map2(cont_ls, cat_wt, function(x, wt) util_classify(x, weighting = wt)),
         # calculate LSM
         cont_lsm = future_map_dbl(cont_ls, function(x) x %>% raster::values() %>% var),
         cat_lsm = future_map_dbl(cat_ls, function(x) diversity(x, lc_class = 0:4))) %>% 
  crossing(window = c(500, 1000, 1500, 3500)) %>% 
  mutate(cont_ls_pad = future_map2(cont_ls, window, create_torus),
         cat_ls_pad = future_map2(cat_ls, window, create_torus),
         # calculate MWM
         cont_mwm = future_map2_dbl(cont_ls_pad, window, function(ls, w) winmove(ls, d = w, type = "rectangle", fun = "var") %>% trim %>% raster::values() %>% mean),
         cat_mwm = future_map2_dbl(cat_ls_pad, window, function(ls, w) winmove(ls, d = w, type = "rectangle", fun = "shei", lc_class = 0:4) %>% trim %>% raster::values() %>% mean)
  ) %>% select(-cont_ls, -cat_ls, -cont_ls_pad, -cat_ls_pad)

runtime = difftime(Sys.time(),  strt)
out = list(res = res, runtime = runtime)
save(out, file = tempfile(tmpdir = ".", fileext = ".Rda"))
