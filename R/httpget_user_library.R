httpget_user_library <- function(username, requri){
  #append user home library to path
  homelib <- userlibpath(username);

  #load package from homelib (dependencies can still be loaded from site library)  
  inlib(homelib, {
    httpget_library(homelib, requri);
  });
}
