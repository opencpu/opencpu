extract_source <- function(evaluation){
  index <- vapply(evaluation, inherits, logical(1), "source")
  evaluation <- evaluation[index]
  output <- lapply(evaluation, "[[", "src")
  return(output)
}

extract_text <- function(evaluation){
  index <- vapply(evaluation, inherits, logical(1), "character")
  output <- evaluation[index]
  return(output)
}

extract_message <- function(evaluation){
  index <- vapply(evaluation, inherits, logical(1), "message")
  output <- evaluation[index]
  return(output)
}

extract_warning <- function(evaluation){
  index <- vapply(evaluation, inherits, logical(1), "warning")
  output <- evaluation[index]
  return(output)
}

extract_error <- function(evaluation){
  index <- vapply(evaluation, inherits, logical(1), "error")
  output <- evaluation[index]
  return(output)
}

extract_graphics <- function(evaluation){
  index <- vapply(evaluation, inherits, logical(1), "recordedplot")
  output <- evaluation[index]
  return(output)
}

extract_console <- function(evaluation){
  messages <- lapply(evaluation, function(x){
    if(inherits(x, "warning")) {
      return(paste("Warning message:", clean_string(x$message), sep="\n"));
    } else if(inherits(x, "message")) {
      return(paste("Message:", clean_string(x$message), sep="\n"));
    } else if(inherits(x, "error")){
      return(paste("Error:", x$message, sep="\n"));
    } else if(inherits(x, "character")){
      return(sub("\n$", "", x));
    } else if(inherits(x, "source")){
      return(gsub("\n", "\n+ ", sub("\n$", "", paste(">",x$src))));
    } else if(inherits(x, "recordedplot")){
      return("[[ plot ]]");
    } else {
      return();
    }
  });
  unlist(messages);
}

clean_string <- function(x){
  return(gsub("^[\\s]+|[\\s]+$", "", x, perl=TRUE));
}

extract <- function(evaluation, what=c("source", "text", "graphics", "message", "warning", "error", "value", "console")){
  #stopifnot(inherits(evaluation, "evaluation"))
  stopifnot(length(what) == 1)

  what <- match.arg(what);
  switch(what,
     "source"  = extract_source(evaluation),
     "text"    = extract_text(evaluation),
     "message" = extract_message(evaluation),
     "console" = extract_console(evaluation),
     "warning" = extract_warning(evaluation),
     "error"   = extract_error(evaluation),
     "graphics"= extract_graphics(evaluation)
  )
}

