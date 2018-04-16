library(knitr)

rmarkdown::render("power_analysis.Rmd", params = list(noise = 1, n_reps = 100), output_file = "results/power_analysis_noise1.html")
rmarkdown::render("power_analysis.Rmd", params = list(noise = 0.5, n_reps = 100), output_file = "results/power_analysis_noise0.5.html")
rmarkdown::render("power_analysis.Rmd", params = list(noise = 0.1, n_reps = 100), output_file = "results/power_analysis_noise0.1.html")


x <- rnorm(100, 0, 1)

y1 <- 1 + 5*x + rnorm(100, 0, 5)
y2 <- 1 + 2*x - 3*x^2 + rnorm(100, 0, 5)
y3 <- 1 + 2*x - x^2 + 2*x^3 + rnorm(100, 0, 5)

df <- data.frame(x = x, y1 = y1, y2 = y2, y3 = y3)

ggplot(df, aes(x = x, y = y1)) + 
  geom_smooth(method = "lm") + 
  labs(x = "", y = "") + 
  theme(axis.text = element_blank(), axis.ticks = element_blank())

ggplot(df, aes(x = x, y = y2)) + 
  geom_smooth(method = "lm", formula = "y ~ poly(x, 2)") + 
  labs(x = "", y = "") + 
  theme(axis.text = element_blank(), axis.ticks = element_blank())

ggplot(df, aes(x = x, y = y3)) + 
  geom_smooth(method = "lm", formula = "y ~ poly(x, 3)") + 
  labs(x = "", y = "") + 
  theme(axis.text = element_blank(), axis.ticks = element_blank())


lscape <- nlmr::nlm_mpd(10, 10, 0.5) %>% raster::as.data.frame(xy = TRUE)

ggplot(lscape, aes(x = x, y = y, fill = layer)) + 
  geom_raster() + 
  coord_equal() + 
  scale_fill_viridis_c() + 
  geom_rect(ymin = 7, ymax = 8.5, xmin = 0, xmax = 1.5, fill = "grey", alpha = 0.02) + 
  annotate("text", x = 0.75, y = 7.75, label = "f(x)") + 
  theme(legend.position = "none", axis.line = element_blank(), axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank())

ggplot(lscape, aes(x = x, y = y, fill = layer)) + 
  geom_raster() + 
  coord_equal() + 
  scale_fill_viridis_c() + 
  geom_rect(ymin = 7, ymax = 8.5, xmin = 0.5, xmax = 2, fill = "grey", alpha = 0.02) + 
  annotate("text", x = 1.25, y = 7.75, label = "f(x)") + 
  theme(legend.position = "none", axis.line = element_blank(), axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank())

ggplot(lscape, aes(x = x, y = y, fill = layer)) + 
  geom_raster() + 
  coord_equal() + 
  scale_fill_viridis_c() + 
  geom_rect(ymin = 7, ymax = 8.5, xmin = 1, xmax = 2.5, fill = "grey", alpha = 0.02) + 
  annotate("text", x = 1.75, y = 7.75, label = "f(x)") + 
  theme(legend.position = "none", axis.line = element_blank(), axis.ticks = element_blank(), axis.text = element_blank(), axis.title = element_blank())


