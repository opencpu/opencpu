github_load <- function(gituser, gitrepo){
  githublib <- file.path(gettmpdir(), "github_library");
  if(!file.exists(githublib)){
    stopifnot(dir.create(githublib, recursive=TRUE));
  }  
  
  gitpath <- file.path(githublib, paste("ocpu_github", gituser, gitrepo, sep="_"));
  blockpath <- paste0(gitpath, "_block");

  pkgpath <- file.path(gitpath, gitrepo);
  maxage <- config("github.cache");
  
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
  unlink(gitpath, recursive=TRUE, force=TRUE);    
    
  #setup a blocker (for concurrent requests to the same gist)
  stopifnot(file.create(blockpath));
  on.exit(unlink(blockpath, force=TRUE));

  #install the app from github 
  gittmpdir <- tempfile("githubdir");
  stopifnot(dir.create(gittmpdir));

  #NOTE: for now we can't capture output from install_github
  #Dependencies = TRUE otherwise it will skip currently loaded packages leading to problems.
  inlib(gittmpdir, {
    output <- try_rscript(paste0("library(methods);library(devtools);install_github(", deparse(gitrepo), ",", deparse(gituser), ", dependencies=TRUE, quick=TRUE, args='--library=", deparse(gittmpdir), "')"));
  });
  
  #check if package has been installed
  if(!file.exists(file.path(gittmpdir, gitrepo))){
    #note that stop() might not work because error message is too large (install log)
    header <- paste("Package'",gitrepo,"' did not successfully install.\nEither installation failed or github repository name does not match package name.\n\n");
    msg <- paste(output, collapse="\n");
    res$error(paste(header, msg, sep="\n"));
  }

  #move everything to new location
  stopifnot(dir.move(gittmpdir, gitpath));
  file.remove(blockpath);
  
  #return the path 
  return(pkgpath);
}