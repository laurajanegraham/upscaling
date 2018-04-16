# this ensures that the font size used for figures is the same across all figures
plot_font_size = 7

rmarkdown::render("forest.Rmd")
rmarkdown::render("jays.Rmd")
rmarkdown::render("simulations.Rmd")
rmarkdown::render("supp_mat.Rmd", output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat.pdf")

# now the final results plot
library(ggplot2)
library(cowplot)

# combine the jay and forests results plots into one figure
load("results/jay_res_figure.Rda")
load("results/forest_res_figure.Rda")
load("results/forest_spatial.Rda")

plot_theme <- theme_set(theme_classic(base_size = plot_font_size) + theme(strip.background = element_blank()))

res_figure <- plot_grid(jay_figure, forest_figure, nrow = 2, labels = c("a)", "b)"), label_size = 10, hjust = 0)

# Ecol. Letts. figures: 82mm, 110mm, 173mm
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/forest_data_figure.tiff", 
          spatial_plot, base_width = 6.81102, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/lores_forest_data_figure.png", 
          spatial_plot, base_width = 6.81102)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/main_results.tiff", 
          res_figure, base_width = 4.33070866, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/main_results.png", 
          res_figure, base_width = 4.33070866)
