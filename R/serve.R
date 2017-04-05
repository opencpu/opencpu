serve <- function(REQDATA){
  
  # Windows doesn't have fork / rapache
  if(is_windows()){
    if(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS")){
      return(request(eval_current(main(REQDATA), timeout=config("timelimit.get"))));
    } else {
      return(tryCatch({
        eval_psock(get("request", envir=asNamespace("opencpu"))(get("main", envir=asNamespace("opencpu"))(REQDATA)), timeout=config("timelimit.post"));
      }, error = reshandler));
    }
  }
  
  # Everything else (rapache, linux, macos)
  totaltimelimit <- if(isTRUE(grepl("^/webhook", REQDATA$PATH_INFO))) {
    config("timelimit.webhook");
  } else if(isTRUE(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS"))){
    config("timelimit.get");
  } else {
    config("timelimit.post");
  }
    
  # On RApache, the RAppArmor package must always be installed. But we use the profile only if available.
  profile <- if(use_apparmor() && !no_rapparmor()){
    "opencpu-main"
  }
  
  # Don't enforce proc limit when running single user server (regular user)
  nproc <- if(is_rapache()){
    config("rlimit.nproc")
  }

  return(request(unix::eval_safe(main(REQDATA), timeout = totaltimelimit, profile = profile, rlimits = list(
    cpu = totaltimelimit + 5, as = config("rlimit.as"), fsize = config("rlimit.fsize"), nproc = nproc))))
}