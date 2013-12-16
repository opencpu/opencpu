loadPackageFrom <- function(package, lib.loc, force = TRUE){
  stopifnot(is.character(package));
  library(package, lib.loc=lib.loc, character.only=TRUE);
  
  #force double checks if the package was loaded form the correct library
  #this is needed when the package was alread loaded from another library before the request
  if(isTRUE(force)){
    name <- paste0("package:", package);
    loadedpath <- attr(as.environment(name), "path");
    if(!is.null(loadedpath) && !identical(normalizePath(lib.loc), normalizePath(dirname(loadedpath)))){
      detach(name, unload=TRUE, character.only=TRUE, force=TRUE);
      library(package, lib.loc=lib.loc, character.only=TRUE);
    }
  }
}
