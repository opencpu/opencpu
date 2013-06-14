errorif <- function(condition, msg){
  errorifnot(!condition, msg)
}

errorifnot <- function(condition, msg){
  if(!isTRUE(condition)){
    res$error(msg);
  }
}