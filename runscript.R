# this ensures that the font size used for figures is the same across all figures
plot_font_size = 7

rmarkdown::render("forest.Rmd", params = list(plot_font_size = plot_font_size), output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/forest.html")
rmarkdown::render("jays.Rmd", params = list(plot_font_size = plot_font_size), output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/jays.html")
rmarkdown::render("simulations.Rmd", params = list(plot_font_size = plot_font_size), output_file = "~/Google Drive/SCALEFORES/Papers/Upscaling/supp_mat/simulations.html")

# now the final results plot
library(ggplot2)
library(cowplot)

# combine the jay and forests results plots into one figure
load("results/jay_res_figure.Rda")
load("results/forest_res_figure.Rda")

plot_theme <- theme_set(theme_classic(base_size = plot_font_size) + theme(strip.background = element_blank()))

res_figure <- plot_grid(forest_figure, jay_figure, nrow = 2, labels = c("a)", "b)"), label_size = 10, hjust = 0)

# Ecol. Letts. figures: 82mm, 110mm, 173mm
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/main_results.tiff", 
          res_figure, base_width = 4.33070866, dpi = 300)
save_plot("~/Google Drive/SCALEFORES/Papers/Upscaling/figures/main_results.png", 
          res_figure, base_width = 4.33070866)
