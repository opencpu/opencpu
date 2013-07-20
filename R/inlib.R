inlib <- function(lib, expr, add=TRUE){
  oldlib <- .libPaths();
  on.exit(
    setlib(oldlib)
  )
  if(isTRUE(add)){
    lib <- c(lib, .libPaths());
  } 
  lib <- unique(normalizePath(lib, mustWork=FALSE));
  lib <- Filter(function(x){ 
    isTRUE(file.info(x)$isdir) 
  }, lib);
  setlib(lib);
  return(force(expr));  
}

setlib <- function(lib){
  assign(".lib.loc", lib, envir=environment(.libPaths));
}
