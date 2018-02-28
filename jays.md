# Upscaling: Jay Case Study
Laura Graham  



# Data

## Relative abundance index

First we need to load in and spatialise the Jay (*Garrulus glandarius*) data. These were provided by Simon Gillings at the BTO. The data includes the relative abundance indices for the 1990 Atlas (index90) and for the 2010 Atlas (index10). 



## Environmental data

The data for which we want to use the upscaling approach on is Land Cover Map 2007 [@Morton2011], which is the closest match to the 2010 relative abundance index for jays. We will use the moving window to upscale diversity of the two used habitats: Broadleaf and Coniferous forest (LCM codes 1, 2). Eurasian jays use a combination of these habitats: broadleaf for foraging, coniferous for nesting [@Hougner2005; @Holden2006]. We will calculate Shannon Diversity on just these two habitats to create a measure of the landscape structure used by jays. We will calculate Shannon diversity using the moving window approach at the 1km scale [needs citation] and without the moving window at the 10km scale. As covariates, to avoid confounding variables, we will calculate forest (habitat) cover percentage, urban land cover percentage and average temperature at the 10km scale. 



## Exploration and transformation

What do the variables look like spatially?

![](jays_files/figure-html/spatial_plot-1.png)<!-- -->

What are the minimum and maximum values? 


variable                     min       max
-----------------------  -------  --------
Abundance (1990 Atlas)     0.000     1.000
Abundance (2010 Atlas)     0.000     1.000
MW Shannon                 0.004     0.893
LS Shannon                 0.005     1.019
Forest %                   0.000     0.752
Urban %                    0.000     0.875
Temperature               43.000   109.000

Bit worrying that the maximum value for landscape-Shannon is (slightly) above 1... Need to go back and check, but it generally looks about right otherwise. 

How are the variables distributed?

![](jays_files/figure-html/distribution-1.png)<!-- -->

Lots of zeros in the 1990 index. Likely that this is more to do with surveyed cells than actual abundances. Start with the 2010 Atlas, then if we move to look at comparison we might want to think of removing zero rows (or rows which are not zero in both 2010 and 1990). 

Right skew to habitat percentage and urban percentage, and left skew to temperature. 

And where are the correlations?

![](jays_files/figure-html/pairs-1.png)<!-- -->

Good sign to start! Strongest correlate of both indices is temperature followed by the window-based Shannon measure. After that it's urban percentage, followed by the landscape-based Shannon measure, followed by percentage cover of habitat. Interestingly, although both Shannon measures correlate with the amount of habitat, the window-based measure is least correlated with this (still very high). The 0.9649287 between the two Shannon measures means we will have issues with Type II errors when we include both - need to remember this. One point about the 'high' (not really high, but relative to other predictors) correlation between urban percentage and jay abundance: this is potentially an observation thing, but also jays are becoming more associated with urban habitats [parks, cemetaries etc, see @Holden2006], so it may be a real effect. Anyway, it's worth including. 

Based on distributions (and some initial modeling not shown) need to transform the temperature, habitat and urban percentage variables:

![](jays_files/figure-html/transform-1.png)<!-- -->

Better, stick with this for now. It's fine because we don't need to interpret these coefficients. 

Now scale the data (mean = 0, sd = 1) so that the partial regression coefficients are comparable. 


# Models 

Using the approch outlined by [@Smith2009a; @Smith2011c] we use three approaches to quantify the relative importance of the window-based Shannon measure over the more traditional landscape level measure (and habitat amount??): we compare the partial regression coefficients from a global model, the parsimonious model, and the model average of all supported models in a multi-model inference framework (MMI)

## Global model

This is the model which contains all predictors (window- and landscape-based Shannon measure, habitat amount, and the interaction between habitat amount and the two Shannon measures) and the additional covariates (urban cover and average temperature). 

I'm not currently sure about interactions... I think it is useful to include interactions between habitat amount and the two Shannon measures, but my worry here is that the main effect then becomes less interpretable [this was one of my concerns with @Smith2011c, although I think they dealt with it reasonably well]. 

