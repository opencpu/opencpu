httpget_github <- function(uri){
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
    res$sendlist(ocpu_installed_apps())
  }

  gitrepo <- uri[2];
  if(is.na(gitrepo)){
    res$checkmethod()
    pattern <- sprintf("^ocpu_github_%s_", gituser)
    pkglist <- list.files(github_rootpath(), pattern = pattern)
    res$sendlist(sub(pattern, "", pkglist))
  }

  libpath <- github_userlib(gituser, gitrepo)
  pkgpath <- file.path(libpath, gitrepo)
  if(!file.exists(pkgpath))
    res$error(sprintf("Github package %s/%s not installed on this server", gituser, gitrepo), 404)
  reqtail <- utils::tail(uri, -2)

  #set cache value
  res$setcache("apps")
  httpget_package(pkgpath, reqtail)
}
