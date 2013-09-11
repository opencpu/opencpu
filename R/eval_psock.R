##NOTE: the timeout works in rstudio and rgui on win, but it doesn't work in rterminal.
eval_psock <- function(expr, envir=parent.frame(), timeout=60, opts){
  
  #create a child process
  cluster <- parallel::makePSOCKcluster(1);
  child <- cluster[[1]];
  from("parallel", "sendCall")(child, eval, list(quote(Sys.getpid())));
  pid <- from("parallel", "recvResult")(child);
  
  #set the timeout
  setTimeLimit(elapsed=timeout, transient=TRUE);
  on.exit({
    setTimeLimit(cpu=Inf, elapsed=Inf, transient=FALSE);
    tools::pskill(pid); #win
    tools::pskill(pid, tools::SIGKILL); #nix
    from("parallel", "stopNode")(child);
  });
  
  #try to set options
  if(!missing(opts)){
    from("parallel", "sendCall")(child, eval, list(quote(options(opts)), envir=list(opts=as.list(opts))));
    from("parallel", "recvResult")(child);    
  }
  
  #send the actual call
  #package/objects are already loaded??
  from("parallel", "sendCall")(child, eval, list(expr=substitute(expr), envir=as.list(envir)));
  myresult <- from("parallel", "recvResult")(child);
  
  #reset timelimit
  setTimeLimit(cpu=Inf, elapsed=Inf, transient=TRUE);
  
  #forks don't throw errors themselves
  if(is(myresult,"try-error")){
    #snow only returns the message, not an error object
    stop(myresult, call.=FALSE);
  }
  
  #send the buffered response
  return(myresult);   
}

# test <- function(){
#   n <- 1e8;
#   k <- 1e4;
#   #this should take more than 10 sec
#   eval_psock(svd(matrix(rnorm(n), k)), timeout=10);
# }
# 
# system.time(test());

