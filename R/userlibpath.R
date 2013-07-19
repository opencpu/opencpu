#doesn't work on windows. R_LIBS_USER will always be logged in user.
userlibpath <- function(username, postfix=""){
  userhome <- file.path(userhome(), username);
  homelib <- sub("~", userhome, Sys.getenv("R_LIBS_USER"));
  homelib <- gsub("/+$", "", homelib);
  homelib <- paste(homelib, postfix, sep="");  
  return(homelib);
}

userhome <- function(){
  if(Sys.info()[["effective_user"]] == "root"){
    return("/home")
  } else {
    return(dirname(path.expand("~")));
  }
}
