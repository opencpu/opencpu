error2file <- function(e){
  mytempfile <- tempfile();
  errmsg <- e$message;
  if(isTRUE(config("error.showcall")) && !is.null(e$call)){
    errmsg <- c(errmsg, "", "In call:", deparse(e$call));
  }
  write(errmsg, mytempfile);
  return(mytempfile)  
}
