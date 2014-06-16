github_install <- function(gitrepo, gituser, gitbranch = "master"){  
  #github libraries
  githublib <- file.path(gettmpdir(), "github_library");  
  gitpath <- file.path(githublib, paste("ocpu_github", gituser, gitrepo, sep="_"));
  
  #install from github 
  gittmpdir <- tempfile("githubdir");
  stopifnot(dir.create(gittmpdir));
  
  #For private repos
  mysecret <- gitsecret();
  if(length(mysecret) && length(mysecret$auth_token) &&
     any(nchar(mysecret$auth_token))){
      if(length(mysecret$auth_token) == 1) {
          ## one auth_token provided, assume it is for the given
          ## gitrepo
          auth <- paste0(", auth_token=", deparse(mysecret$auth_token))
      } else if(length(mysecret$auth_token[[gituser]])) {
          ## multiple pats are available, choose the one for this gitrepo 
          ## name
          auth <- paste0(", auth_token=", deparse(mysecret$auth_token[[gituser]]))
      } else {
          ## multiple pats are available, but none with name of this repo
          auth <- "";
      }
  } else {
      auth <- "";
  }
  
  #Dependencies = TRUE would also install currently loaded packages.
  inlib(gittmpdir, {
    output <- try_rscript(paste0("library(methods);suppressPackageStartupMessages(library(devtools));install_github(", deparse(gitrepo), ",", deparse(gituser), ",", deparse(gitbranch), auth, ", quick=TRUE, args='--library=", deparse(gittmpdir), "')"));
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
