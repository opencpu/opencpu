github_install <- function(repo, username, ref = "master", args = NULL, ...){
  #get args
  all_args <- list(...)
  all_args$repo <- repo;
  all_args$username <- username;
  all_args$ref <- ref;

  #github libraries
  githublib <- file.path(gettmpdir(), "github_library");
  gitpath <- file.path(githublib, paste("ocpu_github", username, repo, sep="_"));

  #install from github
  gittmpdir <- tempfile("githubdir");
  stopifnot(dir.create(gittmpdir));
  all_args$args <- paste0("'--library=", deparse(gittmpdir), "'")

  #Override auth_token if set in key
  mysecret <- gitsecret();
  if(length(mysecret) && length(mysecret$auth_token) && nchar(mysecret$auth_token)){
    all_args$auth_token = mysecret$auth_token;
  }

  #Dependencies = TRUE would also install currently loaded packages.
  inlib(gittmpdir, {
    output <- try_rscript(paste0("library(methods); library(devtools); do.call(install_github,", deparse(all_args), ");"));
  });

  #We require package name with identical repo name
  success <- isTRUE(file.exists(file.path(gittmpdir, repo)));

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
