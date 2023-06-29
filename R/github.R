github_prefix <- "ocpu_github"

getlocaldir <- function(which = 'data'){
  if(is_rapache() || is_admin()){
    return("/usr/local/lib/opencpu")
  } else if(getRversion() < "4"){
    rappdirs::user_data_dir('opencpu')
  } else {
    tools::R_user_dir('opencpu', which)
  }
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

github_package_info <- function(repo, token = NULL){
  tryCatch({
  url <- sprintf("https://raw.githubusercontent.com/%s/HEAD/DESCRIPTION", repo)
  handle <- curl::new_handle()
  if(length(token)){
    curl::handle_setheaders(handle, Authorization = paste("token", token))
  }
  con <- curl::curl(url, handle = handle)
  on.exit(close(con))
  out <- as.list(as.data.frame(read.dcf(con), stringsAsFactors = FALSE))
  }, error = function(e){
    stop(sprintf("Failed to read %s. Repsitory does not contain a proper R package.", url))
  })
  stats::setNames(out, tolower(names(out)))
}

github_install <- function(repo, username, ref, args = NULL, upgrade = FALSE, auth_token = github_token(), ...){
  #get args
  all_args <- list(...)
  all_args$upgrade <- upgrade
  all_args$auth_token <- auth_token
  all_args$repo <- url_path(username, repo)
  all_args$ref <- ref

  # final app location
  gitpath <- github_userlib(username, repo)

  # temporary location
  gittmpdir <- paste0(gitpath, "_00TMP")
  if(file.exists(gittmpdir)){
    info <- file.info(gittmpdir)
    time_limit <- config("timelimit.webhook")
    if(difftime(Sys.time(), info$mtime, units = 'sec') > time_limit){
      unlink(gittmpdir, recursive = TRUE)
    } else {
      stop("Package is already being installed: ", gittmpdir)
    }
  }
  stopifnot(dir.create(gittmpdir))
  on.exit(unlink(gittmpdir, recursive = TRUE))

  # Sets 'chmod g+xs' to make writable for other users in the group
  Sys.chmod(gittmpdir, "2755")
  all_args$lib <- gittmpdir
  all_args$force <- TRUE

  # Download metadata before actually installing. Errors if no DESCRIPTION exists.
  # TODO: get this info from 'output' above
  app_info <- github_package_info(all_args$repo, auth_token)
  package <- app_info$package

  # Create the Rscript call
  arg_list <- paste(deparse(all_args), collapse="\n")
  output <- run_rscript(sprintf("do.call(opencpu:::install_apps_one, %s)", arg_list))

  #We require package name with identical repo name
  success <- isTRUE(file.exists(file.path(gittmpdir, package)))

  #The index.html for vignettes is useless due to hardcoded hyperlinks
  unlink(file.path(gittmpdir, package, "doc", "index.html"))

  #move to permanent location
  if(success){
    unlink(gitpath, recursive = TRUE)
    stopifnot(file.rename(gittmpdir, gitpath))
  }

  #return success and output
  list(
    success = success,
    output = output,
    gitpath = gitpath,
    package = package
  )
}
