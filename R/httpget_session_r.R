httpget_session_r <- function(filepath, requri){
  
  #reqhead is function/object name
  reqobject <- head(requri, 1);
  reqformat <- requri[2];   
  
  #try to use old libraries
  libfile <- file.path(filepath, ".Rlibs");
  if(file.exists(libfile)){
    customlib <- readRDS(libfile);
  } else {
    customlib <- NULL;
  }   
  
  #reload packages
  inlib(customlib, {
    infofile <- file.path(filepath, ".RInfo");
    if(file.exists(infofile)){
      loadsessioninfo(infofile);
    }   
  });
  
  #load session
  sessionenv <- new.env();
  sessionfile <- file.path(filepath, ".RData")
  if(file.exists(sessionfile)){
    load(sessionfile, envir=sessionenv);
  }  
  
  #list session objects
  if(!length(reqobject)){
    res$checkmethod();
    dirlist <- ls(sessionenv, all.names=TRUE);
    if(identical(dirlist, ".val")){
      res$redirect(paste(req$uri(), "/.val", sep=""));
    }
    res$sendlist(ls(sessionenv, all.names=TRUE));
  } 
  
  #load object
  myobject <- get(reqobject, envir=sessionenv, inherits=FALSE);
  
  #return object
  switch(req$method(),
     "GET" = httpget_object(myobject, reqformat, reqobject),
     "POST" = execute_function(myobject, tail(requri, -1), reqobject),
     stop("invalid method")
  );  
}
