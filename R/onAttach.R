.onAttach <- function(path, package){
	if("rapache" %in% search()){
		#loaded in rapache
    message("OpenCPU server ready...")
	} else {
	  #loaded from within R (e.g. rook)
    message("Initiating opencpu server...")
    
    #start rhttpd
    httpuv$start();    
    rhttpd$init();    
    
    #NOTE: browse() commands are for debugging only
    #in practice, apps should be calling browse()    
    Sys.sleep(0.5)
    rhttpd$browse();
    httpuv$browse();    
    
    if(.Platform$OS.type != "windows"){

    }
	}
}

.onDetach <- function(libpath){
  httpuv$stop();
  message("exiting OpenCPU");
}
