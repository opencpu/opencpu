.onAttach <- function(path, package){
  #Cloud specific stuff
  if("rapache" %in% search()){
    
    #remove custom system lib
    .libPaths(c(.Library.site, .Library));
  
    #Check for RAppArmor when using Apache    
    if(!isTRUE(getOption("hasrapparmor"))){
      warning("SECURITY WARNING: OpenCPU is running without RAppArmor.");
    }
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
    
    message("OpenCPU server ready.");
  }
}

.onDetach <- function(libpath){
  httpuv$stop();
  message("exiting OpenCPU");
}


