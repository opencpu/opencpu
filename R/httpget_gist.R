httpget_gist <- function(uri){

  #GET /ocpu/gist/jeroen
  gistuser <- uri[1];
  if(is.na(gistuser)){
    res$checkmethod();    
    stop("Please specify a gist username and id, e.g. /ocpu/gist/jerry/123456/")
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
  reqtail <- tail(uri, -2)  
  
  #calc full path
  fullpath <- do.call("file.path", as.list(c(gist_path, reqtail)));
  
  #serve basic files
  httpget_file(fullpath);
}
