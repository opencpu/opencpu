parse_query <- function(query){
  if(is.raw(query)){
    query <- rawToChar(query);
  }
  stopifnot(is.character(query));
  
  argslist <- strsplit(query, "&")[[1]];
  argslist <- strsplit(argslist, "=");
  ARGS <- lapply(argslist, "[[", 2);
  ARGS <- lapply(ARGS, function(s) {utils:::URLdecode(chartr('+',' ',s))});
  names(ARGS) <- lapply(argslist, "[[", 1);    
  return(ARGS)
}