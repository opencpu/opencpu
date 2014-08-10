httpget_tmp <- function(requri){
  #check if API has been enabled
  check.enabled("api.tmp");    
  
  tmpsessiondir <- file.path(gettmpdir(), "tmp_library");
  prefix <- "x0";

  #reqhead is pub subapi
  reqhead <- head(requri, 1);
  reqtail <- tail(requri, -1);
  
  if(!length(reqhead)){
    res$checkmethod();
    res$checktrail();
    allfiles <- list.files(tmpsessiondir, pattern=paste("^", prefix, sep=""));
    res$sendlist(allfiles);
  }
  
  sessionpath <- file.path(tmpsessiondir, reqhead); 
  
  #set cache value
  res$setcache("tmp");    
  
  #retrieve tmp session
  httpget_session(sessionpath, reqtail);
}
