gitsecret <- function(){
  tryCatch({
    secretfile <- "/etc/opencpu/secret.conf";
    as.list(fromJSON(secretfile));
  }, error=function(e){
    return(NULL)
  });
}
