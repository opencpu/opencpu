#changes default to call.=FALSE
stop <- function(..., call. = FALSE, domain = NULL){
  base::stop(..., call. = call., domain = domain);
}
