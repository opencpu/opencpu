httpget_gist <- function(uri){
  #check if API has been enabled
  check.enabled("api.gist");  

  #GET /ocpu/gist/jeroen
  gistuser <- uri[1];
  if(is.na(gistuser)){
    res$checkmethod();    
    stop("Please specify a github username, e.g. /ocpu/gist/hadley")
  }

  gistid <- uri[2];
  if(is.na(gistid)){
    res$checktrail();    
    gists <- gist_list(gistuser);
    res$sendlist(gists);
  }
  
  #init the gist
  gist_path <- gist_load(gistuser, gistid);
  
  #remaining of the api
  reqtail <- utils::tail(uri, -2)  
  
  #calc full path
  fullpath <- do.call("file.path", as.list(c(gist_path, reqtail)));

  #set cache value
  res$setcache("git");  
  
  #serve basic files
  httpget_file(fullpath);
}
