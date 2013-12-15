eval_current <- function(expr, envir=parent.frame(), timeout=60){  
  #set the timeout
  setTimeLimit(elapsed=timeout, transient=TRUE);
  
  #currently attached packages
  attached_before <- search();
  
  on.exit({
    #reset time limit
    setTimeLimit(cpu=Inf, elapsed=Inf, transient=FALSE);
    
    #try to detach packages that were attached during eval
    attached_after <- search();
    loaded_after <- loadedNamespaces();
    
    #only deals only with attaching, not unloading
    for(pkg in attached_after){
      if(pkg %in% attached_before){
        next;
      } else if(sub("package:", "", pkg) %in% loaded_after) {
        try(detach(pkg, unload=FALSE, character.only=TRUE, force=TRUE));
      } else {
        try(detach(pkg, unload=TRUE, character.only=TRUE, force=TRUE));        
      }
    }
  });
  
  eval(expr, envir) 
}
