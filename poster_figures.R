# Figures ----
library(raster)
library(NLMR)
library(tidyverse)
library(cowplot)

out_path <- "~/Google Drive/SCALEFORES/Presentations/201804 IFLS Upscaling"

# set the theme (incl. font size) for the figures for the paper
theme_set(theme_classic(base_size = 12) + theme(strip.background = element_blank()))


# Methods box
ls <- nlm_random(10, 10) %>% as.data.frame(xy = TRUE)
w1 <- data.frame(x = rep(c(0.5, 1.5, 2.5), times = 3), y = rep(c(7.5, 8.5, 9.5), each = 3))
w2 <- mutate(w1, x = x+1)
w3 <- mutate(w2, x = x+1)

w1_plot <- ggplot() + 
  geom_raster(data = ls, aes(x = x, y = y, fill = layer)) + 
  geom_raster(data = w1, aes(x = x, y = y), fill = "grey", alpha = 0.7) + 
  annotate("text", x = 1.5, y = 8.5, label = "italic(f(x))", parse = TRUE, size = 4.23333) +
  annotate("text", x = 0, y = 11.2, hjust = 0, label = "Predictor grain", size = 4.23333) +
  annotate("text", x = 0, y = 12.6, hjust = 0, label = "Scale of effect", size = 4.23333) +
  annotate("text", x = 0, y = 14, hjust = 0, label = "Response grain", size = 4.23333) +
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
  annotate("text", x = 2.5, y = 8.5, label = "italic(f(x))", parse = TRUE, size = 4.23333) +
  annotate("text", x = 0, y = 11.2, hjust = 0, label = "Predictor grain", size = 4.23333, colour = "white") +
  annotate("text", x = 0, y = 12.6, hjust = 0, label = "Scale of effect", size = 4.23333, colour = "white") +
  annotate("text", x = 0, y = 14, hjust = 0, label = "Response grain", size = 4.23333, colour = "white") +
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
  annotate("text", x = 3.5, y = 8.5, label = "italic(f(x))", parse = TRUE, size = 4.23333) +
  annotate("text", x = 0, y = 11.2, hjust = 0, label = "Predictor grain", size = 4.23333, colour = "white") +
  annotate("text", x = 0, y = 12.6, hjust = 0, label = "Scale of effect", size = 4.23333, colour = "white") +
  annotate("text", x = 0, y = 14, hjust = 0, label = "Response grain", size = 4.23333, colour = "white") +
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

save_plot(paste0(out_path, "/methods_figure.tiff"), method_plot, base_width = 8.622047, base_height = 3.93701, dpi = 300)


# Jay box
load("results/jays_covs_plot.Rda")
load("results/jays_response_plot.Rda")
load("results/jays_res_figure.Rda")

jay_plot$theme <- NULL
cov_plot$theme <- NULL

jay_spatial_plot <- plot_grid(jay_plot, cov_plot, labels = c("a)", "b)"), label_size = 14, rel_widths = c(1, 1.5), nrow = 2)

save_plot(paste0(out_path, "/jay_data_figure.tiff"), jay_spatial_plot, base_width = 7.48031, base_height = 8.66142, dpi = 300)
save_plot(paste0(out_path, "/jay_results_figure.tiff"), jay_figure, base_width = 8.7598425, base_height = 4.72441, dpi = 300)

# Forest box
load("results/forests_cov_plot.Rda")
load("results/forests_response_plot.Rda")
load("results/forests_res_figure.Rda")

sp_plot$theme <- NULL
cov_plot$theme <- NULL

forest_spatial_plot <- plot_grid(sp_plot, cov_plot, labels = c("a)", "b)"), label_size = 14, rel_widths = c(1, 1.5), nrow = 2)

save_plot(paste0(out_path, "/forest_data_figure.tiff"), forest_spatial_plot, base_width = 7.48031, base_height = 8.66142, dpi = 300)
save_plot(paste0(out_path, "/forest_results_figure.tiff"), forest_figure, base_width = 8.7598425, base_height = 4.72441, dpi = 300)

# Theoretical underpinning box
load("results/contsim_ls_plot.Rda")
load("results/contsim_results_plot.Rda")

cont_figure <- plot_grid(cont_res_plot, cont_ls_plot, rel_widths = c(2, 1))

save_plot(paste0(out_path, "/contsim_figure.tiff"), cont_figure, base_width = 8.0354331, base_height = 5.8149606, dpi = 300)
