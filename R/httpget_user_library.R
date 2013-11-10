httpget_user_library <- function(username, requri){
  #append user home library to path
  homelib <- userlibpath(username);
  
  #check if exists
  if(!file.exists(homelib)){
    res$error(paste("R package library for user", username, "not found."), 404);
  }

  #load package from homelib (dependencies can still be loaded from site library)  
  inlib(homelib, {
    httpget_library(homelib, requri);
  });
}
