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
    
    #Use AppArmor if available.
    if(has_apparmor()){
      request(RAppArmor::eval.secure(main(REQDATA), timeout=totaltimelimit, RLIMIT_CPU=totaltimelimit+5, RLIMIT_AS=config("rlimit.as"), RLIMIT_FSIZE=config("rlimit.fsize"), RLIMIT_NPROC=config("rlimit.nproc"), profile="opencpu-main"));
    } else { 
      #Note that fork happens inside request() instead of other way around.
      request(eval_fork(main(REQDATA), timeout=totaltimelimit));
    }
  }
  
  #Note: forks now disabled on OSX cause of problems with rJava and RCurl
  if(is.windows() || is_mac()){
    if(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS")){
      return(request(eval_current(main(REQDATA), timeout=config("timelimit.get"))));
    } else {
      return(tryCatch({
        eval_psock(get("request", envir=asNamespace("opencpu"))(get("main", envir=asNamespace("opencpu"))(REQDATA)), timeout=config("timelimit.post"));
      }, error = reshandler));
    }
  }
  
  #Linux, BSD, etc
  if(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS")){
    return(request(eval_current(main(REQDATA), timeout=config("timelimit.get"))));
  } else {
    request(eval_fork(main(REQDATA), timeout=config("timelimit.post")));
  }
}
