github_prefix <- "ocpu_github"

getlocaldir <- function(){
  if(is_rapache() || is_admin()){
    return("/usr/local/lib/opencpu")
  }
  rappdirs::user_data_dir("opencpu")
}

github_rootpath <- function(){
  githublib <- file.path(getlocaldir(), "apps")
  if(!file.exists(githublib))
    stopifnot(dir.create(githublib, recursive = TRUE))
  return(githublib)
}

github_userlib <- function(gituser, gitrepo){
  file.path(github_rootpath(), paste(github_prefix, gituser, gitrepo, sep="_"))
}

github_package_info <- function(repo){
  tryCatch({
  url <- sprintf("https://raw.githubusercontent.com/%s/master/DESCRIPTION", repo)
  con <- curl::curl(url)
  on.exit(close(con))
  out <- as.list(as.data.frame(read.dcf(con), stringsAsFactors = FALSE))
  }, error = function(e){
    stop(sprintf("Failed to read %s. Repsitory does not contain a proper R package.", url))
  })
  stats::setNames(out, tolower(names(out)))
}

github_install <- function(repo, username, ref, args = NULL, upgrade_dependencies = FALSE, ...){
  #get args
  all_args <- list(...)
  all_args$upgrade_dependencies <- upgrade_dependencies
  all_args$repo <- url_path(username, repo)
  all_args$ref <- ref

  # Sets 'chmod g+xs' to make writable for other users in the group
  gittmpdir <- tempfile("githubdir")
  stopifnot(dir.create(gittmpdir))
  Sys.chmod(gittmpdir, "2755")
  all_args$lib <- gittmpdir
  all_args$force <- TRUE

  # Download metadata before actually installing. Errors if no DESCRIPTION exists.
  # TODO: get this info from 'output' above
  app_info <- github_package_info(all_args$repo)
  package <- app_info$package

  #Override auth_token if set in key
  mysecret <- gitsecret()
  if(length(mysecret) && length(mysecret$auth_token) && nchar(mysecret$auth_token)){
    all_args$auth_token = mysecret$auth_token
  }

  # Create the Rscript call
  arg_list <- paste(deparse(all_args), collapse="\n")
  output <- run_rscript(sprintf("do.call(opencpu:::install_apps_one, %s)", arg_list))

  #We require package name with identical repo name
  success <- isTRUE(file.exists(file.path(gittmpdir, package)))

  #The index.html for vignettes is useless due to hardcoded hyperlinks
  unlink(file.path(gittmpdir, package, "doc", "index.html"))

  # final app location
  gitpath <- github_userlib(username, repo)

  #move to permanent location
  if(success){
    unlink(gitpath, recursive = TRUE)
    stopifnot(dir.move(gittmpdir, gitpath))
  }

  #return success and output
  list(
    success = success,
    output = output,
    gitpath = gitpath,
    package = package
  )
}
