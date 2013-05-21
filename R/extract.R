extract <- local({  
  extract_source <- function(evaluation){
    index <- vapply(evaluation, is, logical(1), "source")
    evaluation <- evaluation[index]
    output <- lapply(evaluation, "[[", "src")
    return(output)
  }
  
  extract_text <- function(evaluation){
    index <- vapply(evaluation, is, logical(1), "character")
    output <- evaluation[index]
    return(output)
  }
  
  extract_message <- function(evaluation){
    index <- vapply(evaluation, is, logical(1), "message")
    output <- evaluation[index]
    return(output)  
  }
  
  extract_warning <- function(evaluation){
    index <- vapply(evaluation, is, logical(1), "warning")
    output <- evaluation[index]
    return(output)  
  }
  
  extract_error <- function(evaluation){
    index <- vapply(evaluation, is, logical(1), "error")
    output <- evaluation[index]
    return(output)  
  }
  
  extract_graphics <- function(evaluation){
    index <- vapply(evaluation, is, logical(1), "recordedplot")
    output <- evaluation[index]
    output <- lapply(output, fixplot)
    return(output)  
  }  
  
  extract <- function(evaluation, what=c("source", "text", "graphics", "message", "warning", "error", "value")){
    #stopifnot(is(evaluation, "evaluation"))
    stopifnot(length(what) == 1)
    
    what <- match.arg(what);
    switch(what,
       "source"  = extract_source(evaluation),
       "text"    = extract_text(evaluation),
       "message" = extract_message(evaluation),
       "warning" = extract_warning(evaluation),
       "error"   = extract_error(evaluation),
       "graphics"= extract_graphics(evaluation)
    )  
  }  
});