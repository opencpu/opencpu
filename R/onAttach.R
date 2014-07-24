.onAttach <- function(lib, pkg){
  #Cloud specific stuff
  if(is_rapache()){
    
    #load opencpu configuration
    loadconfigs(preload=TRUE);     
    
    #try set tempdir() to match config("tempdir"). Must be after loadconfigs!
    inittempdir();
    
    #for the log files
    packageStartupMessage("OpenCPU cloud server ready.");
  
  } else if(interactive() && !("--slave" %in% commandArgs())){
    #This will start XQuartz in OSX
    capabilities();
    
    #Dont run in rscript
    packageStartupMessage("Initiating OpenCPU server...")
    
    #Start HTTPUV
    opencpu$start();
    
    #start rhttpd only in rstudio server
    if(nchar(Sys.getenv("RSTUDIO_HTTP_REFERER"))){
      rhttpd$init();
    }
  
    #Try to stop httpuv if opencpu is still attached when exiting R
    reg.finalizer(globalenv(), function(env){
      #if not attached, then .onDetach already stopped the server
      if("package:opencpu" %in% search()){
        opencpu$stop();
      }
    }, onexit = TRUE);
    
    #on windows the finalizer doesn't always work
    if(identical(.Platform$OS.type, "windows") && !exists(".Last", globalenv())){
      exitfun <- function(){
        if("package:opencpu" %in% search()){
          suppressMessages(opencpu$stop());
          get("cleanwin", asNamespace("opencpu"))();
        }
        rm(".Last", envir=globalenv());
      }
      environment(exitfun) <- globalenv();
      eval(call("assign", ".Last", quote(exitfun), quote(globalenv())));
    }
    
    packageStartupMessage("OpenCPU single-user server ready.");
  }
}

#onDetach for detach
.onDetach <- function(libpath){
  opencpu$stop();
}
