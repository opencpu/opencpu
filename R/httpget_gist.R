httpget_gist <- function(uri){

  #GET /ocpu/gist/jeroen
  gistuser <- uri[1];
  gistid <- uri[2];
  if(is.na(gistuser) || is.na(gistid)){
    res$checkmethod();    
    stop("Please specify a gist username and id, e.g. /ocpu/gist/jerry/123456/")
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