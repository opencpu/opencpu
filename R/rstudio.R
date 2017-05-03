rstudioproxy <- function(url){
  match <- regexpr("/p/[0-9]{2,5}/ocpu[$/].*", url)
  if(match < 0){
    return(url)
  }

  matchpath <- regmatches(url, match)
  prefix <- regmatches(matchpath, regexpr("/p/[0-9]{3,5}/", matchpath))
  realpath <- sub(prefix, "/", matchpath)
  port <- substring(prefix, 4, nchar(prefix) -1)
  host <- regmatches(url, regexpr("^https?://[^/:]+", url))
  paste0(host, ":", port, realpath)
}

get_localhost <- function(port){
  referer <- Sys.getenv("RSTUDIO_HTTP_REFERER", NA)
  if(is.na(referer))
    return(paste0("http://localhost:", port))
  paste0(referer, "p/", port)
}
