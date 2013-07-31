packagename = "";

.onLoad <- function(lib, pkg){
  packagename <<- pkg;
  
  #Makes sure methods is loaded, which should always be the case
  #This is needed for R CMD CHECK only... looks like a bug?
  #See Uwe @ https://stat.ethz.ch/pipermail/r-devel/2011-October/062261.html
  eval(call("require", "methods", quietly=TRUE))
  
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
  options(max.print=50);
  options(device=grDevices::pdf);
  options(menu.graphics=FALSE);
  options(repos=config('repos'));
  options(keep.source = FALSE);
  options(useFancyQuotes = FALSE);
  
  #check for software
  #options(hasgit = cmd_exists("git --version")); 
  #options(haspandoc = cmd_exists("pandoc --version"));  
  #options(hastex = cmd_exists("texi2dvi --version"));
  
  #create tmp directories
  stopifnot(file.exists(gettmpdir()));
  
  if(.Platform$OS.type != "windows"){
    Sys.setlocale(category='LC_ALL', 'en_US.UTF-8');
  }
  
  #preload libraries
  for(thispackage in config("preload")){
    #try to preload the packages. Make sure to complain about non existing packages.
    try(getNamespace(thispackage), silent=FALSE);
  }
}
