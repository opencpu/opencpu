#doesn't work on windows. R_LIBS_USER will always be logged in user.
userlibpath <- function(username, postfix=""){
  userhomepath <- file.path(userhome(), username);
  homelib <- sub("~", userhomepath, Sys.getenv("R_LIBS_USER"));
  homelib <- gsub("/+$", "", homelib);
  homelib <- paste(homelib, postfix, sep="");  
  return(homelib);
}

userhome <- function(){
  if(Sys.info()[["effective_user"]] %in% c("root", "www-data")){
    return("/home")
  } else {
    return(dirname(path.expand("~")));
  }
}
