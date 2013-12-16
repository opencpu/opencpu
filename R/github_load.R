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
    
  #wipe old stuff
  unlink(gitpath, recursive=TRUE, force=TRUE);
    
  #setup a blocker (for concurrent requests to the same gist)
  stopifnot(file.create(blockpath));
  on.exit(unlink(blockpath, force=TRUE));

  #install package
  result <- github_install(gitrepo, gituser);
  file.remove(blockpath);
  
  #check if package has been installed
  if(!isTRUE(result$success)){
    #note that stop() might not work because error message is too large (install log)
    header <- paste("Package'",gitrepo,"' did not successfully install.\nEither installation failed or github repository name does not match package name.\n\n");
    msg <- paste(result$output, collapse="\n");
    res$error(paste(header, msg, sep="\n"));
  }
  
  #return the path 
  return(pkgpath);
}