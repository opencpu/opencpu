serve <- function(REQDATA){

  #On Windows, use the main proc for safe GET requests
  #Safe here means no packages will be loaded
  if(identical(.Platform$OS.type, "windows")) {   
    if (REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS") && !isdangerous(REQDATA$PATH_INFO)){
      return(request(eval_current(main(REQDATA), timeout=config("timelimit.get"))));
    } else {
      return(tryCatch({
        eval_psock(get("request", envir=asNamespace("opencpu"))(get("main", envir=asNamespace("opencpu"))(REQDATA)), timeout=config("timelimit.post"));
      }, error = reshandler));      
    }
  } 
  
  #This is temporary fix to deal with the corefoundation forking issues on Mavericks. 
  #We want to avoid forking for requests which do aribtrary code execution (and hence could call CF)
  #We can probably remove this when libuv 0.12 is released which no longer depends on CF.
  if(grepl("darwin", R.Version()$platform)){
    if(REQDATA$METHOD %in% c("HEAD", "GET", "OPTIONS") && !isdangerous(REQDATA$PATH_INFO)){
      return(request(eval_current(main(REQDATA), timeout=config("timelimit.get"))));
    } else if(REQDATA$METHOD == "POST") {
      return(tryCatch({
        eval_psock(get("request", envir=asNamespace("opencpu"))(get("main", envir=asNamespace("opencpu"))(REQDATA)), timeout=config("timelimit.post"));
      }, error = reshandler));
    }
  } 
  
  #If none of the above: use forking method
  totaltimelimit <- ifelse(isTRUE(REQDATA$METHOD %in% c("HEAD", "GET")), config("timelimit.get"), config("timelimit.post"));  
  if(isTRUE(getOption("rapache"))){
    request(RAppArmor::eval.secure(main(REQDATA), timeout=totaltimelimit, RLIMIT_CPU=totaltimelimit+5, RLIMIT_AS=config("rlimit.as"), RLIMIT_FSIZE=config("rlimit.fsize"), RLIMIT_NPROC=config("rlimit.nproc"), profile="opencpu-main"));
  } else { 
    #Note that fork happens inside request() instead of other way around.
    request(eval_fork(main(REQDATA), timeout=totaltimelimit));
  }
}
