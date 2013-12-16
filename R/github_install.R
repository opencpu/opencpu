github_install <- function(gitrepo, gituser, gitbranch = "master"){  
  #github libraries
  githublib <- file.path(gettmpdir(), "github_library");  
  gitpath <- file.path(githublib, paste("ocpu_github", gituser, gitrepo, sep="_"));
  
  #install from github 
  gittmpdir <- tempfile("githubdir");
  stopifnot(dir.create(gittmpdir));
  
  #NOTE: for now we can't capture output from install_github
  #Dependencies = TRUE otherwise it will skip currently loaded packages leading to problems.
  inlib(gittmpdir, {
    output <- try_rscript(paste0("library(methods);library(devtools);install_github(", deparse(gitrepo), ",", deparse(gituser), ",", deparse(gitbranch), ", quick=TRUE, args='--library=", deparse(gittmpdir), "')"));
  });  
  
  #We require package name with identical repo name
  success <- isTRUE(file.exists(file.path(gittmpdir, gitrepo)));
  
  #move everything to new location
  if(success){
    unlink(gitpath, recursive=TRUE);
    stopifnot(dir.move(gittmpdir, gitpath));
  }  
  
  #return success and output
  list(
    success = success,
    output = output,
    gitpath = gitpath
  );
}