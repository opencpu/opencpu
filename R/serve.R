serve <- function(REQDATA){
  
  #Cloud server
  if(is_rapache()){
    #Determine time limits
    totaltimelimit <- if(isTRUE(grepl("^/webhook", REQDATA$PATH_INFO))) {
      config("timelimit.webhook");
    } else if(isTRUE(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS"))){
      config("timelimit.get");
    } else {
      config("timelimit.post");
    };
    
    # Run without RAppArmor on legacy systems.
    if(no_rapparmor()){
      return(request(eval_fork(main(REQDATA), timeout=totaltimelimit)))
    }
    
    # On RApache, the RAppArmor package must always be installed. But we use the profile only if available.
    if(use_apparmor()){
      return(request(RAppArmor::eval.secure(main(REQDATA), timeout=totaltimelimit, RLIMIT_CPU=totaltimelimit+5, 
        RLIMIT_AS=config("rlimit.as"), RLIMIT_FSIZE=config("rlimit.fsize"), RLIMIT_NPROC=config("rlimit.nproc"),
        closeAllConnections = TRUE, profile="opencpu-main")));
    } else { 
      return(request(RAppArmor::eval.secure(main(REQDATA), timeout=totaltimelimit, RLIMIT_CPU=totaltimelimit+5, 
        RLIMIT_AS=config("rlimit.as"), RLIMIT_FSIZE=config("rlimit.fsize"), RLIMIT_NPROC=config("rlimit.nproc"),
        closeAllConnections = TRUE)));  
    }
  }
  
  if(is_windows()){
    if(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS")){
      return(request(eval_current(main(REQDATA), timeout=config("timelimit.get"))));
    } else {
      return(tryCatch({
        eval_psock(get("request", envir=asNamespace("opencpu"))(get("main", envir=asNamespace("opencpu"))(REQDATA)), timeout=config("timelimit.post"));
      }, error = reshandler));
    }
  }
  
  #Linux, OSX, BSD, etc
  if(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS")){
    return(request(sys::eval_safe(main(REQDATA), timeout = config("timelimit.get"))));
  } else {
    return(request(sys::eval_safe(main(REQDATA), timeout = config("timelimit.post"))));
  }
}
