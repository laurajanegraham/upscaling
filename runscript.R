# runscript.R: generate all results, figures and supplementary materials for the
# window-based upscaling paper

# load all packages upfront to avoid conflicting package loads within different .Rmd files
# (this is necessary until I work out how to make render self-contained - at present the
# envir = new.env() gets rid of objects, but not loaded packages)

# utility packages
library(R.utils)
library(knitr)

# statistical packages
library(MuMIn)
library(MASS)
library(DHARMa)
library(e1071) 

# spatial packages
library(landscapetools)
library(NLMR)
library(raster)
library(rgdal)
library(rgeos)
library(winmoveR)
library(sf)

# data tidying packages
library(plyr)
library(GGally)
library(cowplot)
library(broom)
library(tidyverse)


# Supplementary material ----

# jays.Rmd and simulations.Rmd contain all the code to replicate the
# analyses and should be shared as supplementary material (in addition, the
# repository for the analysis and the package will be put on zenodo as a
# snapshot)
rmarkdown::render("simulations.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S2_simulations.pdf", envir = new.env())
rmarkdown::render("jays.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S3_jay.pdf", envir = new.env())
