ls_create <- function(x) {
  ls <- nlm_mpd(ncol = x['ncol'], nrow = x['nrow'], roughness = x['roughness'], rescale = FALSE, verbose = FALSE)
  
  # scale to mean = 0 and sd = 1: this is for comparison between different simulated landscapes
  ls <- raster::scale(ls)

  # get a dataframe out for ease of plotting
  ls_df <- raster::as.data.frame(ls, xy = TRUE) %>% cbind(x %>% as.data.frame %>% t)
  
  return(list(params = x, ls = ls, ls_df = ls_df))
}