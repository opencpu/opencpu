github_list <- function(username){
  myurl <- paste("https://api.github.com/users", username, "repos?per_page=100", sep="/");
  mysecret <- gitsecret();
  if(length(mysecret) && length(mysecret$client_secret) && nchar(mysecret$client_secret)){
    myurl <- paste(myurl, "&client_id=", mysecret$client_id, "&client_secret=", mysecret$client_secret, sep="");
  }
  
  #temporary fix for Mavericks CF
  if(grepl("darwin", R.Version()$platform)){
    out <-  eval_psock(httr::GET(myurl, httr::add_headers("User-Agent" = "OpenCPU")), list(myurl=myurl));
  } else {
    out <- httr::GET(myurl, httr::add_headers("User-Agent" = "OpenCPU"));
  }
  
  httr::stop_for_status(out)
  response <- fromJSON(rawToChar(out$content));
  
  #proxy limit headers
  if(length(out$headers[["X-RateLimit-Limit"]])){
    res$setheader("X-RateLimit-Limit", out$headers[["X-RateLimit-Limit"]])
  }
  if(length(out$headers[["X-RateLimit-Limit"]])){
    res$setheader("X-RateLimit-Remaining", out$headers[["X-RateLimit-Remaining"]])
  }    
  
  #cache the response
  res$setcache("gitapi"); 
  
  #repo names
  return(response$name);                  
}
