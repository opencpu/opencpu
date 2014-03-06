createconfigfile <- function(){
  configfile <- path.expand("~/.opencpu.conf");
  if(file.exists(configfile)){
    if(validate(readLines(configfile))){
      message("Using config: ", configfile)
    } else {
      stop("Config contains invalid JSON: ", configfile)
    }
  } else {
    defaultconf <- system.file("config/defaults.conf", package=packagename);
    if(file.copy(defaultconf, "~/.opencpu.conf")){
      message("Creating new config file: ", configfile);
    } else {
      warning("Failed to create new config file: ", configfile, ". Using default config.")      
    };
  }
}