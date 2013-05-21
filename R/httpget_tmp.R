httpget_tmp <- function(requri){

  #reqhead is pub subapi
  reqhead <- head(requri, 1);
  reqtail <- tail(requri, -1);
  
  if(!length(reqhead)){
    res$checkmethod();
    res$checktrail();
    allfiles <- list.files(gettmpdir(), pattern="^ocpu_session_0x[0-9a-f]+$");
    allfiles <- sub("^ocpu_session_", "", allfiles);
    res$sendlist(allfiles);
  }
  
  sessionpath <- file.path(gettmpdir(), paste("ocpu_session_", reqhead, sep="")); 
  httpget_session(sessionpath, reqtail);
}
