eval_current <- function(expr, envir=parent.frame(), timeout=60){  
  #set the timeout
  setTimeLimit(elapsed=timeout, transient=TRUE);
  on.exit({
    setTimeLimit(cpu=Inf, elapsed=Inf, transient=FALSE);
  });
  
  eval(expr, envir) 
}
