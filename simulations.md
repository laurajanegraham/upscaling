# Upscaling: Simulations
Laura Graham  
5 March 2018  



## Simulation One: continuous variables

This simulation will show the use of the moving window-based spatial structure measure for continuous variables which have finer scale variation than the resolution of analysis. This could be, for example, topographic or microclimate variation. 

### Simulated landscapes

We simulated landscapes using the mid-point displacement method (`nlm_mpd`) from the `NLMR` package [@Sciaini2018]. We simulated landscapes with three levels of spatial autocorrelation, and 100 replicates for each of these. The spatial autocorrelation of the landscape is controlled by the `roughness` parameter where a value of zero is a clustered landscape, and a value of one is a rough landscape. We generated landscapes of 65 x 65 cells using roughness = 0, 0.5, 1. 


```r
nrows <- ncols <- 65
roughness <- c(0, 0.5, 1)
reps <- 1

param_table <- expand.grid(ncol = ncols, nrow = nrows, roughness = roughness, reps = reps)

sim_ls <- apply(param_table, 1, function(x) ls_create(x))

# combine all runs into one dataframe and only take the first replicate of each
# combination for plotting
ls_df <- ldply(sim_ls, function(x) x$ls_df) %>% 
  filter(reps == 1) %>% 
  inner_join(group_by(., roughness) %>% summarise(Var = round(var(layer), 2))) %>% 
  mutate(facet = paste0("Roughness = ", roughness, ", Variance = ", Var))

# plot example landscapes
ggplot(ls_df, aes(x = x, y = y, fill = layer)) + 
  geom_raster() + 
  coord_equal() + 
  scale_fill_viridis_c(name = "Continuous variable") + 
  theme(axis.text = element_blank(), axis.title = element_blank(), 
        axis.line = element_blank(), axis.ticks = element_blank()) + 
  facet_wrap(~facet, ncol = 1)
```

![](simulations_files/figure-html/sim_ls-1.png)<!-- -->

**Figure 1** Example landscapes of each level of roughness

### Use winmover function


### Results (see Macro 2017 poster)

## Simulation Two: categorical variables

This simulation will show the use of the moving window-based spatial structure measure for categorical variables which have finer scale variation than the resolution of analysis. This is appropriate for more classical landscape ecology questions about habitat structure. 

### Simulated landscapes
### Use winmover function
### Results (see Macro 2017 poster)
