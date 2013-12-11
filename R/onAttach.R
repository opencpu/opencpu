.onAttach <- function(lib, pkg){
  #Cloud specific stuff
  if(isTRUE(getOption("rapache"))){
    
    #try set tempdir() to match config("tempdir")
    inittempdir();
    
    #move opencpu system lib to the end of the search lib
    #note: removing a lib from which packages are already loaded results in weird behavior.
    #.libPaths(c(.Library.site, .Library, "/usr/lib/opencpu/library"));
    #note undo this because of version conflicts with packages installed in global library
  
  } else if(interactive() && !("--slave" %in% commandArgs())){
    #Dont run in rscript
    packageStartupMessage("Initiating OpenCPU server...")
    
    #start rhttpd only in rstudio server
    if(nchar(Sys.getenv("RSTUDIO_HTTP_REFERER"))){
      rhttpd$init();
    }
    
    #Start HTTPUV
    opencpu$start();
  
    #Try to stop httpuv if opencpu is still attached when exiting R
    reg.finalizer(globalenv(), function(env){
      try({
        #if not attached, then .onDetach already stopped the server
        if("package:opencpu" %in% search()){
          opencpu$stop();
          cleanwin();
        }
      }, silent = TRUE)
    }, onexit = TRUE);
    
    packageStartupMessage("OpenCPU single-user server ready.");
  }
}

#onDetach for detach
.onDetach <- function(libpath){
  opencpu$stop();
  message("Stopping OpenCPU");
}
