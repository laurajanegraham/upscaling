torus_create <- function(ls, r) {
  # This function takes as input a raster and an integer radius value.
  # The output is a raster that is padded by r, creating the effect of a torus and allowing us to deal with edge effects
  # Pad raster to create torus effect ----
  # There must be a better way to do this...
  
  #   1. Convert raster to matrix
  ls_m <- raster::as.matrix(ls)
  nrows <- nrow(ls_m)
  ncols <- ncol(ls_m)
  
  #   2. Create new matrix of dim + radius*2
  ls_pad_m <- matrix(NA, nrow=nrows + 2*r, ncol=ncols + 2*r)
  
  #   3. Infill with values from the matrix
  # top
  ls_pad_m[1:r,(r+1):(ncols+r)] <- ls_m[(nrows-r+1):nrows,]
  # left
  ls_pad_m[(r+1):(nrows+r),1:r] <- ls_m[,(ncols-r+1):ncols]
  # bottom
  ls_pad_m[(nrows+r+1):(nrows+2*r),(r+1):(ncols+r)] <- ls_m[1:r,]
  # right
  ls_pad_m[(r+1):(nrows+r),(ncols+r+1):(ncols+2*r)] <- ls_m[,1:r]
  # top left corner
  ls_pad_m[1:r,1:r] <- ls_m[(nrows-r+1):nrows,(ncols-r+1):ncols]
  # top right corner
  ls_pad_m[1:r,(ncols+r+1):(ncols+2*r)] <- ls_m[(nrows-r+1):nrows,1:r]
  # bottom left corner
  ls_pad_m[(nrows+r+1):(nrows+2*r),1:r] <- ls_m[1:r,(ncols-r+1):ncols]
  # bottom right corner
  ls_pad_m[(nrows+r+1):(nrows+2*r),(ncols+r+1):(ncols+2*r)] <- ls_m[1:r,1:r]
  # centre
  ls_pad_m[(r+1):(nrows+r), (r+1):(ncols+r)] <- ls_m
  
  #   4. convert to raster
  ls_pad <- raster::raster(ls_pad_m)
  
  #   5. Fix resolution
  # specify resolution ----
  raster::extent(ls_pad) <- c(
    0,
    ncol(ls_pad),
    0,
    nrow(ls_pad)
  )
  
  return(ls_pad)
  
}