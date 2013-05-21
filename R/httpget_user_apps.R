httpget_user_apps <- function(username, reqtail){
  #user apps lib
  userappslib <- userlibpath(username, "-apps");
  httpget_apps(userappslib, reqtail);
}
