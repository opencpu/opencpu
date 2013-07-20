cran_load <- function(pkgname){
  cranpath <- file.path(gettmpdir(), "cran_library");
  if(!file.exists(cranpath)){
    stopifnot(dir.create(cranpath));
  }
  
  pkgpath <- file.path(cranpath, pkgname);
  blockpath <- paste(pkgpath, "block", sep="_")
  maxage <- config("cran.cache");
  
  #is there is a blocker but its old, we remove it. This should not happen.
  if(isTRUE(difftime(Sys.time(), file.info(blockpath)$mtime, units="secs") > config("timelimit.get")+5)){
    stopifnot(file.remove(blockpath, recursive=TRUE, force=TRUE));    
  }
  
  #wait for the block to disappear
  while(file.exists(blockpath)){
    Sys.sleep(1);
  }
  
  #see if it exists and if it is fresh enough
  if(file.exists(pkgpath)){
    dirage <- difftime(Sys.time(), file.info(pkgpath)$mtime, units="secs");
    if(dirage < maxage){
      return(pkgpath);      
    } 
  } 
    
  #make sure its gone
  unlink(pkgpath, recursive=TRUE, force=TRUE);    
    
  #setup a blocker (for concurrent requests to the same gist)
  stopifnot(file.create(blockpath));
  on.exit(unlink(blockpath, force=TRUE));

  #NOTE: for now we can't capture output from install.packages
  inlib(cranpath,
    tryCatch(install.packages(pkgname), error=function(e){
      stop("Package installation of ", pkgname, " failed: ", e$message);
    })
  );
  
  #check if package has been installed
  if(!file.exists(pkgpath)){
    stop("Package installation of ", pkgname, " was unsuccessful.");
  }

  #return the path 
  return(pkgpath);
}