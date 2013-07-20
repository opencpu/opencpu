httpget_tmp <- function(requri){
  
  tmpsessiondir <- file.path(gettmpdir(), "ocpu_temp");
  prefix <- "ocpu_tmp_";

  #reqhead is pub subapi
  reqhead <- head(requri, 1);
  reqtail <- tail(requri, -1);
  
  if(!length(reqhead)){
    res$checkmethod();
    res$checktrail();
    allfiles <- list.files(tmpsessiondir, pattern=paste("^", prefix, sep=""));
    allfiles <- sub(paste("^", prefix, sep=""), "", allfiles);
    res$sendlist(allfiles);
  }
  
  sessionpath <- file.path(tmpsessiondir, paste(prefix, reqhead, sep="")); 
  
  #set cache value
  res$setcache("tmp");    
  
  #retrieve tmp session
  httpget_session(sessionpath, reqtail);
}
