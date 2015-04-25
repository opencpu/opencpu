httpget_github <- function(uri){
  #check if API has been enabled
  check.enabled("api.github");  

  #GET /ocpu/github/jeroen/mypackage
  gituser <- tolower(uri[1]);
  if(is.na(gituser)){
    res$checkmethod();    
    stop("Please specify a github username, e.g. /ocpu/github/hadley/")
  }

  gitrepo <- uri[2];
  if(is.na(gitrepo)){
    res$checktrail();
    repos <- github_list(gituser);
    res$sendlist(repos);
  }
  
  #init the gist
  pkgpath <- github_load(gituser, gitrepo);
  
  #remaining of the api
  reqtail <- tail(uri, -2)  

  #set cache value
  res$setcache("git");      
  
  #serve basic files
  httpget_package(pkgpath, reqtail);
}