# Helper for loading and getting settings
config <- local({
  conflist <- list()

  load <- function(filepath){
    message("Loading config from ", filepath)
    newconf <- as.list(fromJSON(filepath));
    for(i in seq_along(newconf)){
      val <- newconf[[i]]
      name <- names(newconf[i])
      # Turn JSON 'null' value into NA
      conflist[[name]] <<- ifelse(length(val), val, NA)
    }
  }

  function(x){
    value = conflist[[x]];
    if(is.null(value)){
      stop("System error! No config set for: ", x);
    }
    return(value);
  }
})

# Used by single-user server only
create_user_config <- function(){
  configfile <- get_user_conf()
  if(file.exists(configfile)){
    if(!validate(readLines(configfile))){
      stop("Config contains invalid JSON: ", configfile)
    }
  } else {
    defaultconf <- system.file("config/defaults.conf", package = packagename);
    userconf <- get_user_conf()
    dir.create(dirname(userconf), showWarnings = FALSE, recursive = TRUE)
    if(file.copy(defaultconf, userconf)){
      message("Creating new user config file: ", configfile);
    } else {
      warning("Failed to create new config file: ", configfile, ". Using default config.")
    }
  }
}

get_user_conf <- function(){
  if(is_rapache() || is_admin()){
    return("/etc/opencpu/server.conf")
  } else {
    file.path(getlocaldir(), "user.conf")
  }
}
