parse_query <- function(query){
  if(is.raw(query)){
    query <- rawToChar(query);
  }
  stopifnot(is.character(query));

  #httpuv includes the question mark in query string
  query <- sub("^[?]", "", query)
  
  #split by & character
  argslist <- sub("^&", "", regmatches(query, gregexpr("(^|&)[^=]+=[^&]+", query))[[1]])
  argslist <- strsplit(argslist, "=");
  ARGS <- lapply(argslist, function(x){if(length(x) < 2) "" else paste(x[-1], collapse="=")});
  ARGS <- lapply(ARGS, function(s) {utils::URLdecode(chartr('+',' ',s))});
  names(ARGS) <- lapply(argslist, "[[", 1);    
  return(ARGS)
}