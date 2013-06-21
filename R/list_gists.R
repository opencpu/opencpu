list_gists <- function(username){
  library(httr);
  library(RJSONIO);
  out <- GET("https://api.github.com/users/jeroenooms/gists", add_headers("User-Agent" = "OpenCPU"));
  stopifnot(out$status == 200);
  response <- fromJSON(rawToChar(out$content));
  unlist(lapply(response, function(x) {x$id}));                  
}
