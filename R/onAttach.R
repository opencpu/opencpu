.onAttach <- function(path, package){
  #Cloud specific stuff
  if(isTRUE(getOption("rapache"))){
    
    #try set tempdir() to match config("tempdir")
    inittempdir();
    
    #remove custom system lib
    .libPaths(c(.Library.site, .Library));
  
  } else {
    #Dont run in rscript
    if(!interactive() || ("--slave" %in% commandArgs())){
      return();
    }
    
    #loaded from within R
    message("Initiating OpenCPU server...")
    
    #start rhttpd only in rstudio server
    if(nchar(Sys.getenv("RSTUDIO_HTTP_REFERER"))){
      rhttpd$init();        
    }
    
    #Start HTTPUV
    httpuv$start();
    Sys.sleep(1);
    httpuv$browse();  
    
  
    #Make sure httpuv stops when exiting R.
    if(!exists(".Last", globalenv())){
      exitfun <- function(){
        try({
          ocpu:::httpuv$stop();
          rm(".Last", envir=globalenv());
        }, silent=TRUE);
      } 
  
      environment(exitfun) <- globalenv();
      assign(".Last", exitfun, globalenv());
    }
    
    message("OpenCPU development server ready.");
  }
}

.onDetach <- function(libpath){
  httpuv$stop();
  message("Exiting OpenCPU");
}


