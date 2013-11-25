httpget_CI <- function(){
  args <- req$post();
  payload <- args$payload;
  if(is.null(payload)){
    stop("No argument 'payload' posted.")
  }
  
  #extract some fields
  email <- payload$repository$owner$email;
  
  #get started
  gituser <- payload$repository$owner$name;
  gitrepo <- payload$repository$name;
  gitbranch <- payload$repository$master_branch;
  githublib <- file.path(gettmpdir(), "github_library");  
  gitpath <- file.path(githublib, paste("ocpu_github", gituser, gitrepo, sep="_"));
  
  #install from github 
  gittmpdir <- tempfile("githubdir");
  stopifnot(dir.create(gittmpdir));
  
  #NOTE: for now we can't capture output from install_github
  #Dependencies = TRUE otherwise it will skip currently loaded packages leading to problems.
  inlib(gittmpdir, {
    output <- try_rscript(paste0("library(methods);library(devtools);install_github(", deparse(gitrepo), ",", deparse(gituser), ",", deparse(gitbranch), ", dependencies=TRUE, quick=TRUE, args='--library=", deparse(gittmpdir), "')"));
  });  
  
  #check if package has been installed
  if(!file.exists(file.path(gittmpdir, gitrepo))){
    stop("Package '",gitrepo, "' did not successfully install.\nEither installation failed or github repository name does not match package name.\n\n", paste(output, collapse="\n"))
  }
  
  #move everything to new location
  unlink(gitpath, recursive=TRUE)
  stopifnot(dir.move(gittmpdir, gitpath));
}