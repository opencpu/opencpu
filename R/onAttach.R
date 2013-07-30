.onAttach <- function(lib, pkg){
  #Cloud specific stuff
  if(isTRUE(getOption("rapache"))){
    
    #try set tempdir() to match config("tempdir")
    inittempdir();
    
    #remove custom system lib
    .libPaths(c(.Library.site, .Library));
  
  } else if(interactive() && !("--slave" %in% commandArgs())){
    #Dont run in rscript
    packageStartupMessage("Initiating OpenCPU server...")
    
    #start rhttpd only in rstudio server
    if(nchar(Sys.getenv("RSTUDIO_HTTP_REFERER"))){
      rhttpd$init();        
    }
    
    #Start HTTPUV
    httpuv$start();
  
    #Make sure httpuv stops when exiting R.
    if(!exists(".Last", globalenv())){
      exitfun <- function(){
        try({
          opencpu:::httpuv$stop();
          rm(".Last", envir=globalenv());
        }, silent=TRUE);
      } 
  
      environment(exitfun) <- globalenv();
      eval(call("assign", ".Last", quote(exitfun), quote(globalenv())));
    }
    
    packageStartupMessage("OpenCPU single-user server ready.");
  }
}

.onDetach <- function(libpath){
  httpuv$stop();
  message("Exiting OpenCPU");
}
