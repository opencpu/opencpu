#doesn't work on windows. R_LIBS_USER will always be logged in user.
userlibpath <- function(username, postfix=""){
  home <- homedir(username);
  homelib <- sub("~", home, Sys.getenv("R_LIBS_USER"), fixed=TRUE);
  homelib <- gsub("/+$", "", homelib);
  homelib <- paste(homelib, postfix, sep="");
  if(file.exists(homelib)){
    return(homelib);
  } 
  
  #failed
  return("");
}

homedir <- function(username){
  #easiest method
  home <- path.expand(paste0("~", username));
  if(file.exists(home)){
    return(home);
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
  
  stop("Could not find home directory for user", username);
}