# For each landscape:
ls_analyse <- function(x, fn, lc_class = NULL){
  r <- x$params['radius']
  ls <- x$ls
  
  if (fn == "diversity") {
    wt <- rep(1/length(lc_class), length(lc_class))
    ls <- util_classify(ls, weighting = wt)
  } 
  
  # 1. apply create_torus to pad
  ls_pad <- torus_create(ls, r)
  
  # 2. do winmover
  mw_var <- winmove_nbrhd(ls_pad, radius = r, type = "rectangle", fn = fn, lc_class = lc_class)
  
  # 3. crop raster (may require a new function)
  mw_var <- raster::trim(mw_var)
  
  # 4. Calculate mean value (nomove function)
  val <- mean(as.vector(mw_var))
  out <- data.frame(t(x$params), val = val)
  return(out)
}