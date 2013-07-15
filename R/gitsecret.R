gitsecret <- function(){
  output <- try({
    secretfile <- "/etc/opencpu/secret.conf";
    out <- as.list(fromJSON(secretfile));
    stopifnot(!is.null(out$client_id));
    stopifnot(!is.null(out$client_secret));
    out
  });
  
  if(is(output, "try-error")){
    return(NULL)
  } else {
    return(output);
  }  
}
