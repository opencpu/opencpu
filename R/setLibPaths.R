setLibPaths <- local({
  checkfordir <- function(path){
    return(isTRUE(file.info(path)$isdir));
  }

  #because .libPaths() only appends paths, doesn't replace anything.
  function(newlibs, baselib=TRUE){
    if(baselib){
      baselibpath <- file.path(Sys.getenv("R_HOME"), "library");
      newlibs <- unique(c(newlibs, baselibpath));
    }
    newlibs <- newlibs[sapply(newlibs, checkfordir)]
    assign(".lib.loc", newlibs, envir=environment(.libPaths));
  }
})