I need to properly look into the error structure for the models, because it is proportion data and therefore bounded at 0, 1. For now am incorrectly using normal distribution see [Warton and Hui 2011](http://onlinelibrary.wiley.com/doi/10.1890/10-0340.1/full) for discussion of analysis of proportion data. Normal distribution can be problematic with ratio data unless numerator variance >> denominator variance. In our case, the denominator is always the same, so it should be fine to model with a normal distribution? My main concern is it looks much more like a Poisson distribution (or zero-inflated for 1990 index).

I'm going to try an attempt at Beta regression [@Cribari-Neto2010], which works for proportions without having the drawback of being uninterpretable on the scale of the variable (like regression with a logit transform would be). Beta regression doesn't work if the data are [0, 1]: needs to be (0, 1). Binomial regression may be more appropriate. MW Shannon is much stronger using this. I just need to work out how . The model fit is also slightly better, so I may want to come back and change this.  


fvariable                  coef    2.5 %   97.5 %
----------------------  -------  -------  -------
Intercept                -0.849   -0.998   -0.703
MW Shannon                0.410   -0.206    1.041
LS Shannon               -0.162   -0.879    0.552
Forest %                  0.246   -0.203    0.669
Forest % : MW Shannon    -0.083   -0.617    0.452
Forest % : LS Shannon     0.031   -0.515    0.575
Urban %                   0.142    0.013    0.270
Temperature               0.518    0.378    0.662

First model looks to fit my expectation - partial regression coefficient for window-based Shannon is significant and larger than the landscape-based Shannon coefficient, habitat (marginally) and the interaction terms. 

The model explains 36.47% of the variance in jay abundance. 

Need to check how terrible this model is:

![](jays_files/figure-html/global_validation-1.png)<!-- -->![](jays_files/figure-html/global_validation-2.png)<!-- -->![](jays_files/figure-html/global_validation-3.png)<!-- -->![](jays_files/figure-html/global_validation-4.png)<!-- -->![](jays_files/figure-html/global_validation-5.png)<!-- -->![](jays_files/figure-html/global_validation-6.png)<!-- -->


Binomial model looks a lot better than the normal one did, although there are still no fitted values higher than 0.7. Overall it seems like it's underpredicting high values and overpredicting low. 

## Parsimonious model

This model is determined using stepwise selection. 


```
## Start:  AIC=1555.95
## index10 ~ habitat + winshannon + lsshannon + urban + tavg + habitat:lsshannon + 
##     habitat:winshannon
## 
##                      Df Deviance    AIC
## - habitat:lsshannon   1   243.57 1554.0
## - habitat:winshannon  1   243.65 1554.0
## <none>                    243.56 1556.0
## - urban               1   248.25 1558.6
## - tavg                1   297.53 1607.9
## 
## Step:  AIC=1554.05
## index10 ~ habitat + winshannon + lsshannon + urban + tavg + habitat:winshannon
## 
##                      Df Deviance    AIC
## - lsshannon           1   243.79 1552.3
## - habitat:winshannon  1   244.55 1553.0
## <none>                    243.57 1554.0
## - urban               1   248.27 1556.8
## - tavg                1   298.38 1606.8
## 
## Step:  AIC=1553.38
## index10 ~ habitat + winshannon + urban + tavg + habitat:winshannon
## 
##                      Df Deviance    AIC
## - habitat:winshannon  1   245.30 1552.9
## <none>                    243.79 1553.4
## - urban               1   248.80 1556.4
## - tavg                1   302.19 1609.8
## 
## Step:  AIC=1550.38
## index10 ~ habitat + winshannon + urban + tavg
## 
##              Df Deviance    AIC
## <none>            245.30 1550.4
## - habitat     1   247.75 1550.8
## - winshannon  1   247.90 1551.0
## - urban       1   251.17 1554.2
## - tavg        1   303.23 1606.3
```

```
## Waiting for profiling to be done...
```

```
## Joining, by = "variable"
```



fvariable        coef    2.5 %   97.5 %
------------  -------  -------  -------
Intercept      -0.893   -0.998   -0.703
MW Shannon      0.239   -0.206    1.041
Forest %        0.250   -0.203    0.669
Urban %         0.156    0.013    0.270
Temperature     0.522    0.378    0.662

This model kicks out LS Shannon entirely. The MW Shannon is no longer significant (but still in the model). 

How bad is this one? 

![](jays_files/figure-html/simple_validation-1.png)<!-- -->![](jays_files/figure-html/simple_validation-2.png)<!-- -->![](jays_files/figure-html/simple_validation-3.png)<!-- -->![](jays_files/figure-html/simple_validation-4.png)<!-- -->![](jays_files/figure-html/simple_validation-5.png)<!-- -->![](jays_files/figure-html/simple_validation-6.png)<!-- -->

This looks worse than the global model...

## Model average in MMI framework

Now to get the model averaged and variable importance estimates. We are using `dredge` to get the full list of models, then model.avg to get the estimates for the 95% confidence set. 


Table: Results of model averaging

fvariable                  coef    2.5 %   97.5 %   importance
----------------------  -------  -------  -------  -----------
Intercept                -0.884   -1.005   -0.764           NA
MW Shannon                0.317   -0.080    0.714    0.8730909
LS Shannon               -0.188   -0.772    0.396    0.4921854
Forest %                  0.304   -0.069    0.678    1.0000000
Forest % : MW Shannon    -0.058   -0.159    0.044    0.1300336
Forest % : LS Shannon    -0.052   -0.158    0.055    0.0526900
Urban %                   0.152    0.024    0.280    1.0000000
Temperature               0.518    0.379    0.657    1.0000000

Window-based Shannon measure again coming out as more important than the landscape-based version using both the model averaged partial regression coefficients and the sum of Akaike weights (importance in the above table). MW Shannon still not significant, but has much smaller confidence interval than LS Shannon. 

# Plots and summary of main results

The window-based Shannon measure was included in more supported models (summed Akaike weight = 0.87than the landscape-based Shannon measure (summed Akaike weight = 0.49). The greater importance of the window-based measure is also demonstrated by its larger absolute effect and smaller confidence intervals in the global and mmi modelling approaches. LS Shannon was not present in the parsimonious modelling approach. Results for the global model are shown. 

![](jays_files/figure-html/results_out-1.png)<!-- -->

So using the binomial model is correctly specified, but habitat is no longer important (well, it's important in terms of variable importance, but the habitat variables are no longer significant). 

# References
