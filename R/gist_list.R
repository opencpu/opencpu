gist_list <- function(username){
  library(httr);
  library(RJSONIO);
  out <- GET("https://api.github.com/users/jeroenooms/gists", add_headers("User-Agent" = "OpenCPU"));
  stop_for_status(out);
  response <- fromJSON(rawToChar(out$content));
  unlist(lapply(response, function(x) {x$id}));                  
}
