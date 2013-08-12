eval_current <- function(expr, envir=parent.frame(), timeout=60){  
  #set the timeout
  setTimeLimit(elapsed=timeout, transient=TRUE);
  
  #currently loaded packages
  currentlyattached <- search();
  currentlyloaded <- loadedNamespaces();
  
  on.exit({
    #reset time limit
    setTimeLimit(cpu=Inf, elapsed=Inf, transient=FALSE);
    
    #try to detach packages that were attached during eval
    nowattached <- search();
    todetach <- nowattached[!(nowattached %in% currentlyattached)];
    for(i in seq_along(todetach)){
      try(detach(todetach[i], unload=TRUE, character.only=TRUE, force=TRUE));
    }
  });
  
  eval(expr, envir) 
}
