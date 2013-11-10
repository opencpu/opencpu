#doesn't work on windows. R_LIBS_USER will always be logged in user.
userlibpath <- function(username, postfix=""){
  homelib <- path.expand(sub("~", paste0("~", username), Sys.getenv("R_LIBS_USER"), fixed=TRUE));
  homelib <- gsub("/+$", "", homelib);
  homelib <- paste(homelib, postfix, sep="");
  if(file.exists(homelib)){
    return(homelib);
  } else {
    return("");
  }
}
