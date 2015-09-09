github_install <- function(repo, username, ref = "master", args = NULL, upgrade_dependencies = FALSE, ...){
  #get args
  all_args <- list(...)
  all_args$upgrade_dependencies <- upgrade_dependencies;
  all_args$repo <- paste(username, repo, sep="/");
  all_args$ref <- ref;

  #github libraries
  githublib <- file.path(gettmpdir(), "github_library");
  gitpath <- file.path(githublib, paste("ocpu_github", username, repo, sep="_"));

  #install from github
  gittmpdir <- tempfile("githubdir");
  stopifnot(dir.create(gittmpdir));
  #all_args$args <- paste0("'--library=", gittmpdir, "'")

  #Override auth_token if set in key
  mysecret <- gitsecret();
  if(length(mysecret) && length(mysecret$auth_token) && nchar(mysecret$auth_token)){
    all_args$auth_token = mysecret$auth_token;
  }

  #Dependencies = TRUE would also install currently loaded packages.
  inlib(gittmpdir, {
    arg_list <- paste(deparse(all_args), collapse="\n")
    output <- try_rscript(paste0("library(methods); library(devtools); do.call(install_github,", arg_list, ");"));
  });

  #We require package name with identical repo name
  success <- isTRUE(file.exists(file.path(gittmpdir, repo)));

  #The index.html for vignettes is useless due to hardcoded hyperlinks
  unlink(file.path(gittmpdir, repo, "doc", "index.html"));

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
