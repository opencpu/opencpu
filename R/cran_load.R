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

  #in cran lib
  inlib(cranpath,{
    cmd <- c(
      paste0("environment(.libPaths)$.lib.loc <- ", deparse(.libPaths(), 500), ";"),
      paste0("options(repos = ", deparse(getOption('repos'), 500), ");"),
      paste0("options(configure.vars = ", deparse(getOption('configure.vars'), 500), ");"),
      paste0("install.packages(", deparse(pkgname), ");")
    );
    
    scriptfile <- tempfile();
    writeLines(cmd, scriptfile);      
    output <- system2("Rscript", shQuote(scriptfile), stdout=TRUE, stderr=TRUE);
  });
    
  #check if package has been installed
  if(!file.exists(pkgpath)){
    stop("Package installation of ", pkgname, " was unsuccessful.\n\n", paste(output, collapse="\n"));
  }

  #return the path 
  return(pkgpath);
}