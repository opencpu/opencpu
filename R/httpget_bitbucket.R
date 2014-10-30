httpget_bitbucket <- function(uri){
  check.enabled("api.bitbucket");

  #GET /ocpu/bitbucket/jeroen/mypackage
  gituser <- uri[1];
  if(is.na(gituser)){
    res$checkmethod();
    stop("Please specify a bitbucket username, e.g. /ocpu/bitbucket/moosilauke18/")
  }
  
  gitrepo <- uri[2];
  if(is.na(gitrepo)){
    res$checktrail();
    repos <- bitbucket_list(gituser);
    res$sendlist(repos);
  }

  #init the gist
  pkgpath <- bitbucket_load(gituser, gitrepo);

  #remaining of the api
  reqtail <- tail(uri, -2)

  #set cache value
  res$setcache("git");

  #serve basic files
  httpget_package(pkgpath, reqtail);
}
