packagename = NULL;

.onLoad <- function(path, package){
  packagename <<- package;
  
  options(repos=config('repos'));
  options(keep.source = FALSE);
  options(useFancyQuotes = FALSE);
  options(hasgit = cmd_exists("git --version")); 
  options(haspandoc = cmd_exists("pandoc --version"));  
  options(hastex = cmd_exists("texi2dvi --version"));
  options(hasrapparmor = suppressWarnings(require("RAppArmor", quietly=TRUE)));
  
  if(.Platform$OS.type != "windows"){
    Sys.setlocale(category='LC_ALL', 'en_US.UTF-8');
  }
  
  #add non-system opencpu libraries
  if(length(config("libpaths")) > 0){
    setLibPaths(unlist(config("libpaths")));
  }
  
  #preload libraries
  for(thispackage in config("preload")){
    #try to preload the packages. Make sure to complain about non existing packages.
    try(getNamespace(thispackage), silent=FALSE);
  }
}
