#this function adds timeout and possibly other security options (if rapparmor is available)

eval_safe <- function(expr, envir=parent.frame(), timeout=60){
  hasrap <- isTRUE(getOption("hasrapparmor"))
  iswin <- identical(.Platform$OS.type, "windows");
  envir <- as.list(envir);
  
  if(hasrap){
    return(eval.secure(expr, envir, timeout=timeout, RLIMIT_CPU=timeout+3));
  } else if(iswin){
    opts <- options()[c("repos", "useFancyQuotes")]
    return(eval(as.call(list(quote(eval_psock), expr=substitute(expr), envir=envir, timeout=timeout, opts=opts))));
  } else {
    return(eval_fork(expr, envir, timeout=timeout))
  }
}
