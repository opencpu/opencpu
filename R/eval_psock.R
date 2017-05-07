call_psock <- function(fun, ..., timeout = Inf){
  # imports
  sendCall <- utils::getFromNamespace('sendCall', 'parallel')
  recvResult <- utils::getFromNamespace('recvResult', 'parallel')

  #create a child process
  cluster <- parallel::makePSOCKcluster(1)
  child <- cluster[[1]]

  #set the timeout
  setTimeLimit(elapsed = timeout)
  on.exit({
    setTimeLimit(cpu = Inf, elapsed = Inf)
    parallel::stopCluster(cluster)
  }, add = TRUE)

  #send the actual call. Make sure that packages get loaded.
  sendCall(child, fun, list(...))
  myresult <- recvResult(child)

  #raise error. Should not happen when call has been wrapped in request()
  if(inherits(myresult, "try-error")){
    stop(myresult)
  }
  return(myresult)
}

# This is very similar to parallel::clusterEvalQ() with a single node
eval_psock <- function(expr, envir = parent.frame(), timeout = 60){
  call_psock(eval, expr=substitute(expr), envir=as.list(envir))
}

# should take more than 5 sec
test_eval_psock <- function(len = 10000){
  n <- len^2
  eval_psock(svd(matrix(stats::rnorm(n), len)), timeout = 5);
}
