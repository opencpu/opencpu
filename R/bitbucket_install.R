bitbucket_install <- function(repo, username, ref = "master", args = NULL, ...){
  #get args
  all_args <- list(...)
  all_args$repo <- paste(username, repo, sep="/");
  all_args$ref <- ref;

  #bitbucket libraries
  bitbucketlib <- file.path(gettmpdir(), "bitbucket_library");
  gitpath <- file.path(bitbucketlib, paste("ocpu_bitbucket", username, repo, sep="_"));

  #install from bitbucket
  gittmpdir <- tempfile("bitbucketdir");
  stopifnot(dir.create(gittmpdir));
  #all_args$args <- paste0("'--library=", gittmpdir, "'")

  #override bitbucket_auth_token if set in key
  mysecret <- gitsecret();
  if(length(mysecret) && length(mysecret$bitbucket_password) && nchar(mysecret$bitbucket_password)){
    all_args$password = mysecret$bitbucket_password;
  }
  if(length(mysecret) && length(mysecret$bitbucket_username) && nchar(mysecret$bitbucket_username)){
    all_args$auth_user = mysecret$bitbucket_username;
  }

  #Dependencies = TRUE would also install currently loaded packages.
  inlib(gittmpdir, {
        arg_list <- paste(deparse(all_args), collapse="\n")
        output <- try_rscript(paste0("library(methods); library(devtools); do.call(install_bitbucket,", arg_list, ");"));
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
