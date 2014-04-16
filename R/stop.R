#changes default to call.=FALSE
stop <- function(..., call. = FALSE, domain = NULL){
  args <- list(...)
  if(length(args) == 1L && inherits(args[[1L]], "condition")){
    #when error is a condition object
    base::stop(args[[1L]])
  } else{
    #when error is a string
    base::stop(..., call. = call., domain = domain);    
  }
}
