.onAttach <- function(lib, pkg){
  if(is_rapache()){

    #for the log files
    packageStartupMessage("OpenCPU cloud server ready.")

  } else {

    #This will start XQuartz in OSX
    capabilities()

    #Dont run in rscript
    packageStartupMessage("Welcome to OpenCPU!")

    #start rhttpd only in rstudio server
    if(nchar(Sys.getenv("RSTUDIO_HTTP_REFERER"))){
      rhttpd$init()
    }
  }
}
