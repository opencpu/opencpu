.onAttach <- function(path, package){
  #httpuv should not be started in rapache or during R CMD INSTALL --test-load
  if(interactive() && !("rapache" %in% search()) && !("--slave" %in% commandArgs())) {  
    #loaded from within R
    message("Initiating OpenCPU server...")
    
    #start rhttpd only in rstudio server
    if(nchar(Sys.getenv("RSTUDIO_HTTP_REFERER"))){
      rhttpd$init();        
    }

    #Start HTTPUV
    httpuv$start();
    #Sys.sleep(1);
    #httpuv$browse();  
    
    #NOTE: browse() commands are for debugging only
    #in practice, apps should be calling browse()   
  } 
  
  #Check for RAppArmor when using Apache
  if("rapache" %in% search() && !isTRUE(getOption("hasrapparmor"))){
    warning("SECURITY WARNING: OpenCPU is running without RAppArmor.");
  }
  
  #Make sure httpuv stops when exiting R.
  if(!exists(".Last", globalenv())){
    .Last <<- function(){
      try(httpuv$stop(), silent=TRUE);
    } 
  }
  
  message("OpenCPU server ready.");
}

.onDetach <- function(libpath){
  httpuv$stop();
  message("exiting OpenCPU");
}
