config <- local({
  conflist <- list()
  
  load <- function(filepath){
    newconf <- as.list(fromJSON(filepath));
    for(i in seq_along(newconf)){
      name <- names(newconf[i]);
      conflist[[name]] <<- newconf[[i]];
    }
  }
  
  get <- function(x){
    value = conflist[[x]];
    if(is.null(value)){
      stop("System error! No config set for: ", x);
    }
    return(value);
  }
  
  #default is get
  get
})