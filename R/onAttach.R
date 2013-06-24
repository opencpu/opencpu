.onAttach <- function(path, package){
  #httpuv should not be started in rapache or during R CMD INSTALL --test-load
  if(interactive() && !("rapache" %in% search()) && !("--slave" %in% commandArgs())) {  
    #loaded from within R
    message("Initiating OpenCPU server...")
    
    #start rhttpd
    httpuv$start();    
    rhttpd$init();    
    
    #NOTE: browse() commands are for debugging only
    #in practice, apps should be calling browse()    
    Sys.sleep(0.5)
    rhttpd$browse();
    httpuv$browse();    
  }
  message("OpenCPU server ready.");
}

.onDetach <- function(libpath){
  httpuv$stop();
  message("exiting OpenCPU");
}
