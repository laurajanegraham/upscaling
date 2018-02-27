# Upscaling: Jay Case Study
Laura Graham  



# Case study 1: Jays

## Data

### Relative abundance index

First we need to load in and spatialise the Jay (*Garrulus glandarius*) data. These were provided by Simon Gillings at the BTO. The data includes the relative abundance indices for the 1990 Atlas (index90) and for the 2010 Atlas (index10). 



### Environmental data

The data for which we want to use the upscaling approach on is Land Cover Map 2007 [@Morton2011], which is the closest match to the 2010 relative abundance index for jays. We will use the moving window to upscale diversity of the two used habitats: Broadleaf and Coniferous forest (LCM codes 1, 2). Eurasian jays use a combination of these habitats: broadleaf for foraging, coniferous for nesting [@Hougner2005; @Holden2006]. We will calculate Shannon Diversity on just these two habitats to create a measure of the landscape structure used by jays. We will calculate Shannon diversity using the moving window approach at the 1km scale [needs citation] and without the moving window at the 10km scale. As covariates, to avoid confounding variables, we will calculate forest (habitat) cover percentage, urban land cover percentage and average temperature at the 10km scale. 



### Exploration and transformation

What do the variables look like spatially?


```
## Warning: attributes are not identical across measure variables;
## they will be dropped
```

![](jays_files/figure-html/spatial_plot-1.png)<!-- -->

what are the minimum and maximum values? 


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


## Models 

Using the approch outlined by [@Smith2009a; @Smith2011c] we use three approaches to quantify the relative importance of the window-based Shannon measure over the more traditional landscape level measure (and habitat amount??): we compare the partial regression coefficients from a global model, the parsimonious model, and the model average of all supported models in a multi-model inference framework (MMI)

### Global model

This is the model which contains all predictors (window- and landscape-based Shannon measure, habitat amount, and the interaction between habitat amount and the two Shannon measures) and the additional covariates (urban cover and average temperature). 

I'm not currently sure about interactions... I think it is useful to include interactions between habitat amount and the two Shannon measures, but my worry here is that the main effect then becomes less interpretable [this was one of my concerns with @Smith2011c, although I think they dealt with it reasonably well]. 

I need to properly look into the error structure for the models, because it is proportion data and therefore bounded at 0, 1. For now am incorrectly using normal distribution see [Warton and Hui 2011](http://onlinelibrary.wiley.com/doi/10.1890/10-0340.1/full) for discussion of analysis of proportion data. Normal distribution can be problematic with ratio data unless numerator variance >> denominator variance. In our case, the denominator is always the same, so it should be fine to model with a normal distribution? My main concern is it looks much more like a Poisson distribution (or zero-inflated for 1990 index).


fvariable                  coef    2.5 %   97.5 %
----------------------  -------  -------  -------
Intercept                 0.314    0.304    0.325
MW Shannon                0.054    0.012    0.097
LS Shannon               -0.008   -0.057    0.042
Forest %                  0.052    0.022    0.083
Forest % : MW Shannon     0.017   -0.020    0.053
Forest % : LS Shannon    -0.025   -0.062    0.012
Urban %                   0.027    0.018    0.036
Temperature               0.099    0.089    0.109

First model looks to fit my expectation - partial regression coefficient for window-based Shannon is significant and larger than the landscape-based Shannon coefficient, habitat (marginally) and the interaction terms. 

The model is significant (p < 0.001) and explains 37.8% of the variance in jay abundance. 

Need to check how terrible this model is:

![](jays_files/figure-html/global_validation-1.png)<!-- -->![](jays_files/figure-html/global_validation-2.png)<!-- -->


It's quite bad. I think this is to do with using the normal distribution (we have negative predicted values, and no predicted values higher than 0.6605497). Need to work out the right distribution for this and check again. 

### Parsimonious model

This model is determined using stepwise selection. 


```
## Start:  AIC=-6570.94
## index10 ~ habitat + winshannon + lsshannon + urban + tavg + habitat:lsshannon + 
##     habitat:winshannon
## 
##                      Df Sum of Sq    RSS     AIC
## - habitat:winshannon  1    0.0208 46.607 -6572.1
## - habitat:lsshannon   1    0.0466 46.633 -6571.1
## <none>                            46.586 -6570.9
## - urban               1    0.8536 47.440 -6540.2
## - tavg                1   10.4435 57.030 -6208.5
## 
## Step:  AIC=-6572.13
## index10 ~ habitat + winshannon + lsshannon + urban + tavg + habitat:lsshannon
## 
##                     Df Sum of Sq    RSS     AIC
## <none>                           46.607 -6572.1
## - habitat:lsshannon  1    0.1389 46.746 -6568.8
## - winshannon         1    0.4806 47.088 -6555.6
## - urban              1    0.8402 47.447 -6541.9
## - tavg               1   10.7199 57.327 -6201.1
```

```
## Joining, by = "variable"
```



fvariable                  coef    2.5 %   97.5 %
----------------------  -------  -------  -------
Intercept                 0.314    0.304    0.325
MW Shannon                0.068    0.012    0.097
LS Shannon               -0.018   -0.057    0.042
Forest %                  0.049    0.022    0.083
Forest % : LS Shannon    -0.009   -0.062    0.012
Urban %                   0.027    0.018    0.036
Temperature               0.099    0.089    0.109

Again, the absolute value of the partial regression coefficient for the window-based Shannon measure is larger than the landscape-based version and habitat amount (as well as the interaction between the landscape based version and habitat amount). The model is significant (p < 0.001) and explains 37.77% of the variance in jay abundance. 

How bad is this one? 

![](jays_files/figure-html/simple_validation-1.png)<!-- -->![](jays_files/figure-html/simple_validation-2.png)<!-- -->

### Model average in MMI framework

Now to get the model averaged and variable importance estimates. We are using `dredge` to get the full list of models, then model.avg to get the estimates for the 95% confidence set. 


Table: Results of model averaging

fvariable                  coef    2.5 %   97.5 %
----------------------  -------  -------  -------
Intercept                 0.314    0.304    0.324
MW Shannon                0.065    0.031    0.099
LS Shannon               -0.018   -0.064    0.029
Forest %                  0.046    0.016    0.076
Forest % : MW Shannon    -0.002   -0.032    0.028
Forest % : LS Shannon    -0.014   -0.042    0.013
Urban %                   0.027    0.018    0.036
Temperature               0.100    0.090    0.109

Window-based Shannon measure again coming out as more important than the landscape-based version using both the model averaged partial regression coefficients and the sum of Akaike weights (importance in the above table). 

## Plots and summary of main results

The window-based Shannon measure was included in all supported models (summed Akaike weight = 1, whereas the landscape-based Shannon measure was not (summed Akaike weight = 0.73). The greater importance of the window-based measure is also demonstrated by its larger absolute effect and constant significance in all three modelling approaches (Figure xx). 

![](jays_files/figure-html/results_out-1.png)<!-- -->

## References
