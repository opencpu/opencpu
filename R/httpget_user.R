httpget_user <- function(uri){

  #GET /ocpu/user/jeroen
  username <- uri[1];
  if(is.na(username)){
    res$checkmethod();
    res$sendfile("/home")
  }
  
  #GET /ocpu/user/jeroen/lib
  what <- uri[2];
  if(is.na(what)){
    res$checkmethod();
    res$sendlist(c("library", "apps", "projects"));
  }
  
  #remaining of the api
  reqtail <- tail(uri, -2)
  switch(what,
    "library" = httpget_user_library(username, reqtail),
    "apps" = httpget_user_apps(username, reqtail),
    "projects" = httpget_user_projects(username, reqtail),
     res$notfound(message=paste("invalid api: /pub/", what, sep=""))
  );  
  
}