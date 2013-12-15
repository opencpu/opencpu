httpget_package_data <- function(pkgpath, requri){
  
  #load package
  reqpackage <- basename(pkgpath);
  reqlib <- dirname(pkgpath);
  
  #Package has to be loaded from reqlib, but dependencies might be loaded from global libs.
  inlib(reqlib,{
    loadPackageFrom(reqpackage, reqlib);
    
    #reqhead is function/object name
    reqobject <- head(requri, 1);
    reqformat <- requri[2];    
    
    if(!length(reqobject)){
      res$checkmethod();
      res$sendlist(data(package=reqpackage)$results[,"Item"]);
    }
    
    #Get object. Throws error if object does not exist.
    myenv <- new.env(parent=emptyenv());
    withCallingHandlers({
      data(list=reqobject, package=reqpackage, envir=myenv)
    }, warning = function(e) {stop(e$message, call.= FALSE)});
    myobject <- get(reqobject, myenv, inherits=FALSE);
    
    #return object
    switch(req$method(),
      "GET" = httpget_object(myobject, reqformat, reqobject),
      stop("invalid method")
    );
  });
}
