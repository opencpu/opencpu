inlib <- function(lib, expr, add = TRUE){
  oldlib <- .libPaths();
  on.exit(setlib(oldlib), add = TRUE)
  if(isTRUE(add)){
    lib <- c(lib, .libPaths())
  }
  lib <- unique(normalizePath(lib, mustWork = FALSE))
  lib <- Filter(function(x){
    isTRUE(file.info(x)$isdir)
  }, lib)
  setlib(lib)
  force(expr)
}

setlib <- function(lib){
  assign(".lib.loc", lib, envir = environment(.libPaths))
}
