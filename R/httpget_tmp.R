httpget_tmp <- function(requri){
  #check if API has been enabled
  check.enabled("api.tmp");
  prefix <- "x0";

  #reqhead is pub subapi
  reqhead <- utils::head(requri, 1);
  reqtail <- utils::tail(requri, -1);

  if(!length(reqhead)){
    res$checkmethod();
    res$checktrail();
    allfiles <- list.files(ocpu_store(), pattern=paste("^", prefix, sep=""));
    res$sendlist(allfiles);
  }

  sessionpath <- file.path(ocpu_store(), reqhead);

  #set cache value
  res$setcache("tmp");

  #retrieve tmp session
  httpget_session(sessionpath, reqtail);
}
