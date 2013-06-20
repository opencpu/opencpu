packagename = NULL;

.onLoad <- function(path, package){
	packagename <<- package;
	
	options(repos=config('repos'));
	options(keep.source = FALSE);
	options(useFancyQuotes = FALSE);
	options(hasgit = identical(0L, system("git --version")));  
  if(.Platform$OS.type != "windows"){
	  Sys.setlocale(category='LC_ALL', 'en_US.UTF-8');
  }
	
	#apparmor stuff:
	#setInteractive(FALSE);
	#aa_change_profile()
	
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
