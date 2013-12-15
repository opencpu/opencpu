loadPackageFrom <- function(package, lib.loc){
  stopifnot(is.character(package));
  library(package, lib.loc=lib.loc, character.only=TRUE);
  
  loadedpath <- attr(as.environment(paste0("package:", package)), "path");
  if(!identical(normalizePath(lib.loc), normalizePath(dirname(loadedpath)))){
    stop("Package loaded from incorrect library:", loadedpath);
  }
}
