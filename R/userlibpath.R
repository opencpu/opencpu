userlibpath <- function(username, postfix=""){
  userhome <- paste("/home/", username, sep="");
  homelib <- sub("~", userhome, Sys.getenv("R_LIBS_USER"));
  homelib <- gsub("/+$", "", homelib);
  homelib <- paste(homelib, postfix, sep="");  
  return(homelib);
}