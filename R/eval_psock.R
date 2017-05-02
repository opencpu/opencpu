# This is very similar to parallel::clusterEvalQ() with a single node
eval_psock <- function(expr, envir = parent.frame(), timeout = 60){
  # imports
  sendCall <- utils::getFromNamespace('sendCall', 'parallel')
  recvResult <- utils::getFromNamespace('recvResult', 'parallel')

  #create a child process
  cluster <- parallel::makePSOCKcluster(1)
  child <- cluster[[1]]
  sendCall(child, eval, list(quote(Sys.getpid())))
  pid <- recvResult(child)

  #set the timeout
  setTimeLimit(elapsed = timeout, transient = TRUE)
  on.exit({
    setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
    parallel::stopCluster(cluster)
    #tools::pskill(pid) # Just in case
  })

  #send the actual call. Make sure that packages get loaded.
  sendCall(child, eval, list(expr=substitute(expr), envir=as.list(envir)))
  myresult <- recvResult(child)

  #raise error. Should not happen when call has been wrapped in request()
  if(inherits(myresult, "try-error")){
    stop(myresult)
  }
  return(myresult)
}

# should take more than 5 sec
test_eval_psock <- function(len = 10000){
  n <- len^2
  eval_psock(svd(matrix(stats::rnorm(n), len)), timeout = 5);
}
