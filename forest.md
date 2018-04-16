# Upscaling: Forest Case Study
Laura Graham  



# Data

## EU forest data

First we need to load in and spatialise the EU forest data: available for download from [figshare](https://ndownloader.figshare.com/files/6662535)



## Environmental data

Analyses will be at 0.5 degree resolution. The data to be upscaled are the elevation data from the [European Environment Agency](https://www.eea.europa.eu/data-and-maps/data/eu-dem). By cropping all datasets to the extent of the EU elevation data, we end up losing some of the data from the EU forest dataset, such as the records from Northern Africa and the Canaries. We aggregate the elevation to 100m (from 25m) for ease of computation.

We will use the moving window to upscale the variation in elevation using a radius of 2km. We will also calculate variation in elevation at 0.5 degree resolution. As covariates, we  calculated average temperature and precipitation at 0.5 degree resolution. 



Upscaling 100m resolution elevation data for Europe to 0.5 degrees using a 2km radius window took: 

## Exploration and transformation

What do the variables look like spatially?

![](forest_files/figure-html/spatial_plot-1.png)<!-- -->

How are the variables distributed and where are the correlations?

![](forest_files/figure-html/pairs-1.png)<!-- -->

MW Elevation is the lowest correlation except for total precipitation (bio12). Highest correlation is with precipitation seasonality (bio15). Our expectation that variation in elevation would be important is supported here by the fact that the species richness correlation with mean elevation is lower. Species richness ideal for Poisson distribution; right skew to MW Elevation and LS elevation, Mean elevation, as well as the precipitation variables - need to transform. 

![](forest_files/figure-html/transform-1.png)<!-- -->

We scaled the data (mean = 0, sd = 1) so that the partial regression coefficients are comparable. 



# Models

## Global model

We are including the quadratic term for temperature (bio1) and precipitation (bio12), due to the shape of the relationship between these variables (and based on some earlier residual diagnostics)


fvariable                          coef    2.5 %   97.5 %
------------------------------  -------  -------  -------
(Intercept)                       3.067    3.020    3.115
MW elevation                     -0.262   -0.378   -0.147
LS elevation                      0.262    0.151    0.374
Mean elevation                    0.193    0.140    0.246
Mean elevation : MW elevation     0.139    0.066    0.212
Mean elevation : LS elevation    -0.061   -0.130    0.008
Temperature                       0.152    0.121    0.183
Precipitation                     0.058    0.016    0.099
Precipitation seasonality        -0.150   -0.179   -0.120
Temperature (quadratic)          -0.237   -0.263   -0.212
Precipitation (quadratic)        -0.077   -0.094   -0.059

There is a negative effect of local-scale (2km) variation in elevation (MW Elevation), but a positive effect of landscape-scale (~50km) variation in elevation (LS Elevation). 

This model explains 40.99% of the deviance in tree species richness. This was calculated using D-squared. 

Check the model specification using the DHARMa package. 

![](forest_files/figure-html/global_validation-1.png)<!-- -->![](forest_files/figure-html/global_validation-2.png)<!-- -->![](forest_files/figure-html/global_validation-3.png)<!-- -->![](forest_files/figure-html/global_validation-4.png)<!-- -->![](forest_files/figure-html/global_validation-5.png)<!-- -->![](forest_files/figure-html/global_validation-6.png)<!-- -->![](forest_files/figure-html/global_validation-7.png)<!-- -->

Based on the residual diagnostics, have gone with a negative binomial model due to overdispersion. The earlier version of the diagnostics also found patterns with temperature (bio1) and precipitation (bio12), hence the inclusion of their quadratic terms.

## Parsimonious model

This model is determined using stepwise selection. 


```
## Start:  AIC=13737.94
## sprich ~ elevmean + winvar2000 + elevvar + elevmean:winvar2000 + 
##     elevmean:elevvar + bio1 + I(bio1^2) + bio12 + I(bio12^2) + 
##     bio15
## 
##                       Df Deviance   AIC
## <none>                     2078.5 13738
## - elevmean:elevvar     1   2081.5 13739
## - bio12                1   2086.1 13744
## - elevmean:winvar2000  1   2092.4 13750
## - I(bio12^2)           1   2149.6 13807
## - bio1                 1   2170.6 13828
## - bio15                1   2177.8 13835
## - I(bio1^2)            1   2413.3 14071
```

```
## Waiting for profiling to be done...
```

```
## Joining, by = "variable"
```



fvariable                          coef    2.5 %   97.5 %
------------------------------  -------  -------  -------
(Intercept)                       3.067    3.020    3.115
MW elevation                     -0.262   -0.378   -0.147
LS elevation                      0.262    0.151    0.374
Mean elevation                    0.193    0.140    0.246
Mean elevation : MW elevation     0.139    0.066    0.212
Mean elevation : LS elevation    -0.061   -0.130    0.008
Temperature                       0.152    0.121    0.183
Precipitation                     0.058    0.016    0.099
Precipitation seasonality        -0.150   -0.179   -0.120
Temperature (quadratic)          -0.237   -0.263   -0.212
Precipitation (quadratic)        -0.077   -0.094   -0.059

Full model retained. 

## Model average in MMI framework

Now to get the model averaged and variable importance estimates. We are using `dredge` to get the full list of models, then `model.avg` to get the estimates for the 95% confidence set. 


Table: Results of model averaging

fvariable                          coef    2.5 %   97.5 %   importance
------------------------------  -------  -------  -------  -----------
(Intercept)                       3.064    3.016    3.112           NA
MW elevation                     -0.272   -0.385   -0.159    1.0000000
LS elevation                      0.274    0.164    0.385    1.0000000
Mean elevation                    0.194    0.143    0.245    1.0000000
Mean elevation : MW elevation     0.116    0.036    0.197    1.0000000
Mean elevation : LS elevation    -0.061   -0.129    0.006    0.6152004
Temperature                       0.150    0.119    0.181    1.0000000
Precipitation                     0.060    0.020    0.099    1.0000000
Precipitation seasonality        -0.150   -0.180   -0.120    1.0000000
Temperature (quadratic)          -0.236   -0.262   -0.211    1.0000000
Precipitation (quadratic)        -0.077   -0.094   -0.059    1.0000000

# Plots and summary of main results

The window-based elevation measure was included in all supported models (summed Akaike weight = 1, as was the landscape elevation measure (summed Akaike weight = 1). MW elevation and LS elevation had a similar absolute effect size based on the partial regression coefficients. However, MW elevation had a negative effect on species richness, whereas for LS elevation it was positive. This suggests that topographic variation has different effects on tree species richness depending on the scale at which it is measured. The interaction between mean elevation and MW elevation was positive, and present in all supported models. This suggests that effect of local-scale topographic variation is positive at high altitudes, but negative at low altitudes. The opposite is true of LS elevation, although this interaction term is not as strong, and was not present in all supported models (summed Akaike weight = 0.62)

![](forest_files/figure-html/results_out-1.png)<!-- -->
