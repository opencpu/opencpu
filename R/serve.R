serve <- function(REQDATA){

  #detect OS
  OS <- .Platform$OS.type;
  
  #for GET requests we use the main proc
  if(identical(OS, "windows") && (REQDATA$METHOD %in% c("HEAD", "GET"))){
    return(request(eval_current(main(REQDATA), timeout=config("time.limit"))));   
  } 
  
  #for non GET we use a psock process
  if(identical(OS, "windows")){
    #return(request(main(REQDATA)));
    return(request(eval_psock(ocpu:::main(REQDATA), timeout=config("time.limit"))));   
  } 
  
  #On unix we always fork:
  #eval_psock(ocpu:::request(ocpu:::main(REQDATA)), timeout=config("time.limit"))
  request(eval_fork(main(REQDATA), timeout=config("time.limit")));
}
