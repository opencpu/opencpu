inlib <- function(lib, expr, addbaselib=TRUE){
  oldlib <- .libPaths();
  on.exit(
    setlib(oldlib)
  );
  if(isTRUE(addbaselib)){
    lib <- c(lib, dirname(system.file(package="base")));    
  }
  setlib(lib);
  return(force(expr));  
}

setlib <- function(lib){
  stopifnot(isTRUE(all(file.info(lib)$isdir)));
  assign(".lib.loc", lib, envir=environment(.libPaths));
}
