.onAttach <- function(lib, pkg){
  #Cloud specific stuff
  if(isTRUE(getOption("rapache"))){
    
    #try set tempdir() to match config("tempdir")
    inittempdir();
    
    #default locale in apache is "C"
    Sys.setlocale(category='LC_ALL', 'en_US.UTF-8');
    
    #load opencpu configuration
    loadconfigs(preload=TRUE); 
  
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
