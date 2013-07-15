github_load <- function(gituser, gitrepo){
  gitpath <- file.path(gettmpdir(), paste("ocpu_github", gituser, gitrepo, sep="_"));
  pkgpath <- file.path(gitpath, gitrepo);
  blockpath <-file.path(gettmpdir(), paste("ocpu_github", gituser, gitrepo, "block", sep="_"));
  maxage <- config("github.cache");
  
  #is there is a blocker but its old, we remove it. This should not happen.
  if(isTRUE(difftime(Sys.time(), file.info(blockpath)$mtime, units="secs") > 120)){
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

  #NOTE: use the forked jeroenooms/devtools to capture stdout
  outfile <- tempfile();
  tryCatch(eval_safe(devtools::install_github(stdout=outfile, stderr=outfile, gitrepo, gituser, args=paste("--library=", deparse(gittmpdir), sep="")), timeout=config("time.limit")-5), error=function(e){
    myerr <- paste("devtools::install_github failed: ", e$message);
    if(file.exists(outfile)){
      myerr <- paste(myerr, readLines(outfile), sep="\n", collapse="\n");
    };
    stop(myerr)
  });
  
  #check if package has been installed
  if(!file.exists(file.path(gittmpdir, gitrepo))){
    stop("Package installation failed.")
  }

  #move everything to new location
  stopifnot(file.rename(gittmpdir, gitpath));
  file.remove(blockpath);
  
  #return the path 
  return(pkgpath);
}