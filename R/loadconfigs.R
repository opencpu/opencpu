loadconfigs <- local({
  #only do this once per package load
  opencpu_is_initiated = FALSE;
  
  #actual function
  function(preload = FALSE){
    if(isTRUE(opencpu_is_initiated)){
      return();
    } else {
      opencpu_is_initiated <<- TRUE;
    }
    
    #load default package config file
    defaultconf <- system.file("config/defaults.conf", package=packagename);
    stopifnot(file.exists(defaultconf));
    environment(config)$load(defaultconf);
    
    #override with system config file
    if(isTRUE(getOption("rapache"))){
      #for cloud server
      if(file.exists("/etc/opencpu/server.conf")){
        environment(config)$load("/etc/opencpu/server.conf");    
      }
      
      #override with custom system config files
      if(isTRUE(file.info("/etc/opencpu/server.conf.d")$isdir)){
        conffiles <- list.files("/etc/opencpu/server.conf.d", full.names=TRUE, pattern=".conf$");
        lapply(as.list(conffiles), environment(config)$load);
      }
    } else {
      #single user server
      configfile <- path.expand("~/.opencpu.conf");
      message("Loading config from ", configfile)
      if(file.exists(configfile)){
        environment(config)$load(configfile);
      }
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
    if(!identical(getOption("bitmapType"), "cairo") && isTRUE(capabilities()[["cairo"]])){
      options(bitmapType = "cairo");
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
});
