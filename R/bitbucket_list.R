bitbucket_list <- function(username){
  myurl <- paste("https://bitbucket.org/api/2.0/repositories", username, sep="/");
  #mysecret <- gitsecret();
  #if(length(mysecret) && length(mysecret$bitbucket_client_secret) && nchar(mysecret
  if(grepl("darwin", R.Version()$platform)){
    out <- eval_psock(httr::GET(myurl, httr::add_headers("User-Agent" = "OpenCPU")), list(myurl=myurl));
  } else {
    out <- GET(myurl, add_headers("User-Agent" = "OpenCPU"));
  }

  stop_for_status(out)
  response <- fromJSON(rawToChar(out$content));


  res$setcache("gitapi");

  #repo names
  return(response$values$name);
}
