httpget_session_r <- function(filepath, requri){
  
  #reqhead is function/object name
  reqobject <- head(requri, 1);
  reqformat <- requri[2];   
  
  #load session
  sessionenv <- new.env();
  sessionfile <- file.path(filepath, ".RData")
  if(file.exists(sessionfile)){
    load(sessionfile, envir=sessionenv);
  }  
  
  #list session objects
  if(!length(reqobject)){
    res$checkmethod();
    res$sendlist(ls(sessionenv));
  } 
  
  #load object
  myobject <- get(reqobject, envir=sessionenv)
    
  #return object
  httpget_object(myobject, reqformat, reqobject);
}