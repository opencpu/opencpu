#doesn't work on windows. R_LIBS_USER will always be logged in user.
userlibpath <- function(username, postfix=""){
  userhome <- paste("/home/", username, sep="");
  homelib <- sub("~", userhome, Sys.getenv("R_LIBS_USER"));
  homelib <- gsub("/+$", "", homelib);
  homelib <- paste(homelib, postfix, sep="");  
  return(homelib);
}