#doesn't work on windows. R_LIBS_USER will always be logged in user.
userlibpath <- function(username, postfix=""){
  home <- homedir(username);
  check_mode(home)
  homelib <- sub("~", home, Sys.getenv("R_LIBS_USER", default_lib_user()), fixed=TRUE);
  if(is_rapache() || is_admin()){
    # This is needed as of R-4.2 because R now hardcodes R_LIBS_USER to a full path
    apache_home <- homedir(Sys.info()[['user']])
    homelib <- sub(apache_home, home, homelib, fixed = TRUE)
  }
  homelib <- gsub("/+$", "", homelib);
  homelib <- paste(homelib, postfix, sep="");
  if(file.exists(homelib)){
    return(homelib);
  }

  #failed
  return("");
}

default_lib_user <- function(){
  info <- R.Version()
  sprintf('~/R/%s-library/%s.%s', info$platform, info$major, substring(info$minor, 1, 1))
}

homedir <- function(username){
  getNamespace('unix')
  tryCatch({
    unix::user_info(username)$dir
  }, error = function(e){
    stop("Could not find or access home directory of user ", username);
  })
}

check_mode <- function(path){
  mode <- file.info(path)$mode
  if(is.na(mode)){
    stop("Failed to read mode for ", path)
  }
  # Check for r-x permission
  if((mode & "005") < 5){
    stop("Directory ", path, " is not readble. Try running: chmod +rx ", path)
  }
}
