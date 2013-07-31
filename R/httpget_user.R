httpget_user <- function(uri){
  #check if API has been enabled
  check.enabled("api.user");  
  
  #no windows
  if(identical(.Platform$OS.type, "windows")){
    stop("The /ocpu/user API is not supported on MS windows.")
  }

  #GET /ocpu/user/jeroen
  username <- uri[1];
  if(is.na(username)){
    res$checkmethod();
    res$sendfile(userhome());
  }
  
  #GET /ocpu/user/jeroen/lib
  what <- uri[2];
  if(is.na(what)){
    res$checkmethod();
    res$sendlist(c("library", "apps"));
  }
  
  #remaining of the api
  reqtail <- tail(uri, -2)
  switch(what,
    "library" = httpget_user_library(username, reqtail),
    "apps" = httpget_user_apps(username, reqtail),
     res$notfound(message=paste("invalid api: /user/", username, "/", what, sep=""))
  );  
}
