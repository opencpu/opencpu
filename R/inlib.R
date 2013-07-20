inlib <- function(lib, expr, addbaselib=TRUE, addsitelib=TRUE){
  oldlib <- .libPaths();
  on.exit(
    setlib(oldlib)
  );
  if(isTRUE(addsitelib)){
    lib <- c(lib, base:::.Library.site);    
  } else if(isTRUE(addbaselib)){
    lib <- c(lib, base:::.Library);    
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
