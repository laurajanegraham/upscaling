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

# forest.Rmd, jays.Rmd and simulations.Rmd contain all the code to replicate the
# analyses and should be shared as supplementary material (in addition, the
# repository for the analysis and the package will be put on zenodo as a
# snapshot)
rmarkdown::render("supp_mat.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S1_supp_mat.pdf", envir = new.env())
rmarkdown::render("simulations.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S2_simulations.pdf", envir = new.env())
rmarkdown::render("jays.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S3_jay.pdf", envir = new.env())
rmarkdown::render("forest.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S4_forest.pdf", envir = new.env())
rmarkdown::render("power_analysis.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/S5_power_analysis.pdf", envir = new.env())


# Figures ----
library(ggplot2)
library(cowplot)

# set the theme (incl. font size) for the figures for the paper
plot_theme <- theme_set(theme_classic(base_size = 7) + theme(strip.background = element_blank()))

# Ecol. Letts. figures: 82mm (3.22835"), 110mm (4.33071"), 173mm (6.81102")
# Figure 1 - methods figure
ls <- nlm_random(10, 10) %>% as.data.frame(xy = TRUE)
w1 <- data.frame(x = rep(c(0.5, 1.5, 2.5), times = 3), y = rep(c(7.5, 8.5, 9.5), each = 3))
w2 <- mutate(w1, x = x+1)
w3 <- mutate(w2, x = x+1)

w1_plot <- ggplot() + 
  geom_raster(data = ls, aes(x = x, y = y, fill = layer)) + 
  geom_raster(data = w1, aes(x = x, y = y), fill = "grey", alpha = 0.7) + 
  annotate("text", x = 1.5, y = 8.5, label = "italic(f(x))", parse = TRUE, size = 2.5) +
  annotate("text", x = 0, y = 11.2, hjust = 0, label = "Predictor grain", size = 2.5) +
  annotate("text", x = 0, y = 12.6, hjust = 0, label = "Scale of effect", size = 2.5) +
  annotate("text", x = 0, y = 14, hjust = 0, label = "Response grain", size = 2.5) +
  geom_segment(aes(x=0, xend=1, y=10.5, yend=10.5), size = 0.5,
               arrow = arrow(length = unit(0.1, "cm"), ends = "both")) +
  geom_segment(aes(x=0, xend=3, y=11.9, yend=11.9), size = 0.5,
               arrow = arrow(length = unit(0.1, "cm"), ends = "both")) + 
  geom_segment(aes(x=0, xend=10, y=13.3, yend=13.3), size = 0.5,
               arrow = arrow(length = unit(0.1, "cm"), ends = "both")) + 
  scale_fill_viridis_c() + 
  coord_equal() + 
  theme(axis.line = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
        axis.title = element_blank(), legend.position = "none")

w2_plot <- ggplot() + 
  geom_raster(data = ls, aes(x = x, y = y, fill = layer)) + 
  geom_raster(data = w2, aes(x = x, y = y), fill = "grey", alpha = 0.7) + 
  annotate("text", x = 2.5, y = 8.5, label = "italic(f(x))", parse = TRUE, size = 2.5) +
  annotate("text", x = 0, y = 11.2, hjust = 0, label = "Predictor grain", size = 2.5, colour = "white") +
  annotate("text", x = 0, y = 12.6, hjust = 0, label = "Scale of effect", size = 2.5, colour = "white") +
  annotate("text", x = 0, y = 14, hjust = 0, label = "Response grain", size = 2.5, colour = "white") +
  geom_segment(aes(x=0, xend=1, y=10.5, yend=10.5), size = 0.5,
               arrow = arrow(length = unit(0.1, "cm"), ends = "both"), colour = "white") +
  geom_segment(aes(x=0, xend=3, y=11.9, yend=11.5), size = 0.5,
               arrow = arrow(length = unit(0.1, "cm"), ends = "both"), colour = "white") + 
  geom_segment(aes(x=0, xend=10, y=13.3, yend=12.5), size = 0.5,
               arrow = arrow(length = unit(0.1, "cm"), ends = "both"), colour = "white") + 
  scale_fill_viridis_c() + 
  coord_equal() + 
  theme(axis.line = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
        axis.title = element_blank(), legend.position = "none")

w3_plot <- ggplot() + 
  geom_raster(data = ls, aes(x = x, y = y, fill = layer)) + 
  geom_raster(data = w3, aes(x = x, y = y), fill = "grey", alpha = 0.7) + 
  annotate("text", x = 3.5, y = 8.5, label = "italic(f(x))", parse = TRUE, size = 2.5) +
  annotate("text", x = 0, y = 11.2, hjust = 0, label = "Predictor grain", size = 2.5, colour = "white") +
  annotate("text", x = 0, y = 12.6, hjust = 0, label = "Scale of effect", size = 2.5, colour = "white") +
  annotate("text", x = 0, y = 14, hjust = 0, label = "Response grain", size = 2.5, colour = "white") +
  geom_segment(aes(x=0, xend=1, y=10.5, yend=10.5), size = 0.5,
               arrow = arrow(length = unit(0.1, "cm"), ends = "both"), colour = "white") +
  geom_segment(aes(x=0, xend=3, y=11.9, yend=11.5), size = 0.5,
               arrow = arrow(length = unit(0.1, "cm"), ends = "both"), colour = "white") + 
  geom_segment(aes(x=0, xend=10, y=13.3, yend=12.5), size = 0.5,
               arrow = arrow(length = unit(0.1, "cm"), ends = "both"), colour = "white") + 
  scale_fill_viridis_c() + 
  coord_equal() + 
  theme(axis.line = element_blank(), axis.text = element_blank(), axis.ticks = element_blank(),
        axis.title = element_blank(), legend.position = "none")

method_plot <- plot_grid(w1_plot, w2_plot, w3_plot, nrow = 1, axis = "b")

save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F1_methods_figure.tiff", 
          method_plot, base_width = 4.33071, base_height = 2.15, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F1_methods_figure.png", 
          method_plot, base_width = 4.33071, base_height = 2.15)

# Figure 2 - Continuous simulations
load("results/contsim_figure.Rda")
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F2_contsim_figure.tiff", 
          cont_figure, base_width = 4.33071, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F2_lores_contsim_figure.png", 
          cont_figure, base_width = 4.33071)

# Figure 3 - Categorical simulations
load("results/catsim_figure.Rda")
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F3_catsim_figure.tiff", 
          cat_figure, base_width = 4.33071, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F3_lores_catsim_figure.png", 
          cat_figure, base_width = 4.33071)

# Figure 4 - Jay data
load("results/jays_spatial.Rda")
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F4_jays_data_figure.tiff", 
          spatial_plot, base_width = 6.81102, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F4_lores_jays_data_figure.png", 
          spatial_plot, base_width = 6.81102)

# Figure 5 - Forests data
load("results/forests_spatial.Rda")
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F5_forests_data_figure.tiff", 
          spatial_plot, base_width = 6.81102, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F5_lores_forests_data_figure.png", 
          spatial_plot, base_width = 6.81102)

# Figure 6 - main results
load("results/jays_res_figure.Rda")
load("results/forests_res_figure.Rda")
res_figure <- plot_grid(jay_figure, forest_figure, nrow = 2, labels = c("a)", "b)"), label_size = 10, hjust = 0)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F6_main_results.tiff", 
          res_figure, base_width = 4.33070866, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/F6_main_results.png", 
          res_figure, base_width = 4.33070866)
