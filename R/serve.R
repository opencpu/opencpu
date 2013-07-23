serve <- function(REQDATA){

  #detect OS
  OS <- .Platform$OS.type;
  
  #for GET requests we use the main process
  if(identical(OS, "windows") && (REQDATA$METHOD %in% c("HEAD", "GET")) && !isdangerous(REQDATA$PATH_INFO)){
    return(request(eval_current(main(REQDATA), timeout=config("timelimit.get"))));
  } 
  
  #for non GETor unsafe we use a psock process in windows
  if(identical(OS, "windows")){
    #we use another trycatch block because request happens inside psockcluster
    return(tryCatch({
      eval_psock(ocpu:::request(ocpu:::main(REQDATA)), timeout=config("timelimit.post"));
    }, error = reshandler));
  } 
  
  #On unix we always fork:
  #timelimit
  if(REQDATA$METHOD %in% c("HEAD", "GET")){
    totaltimelimit <- config("timelimit.get");
  } else {
    totaltimelimit <- config("timelimit.post");  
  }  
  
  if(isTRUE(getOption("rapache"))){
    request(RAppArmor::eval.secure(main(REQDATA), timeout=totaltimelimit, RLIMIT_CPU=totaltimelimit+5));
  } else { 
    #Note that fork happens inside request() instead of other way around.
    request(eval_fork(main(REQDATA), timeout=totaltimelimit));
  }
}
