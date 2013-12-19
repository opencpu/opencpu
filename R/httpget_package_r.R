httpget_package_r <- function(pkgpath, requri){
  
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
      res$sendlist(ls(paste("package", reqpackage, sep=":")));
    }
    
    #Get object. Throws error if object does not exist.
    myobject <- get(reqobject, paste("package", reqpackage, sep=":"), inherits=FALSE);
    
    #only GET/POST allowed
    res$checkmethod(c("GET", "POST"));    
    
    #return object
    switch(req$method(),
      "GET" = httpget_object(myobject, reqformat, reqobject),
      "POST" = execute_function(myobject, tail(requri, -1), reqobject),
      stop("invalid method")
    );
  });
}
