eval_current <- function(expr, envir=parent.frame(), timeout=60){  
  #set the timeout
  setTimeLimit(elapsed=timeout, transient=TRUE);
  
  #currently loaded packages
  currentlyloaded <- search();
  
  on.exit({
    #reset time limit
    setTimeLimit(cpu=Inf, elapsed=Inf, transient=FALSE);
    
    #try to detach packages that were attached during eval
    newlyloaded <- search();
    todetach <- newlyloaded[!(newlyloaded %in% currentlyloaded)];
    for(i in seq_along(todetach)){
      try(detach(todetach[i], unload=TRUE));
    }    
    
  });
  
  eval(expr, envir) 
}
