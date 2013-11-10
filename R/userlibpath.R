#doesn't work on windows. R_LIBS_USER will always be logged in user.
userlibpath <- function(username, postfix=""){
  homelib <- path.expand(sub("~", paste0("~", username), Sys.getenv("R_LIBS_USER"), fixed=TRUE));
  homelib <- gsub("/+$", "", homelib);
  homelib <- paste(homelib, postfix, sep="");
  if(file.exists(homelib)){
    return(homelib);
  } 
  
  #second method
  if(file.exists("/etc/passwd")){
    out <- try(read.table("/etc/passwd", sep=":", row.names=1, as.is=TRUE));
    if(!is(out, "try-error") && length(out) && nrow(out)){
      homelib <- out[username, "V6"];
      if(!is.na(homelib) && file.exists(homelib)){
        return(homelib)
      }
    }
  }   
  
  #all failed
  return("");
}
