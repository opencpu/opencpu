httpget_user <- function(uri){
  #check if API has been enabled
  check.enabled("api.user");  
  
  #no windows
  if(identical(.Platform$OS.type, "windows")){
    stop("The /ocpu/user API is not supported on MS windows.")
  }

  #GET /ocpu/user
  username <- uri[1];
  if(is.na(username)){
    res$checkmethod();
    res$sendlist(listallusers());
  }
  
  #Check that user exists
  if(!(username %in% listallusers(FALSE))){
    res$error(paste("User", username, "not found."), 404);
  }
  
  #GET /ocpu/user/jeroen/lib
  what <- uri[2];
  if(is.na(what)){
    res$checkmethod();
    if(file.exists(userlibpath(username))){
      res$sendlist(c("library"));
    } else {
      res$sendlist(c());
    }
  }
  
  #remaining of the api
  reqtail <- tail(uri, -2)
  switch(what,
    "library" = httpget_user_library(username, reqtail),
    "apps" = httpget_user_apps(username, reqtail),
     res$notfound(message=paste("invalid user api: ", what, sep=""))
  );  
}
