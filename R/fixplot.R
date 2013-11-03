fixplot <- function(plot, loadpackages=FALSE){
  
  if(isTRUE(loadpackages)){
    # packages need to be loaded for some reason
    try(getNamespace("lattice"), silent=TRUE);
    try(getNamespace("ggplot2"), silent=TRUE);  
  }
  
  # restore native symbols for R >= 3.0
  rVersion <- getRversion()
  if (rVersion >= "3.0") {
    attr(plot, "pid") <- Sys.getpid();    
    for(i in 1:length(plot[[1]])) {
      # get the symbol then test if it's a native symbol
      symbol <- plot[[1]][[i]][[2]][[1]]
      if(is(symbol, "NativeSymbolInfo")) {
        # determine the dll that the symbol lives in
        name <- ifelse(is.null(symbol$package), symbol$dll[["name"]], symbol$package[["name"]]);
        pkgDLL <- getLoadedDLLs()[[name]];
        
        # reconstruct the native symbol and assign it into the plot
        plot[[1]][[i]][[2]][[1]] <- getNativeSymbolInfo(name = symbol$name, PACKAGE = pkgDLL, withRegistrationInfo = TRUE);
      }
    }
  }
  # restore native symbols for R >= 2.14
  else if (rVersion >= "2.14") {
    try({
      for(i in 1:length(plot[[1]])) {
        symbol <- plot[[1]][[i]][[2]][[1]];
        if(is(symbol, "NativeSymbolInfo")) {
          plot[[1]][[i]][[2]][[1]] <- getNativeSymbolInfo(plot[[1]][[i]][[2]][[1]]$name); 
        }
      }
    }, silent = TRUE);
  }
  
  #return
  return(plot)
}   
