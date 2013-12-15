loadconfigs <- function(preload = FALSE){
  #only do this once per process
  if(isTRUE(getOption("opencpu.configs"))){
    return();
  } else {
    options(opencpu.configs = TRUE);
  }
  
  #load default package config file
  defaultconf <- system.file("config/defaults.conf", package=packagename);
  stopifnot(file.exists(defaultconf));
  environment(config)$load(defaultconf);
  
  #override with system config file
  if(file.exists("/etc/opencpu/server.conf")){
    environment(config)$load("/etc/opencpu/server.conf");    
  }
  
  #override with custom system config files
  if(isTRUE(file.info("/etc/opencpu/server.conf.d")$isdir)){
    conffiles <- list.files("/etc/opencpu/server.conf.d", full.names=TRUE, pattern=".conf$");
    lapply(as.list(conffiles), environment(config)$load);
  }
  
  #set some global options
  options(max.print=1000);
  options(device=grDevices::pdf);
  options(menu.graphics=FALSE);
  options(repos=config('repos'));
  options(keep.source = FALSE);
  options(useFancyQuotes = FALSE);
  options(warning.length=8000);
  options(scipen=3);
  
  #use cairo if available
  if(isTRUE(capabilities()[["cairo"]])){
    options(bitmapType = 'cairo');
  } 
  
  #create tmp directories
  stopifnot(file.exists(gettmpdir()));
  
  if(isTRUE(preload)){
    #preload libraries
    for(thispackage in config("preload")){
      try(getNamespace(thispackage), silent=TRUE);
    }
  }  
}