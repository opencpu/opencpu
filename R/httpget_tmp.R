httpget_tmp <- function(requri){
  
  prefix <- config("session.prefix");

  #reqhead is pub subapi
  reqhead <- head(requri, 1);
  reqtail <- tail(requri, -1);
  
  if(!length(reqhead)){
    res$checkmethod();
    res$checktrail();
    allfiles <- list.files(gettmpdir(), pattern=paste("^", prefix, sep=""));
    allfiles <- sub(paste("^", prefix, sep=""), "", allfiles);
    res$sendlist(allfiles);
  }
  
  sessionpath <- file.path(gettmpdir(), paste(prefix, reqhead, sep="")); 
  httpget_session(sessionpath, reqtail);
}
