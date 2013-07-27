error2file <- function(e){
  mytempfile <- tempfile();
  errmsg <- e$message;
  if(isTRUE(config("error.showcall"))){
    errmsg <- c(errmsg, "", "In call:", deparse(e$call));
  }
  write(errmsg, mytempfile);
  return(mytempfile)  
}
