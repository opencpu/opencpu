# Helper for loading and getting settings
config <- local({
  conflist <- list()

  load <- function(filepath){
    newconf <- as.list(fromJSON(filepath));
    for(i in seq_along(newconf)){
      name <- names(newconf[i]);
      conflist[[name]] <<- newconf[[i]];
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
create_home_config <- function(){
  configfile <- get_home_conf()
  if(file.exists(configfile)){
    if(!validate(readLines(configfile))){
      stop("Config contains invalid JSON: ", configfile)
    }
  } else {
    defaultconf <- system.file("config/defaults.conf", package=packagename);
    if(file.copy(defaultconf, get_home_conf())){
      message("Creating new config file: ", configfile);
    } else {
      warning("Failed to create new config file: ", configfile, ". Using default config.")
    }
  }
}

get_home_conf <- function(){
  rappdirs::user_config_dir("opencpu.conf")
}
