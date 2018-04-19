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


# render all the files for supplementary material

# forest.Rmd, jays.Rmd and simulations.Rmd contain all the code to replicate the
# analyses and should be shared as supplementary material (in addition, the
# repository for the analysis and the package will be put on zenodo as a
# snapshot)
rmarkdown::render("forest.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S4_forest.pdf", envir = new.env())
rmarkdown::render("jays.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S3_jay.pdf", envir = new.env())
rmarkdown::render("supp_mat.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S1_supp_mat.pdf", envir = new.env())
rmarkdown::render("simulations.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S2_simulations.pdf", envir = new.env())





# now the final results plot
library(ggplot2)
library(cowplot)

# set the theme (incl. font size) for the figures for the paper
plot_theme <- theme_set(theme_classic(base_size = 7) + theme(strip.background = element_blank()))

# Ecol. Letts. figures: 82mm, 110mm, 173mm
# save jays spatial plot
load("results/jays_spatial.Rda")
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/jay_data_figure.tiff", 
          spatial_plot, base_width = 6.81102, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/lores_jay_data_figure.png", 
          spatial_plot, base_width = 6.81102)

# save forest spatial plot
load("results/forest_spatial.Rda")
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/forest_data_figure.tiff", 
          spatial_plot, base_width = 6.81102, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/lores_forest_data_figure.png", 
          spatial_plot, base_width = 6.81102)

# combine the jay and forests results plots into one figure
load("results/jay_res_figure.Rda")
load("results/forest_res_figure.Rda")
res_figure <- plot_grid(jay_figure, forest_figure, nrow = 2, labels = c("a)", "b)"), label_size = 10, hjust = 0)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/main_results.tiff", 
          res_figure, base_width = 4.33070866, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/main_results.png", 
          res_figure, base_width = 4.33070866)
