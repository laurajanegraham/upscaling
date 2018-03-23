library(knitr)

rmarkdown::render("power_analysis.Rmd", params = list(noise = 1), output_file = "results/power_analysis_noise1.html")
rmarkdown::render("power_analysis.Rmd", params = list(noise = 0.5), output_file = "results/power_analysis_noise0.5.html")
rmarkdown::render("power_analysis.Rmd", params = list(noise = 0.1), output_file = "results/power_analysis_noise0.1.html")