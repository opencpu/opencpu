bitbucket_list <- function(username){
  myurl <- paste("https://bitbucket.org/api/2.0/repositories", username, sep="/");
  mysecret <- gitsecret();
  if(length(mysecret) && length(mysecret$bitbucket_username) && nchar(mysecret$bitbucket_password)){
    username = mysecret$bitbucket_username
    password = mysecret$bitbucket_password
  }

  if(grepl("darwin", R.Version()$platform)){
    out <- eval_psock(httr::GET(myurl, httr::config(httr::autheticate(username, password, "basic"), httr::add_headers("User-Agent" = "OpenCPU")), list(myurl=myurl)));
  } else {
    out <- GET(myurl, add_headers("User-Agent" = "OpenCPU"), config=httr::authenticate(username, password, "basic"));
  }

  stop_for_status(out)
  response <- fromJSON(rawToChar(out$content));


  res$setcache("gitapi");

  #repo names
  return(response$values$name);
}
