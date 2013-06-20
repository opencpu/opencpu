httpget_github <- function(uri){

  #GET /ocpu/github/jeroen/mypackage
  gituser <- uri[1];
  gitrepo <- uri[2];
  if(is.na(gituser) || is.na(gitrepo)){
    res$checkmethod();    
    stop("Please specify a github username and repository, e.g. /ocpu/github/jerry/jjplot2/")
  }
  
  #init the gist
  pkgpath <- github_load(gituser, gitrepo);
  
  #remaining of the api
  reqtail <- tail(uri, -2)  
  
  #serve basic files
  httpget_package(pkgpath, reqtail);
}