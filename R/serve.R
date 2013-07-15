serve <- function(REQDATA){

  #detect OS
  OS <- .Platform$OS.type;
  
  #for GET requests we use the main process
  if(identical(OS, "windows") && (REQDATA$METHOD %in% c("HEAD", "GET"))){
    return(request(eval_current(main(REQDATA), timeout=config("time.limit"))));   
  } 
  
  #for non GET we use a psock process
  if(identical(OS, "windows")){
    #we use another trycatch block because request happens inside psockcluster
    return(tryCatch({
      eval_psock(ocpu:::request(ocpu:::main(REQDATA)), timeout=config("time.limit"));
    }, error = reshandler));
  } 
  
  #On unix we always fork:
  #Note that fork happens inside request() instead of other way around.
  request(eval_fork(main(REQDATA), timeout=config("time.limit")));
}
