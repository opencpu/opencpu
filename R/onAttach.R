.onAttach <- function(path, package){
	if("rapache" %in% search()){
		#loaded in rapache
    message("OpenCPU server ready...")
	} else {
	  #loaded from within R (e.g. rook)
    message("Initiating opencpu server...")
    
    #NOTE: browse() commands are for debugging only
    #in practice, apps should be calling browse()    
    
    #start rhttpd
    rhttpd$init();
    rhttpd$browse();
    
    if(.Platform$OS.type != "windows"){
      #start httpuv
		  httpuv$start();
      httpuv$browse();
    }
	}
}

.onDetach <- function(libpath){
  httpuv$stop();
  message("existing OpenCPU")
}
