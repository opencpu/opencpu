httpget_apps <- function(uri){
  #check if API has been enabled
  check.enabled("api.apps");

  #legacy redirect
  if(identical(req$method(), "GET") && grepl("^/github", req$path_info())){
    args <- req$getvalue("GET")
    str <- if(length(args)){
      paste0("?", deparse_query(args))
    }
    new_url <- paste0(req$fullmount(), sub("^/github", "/apps", req$path_info()), str)
    res$redirect(new_url, txt = "The /ocpu/github/ API has been renamed to /ocpu/apps/")
  }

  #GET /ocpu/github/jeroen/mypackage
  gituser <- tolower(uri[1]);
  if(is.na(gituser)){
    res$checkmethod()
    res$sendlist(installed_apps())
  }

  gitrepo <- uri[2];
  if(is.na(gitrepo)){
    res$checkmethod()
    pattern <- sprintf("^ocpu_github_%s_", gituser)
    pkglist <- list.files(github_rootpath(), pattern = pattern)
    res$sendlist(sub(pattern, "", pkglist))
  }

  #check if app is installed
  app_info <- ocpu_app_info(url_path(gituser, gitrepo))
  if(!isTRUE(app_info$installed))
    res$error(sprintf("Github App %s/%s not installed on this server", gituser, gitrepo), 404)

  # For packages with different pkg name than repo name
  libpath <- app_info$path
  package <- app_info$package

  # Name of package inside library
  pkgpath <- file.path(libpath, package)
  if(!file.exists(pkgpath))
    res$error(sprintf("Github package %s not foud in app library %s/%s.", package, gituser, gitrepo), 404)
  reqtail <- utils::tail(uri, -2)

  #set cache value
  res$setcache("apps")
  httpget_package(pkgpath, reqtail)
}
