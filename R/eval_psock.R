eval_psock <- function(expr, envir=parent.frame(), timeout=60){
  #create a child process
  cluster <- parallel::makePSOCKcluster(1);
  child <- cluster[[1]];
  parallel:::sendCall(child, eval, list(quote(Sys.getpid())));
  pid <- parallel:::recvResult(child);
  
  #set the timeout
  setTimeLimit(elapsed=timeout, transient=TRUE);
  on.exit({
    setTimeLimit(cpu=Inf, elapsed=Inf, transient=FALSE);
    tools::pskill(pid); #win
    tools::pskill(pid, tools::SIGKILL); #nix
    parallel:::stopNode(child);
  });
  
  #send the actual call
  #package/objects are already loaded??
  parallel:::sendCall(child, eval, list(expr=substitute(expr), envir=as.list(envir)));
  myresult <- parallel:::recvResult(child);
  
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

