eval_current <- function(expr, envir=parent.frame(), timeout=60){  
  #set the timeout
  setTimeLimit(elapsed=timeout, transient=TRUE);
  
  #currently attached packages
  attached_before <- search();
  loaded_before <- loadedNamespaces();
  
  on.exit({
    #reset time limit
    setTimeLimit(cpu=Inf, elapsed=Inf, transient=FALSE);
    
    #try to detach packages that were attached during eval
    attached_after <- search();
    
    #only deals only with attaching, not unloading
    for(pkg in attached_after){
      if(pkg %in% attached_before){
        next;
      } else if(sub("package:", "", pkg) %in% loaded_before) {
        try(detach(pkg, unload=FALSE, character.only=TRUE, force=TRUE));
      } else {
        #Unloading in R is buggy
        #try(detach(pkg, unload=TRUE, character.only=TRUE, force=TRUE)); 
        try(detach(pkg, unload=FALSE, character.only=TRUE, force=TRUE));
      }
    }
    
    #also unload non-attached namespaces here?
    #currently this is difficult because they need to be unloaded in the correct order  
  });
  
  eval(expr, envir) 
}
