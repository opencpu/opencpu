#doesn't work on windows. R_LIBS_USER will always be logged in user.
userlibpath <- function(username, postfix=""){
  usertable <- read.table("/etc/passwd", sep=":", as.is=TRUE, row.names=1);
  userhome <- usertable[username,"V6"];
  homelib <- sub("~", userhome, Sys.getenv("R_LIBS_USER"));
  homelib <- gsub("/+$", "", homelib);
  homelib <- paste(homelib, postfix, sep="");
  if(file.exists(homelib)){
    return(homelib);
  } else {
    return("");
  }
}
