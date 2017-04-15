httpget_github <- function(uri){
  #check if API has been enabled
  check.enabled("api.github");  

  #GET /ocpu/github/jeroen/mypackage
  gituser <- tolower(uri[1]);
  if(is.na(gituser)){
    res$checkmethod()
    pkglist <- sub(sprintf("^%s_", github_prefix), "", list.files(github_rootpath()))
    usernames <- vapply(strsplit(pkglist, "_", fixed = TRUE), utils::head, character(1), n = 1L)
    res$sendlist(usernames)
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
  res$setcache("git")
  httpget_package(pkgpath, reqtail)
}
