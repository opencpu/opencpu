httpget_user_library <- function(username, requri){
  #append user home library to path
  homelib <- userlibpath(username);
  .libPaths(homelib);
  
  #load package from homelib (dependencies can still be loaded from site library)
  httpget_library(homelib, requri);
}