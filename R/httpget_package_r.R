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
      ns <- paste("package", reqpackage, sep=":")
      res$sendlist(ls(ns))
      #HTML:
      #indexdata <- data.frame(name = ls(ns), stringsAsFactors=FALSE)
      #indexdata$size <- unname(vapply(indexdata$name, function(x){object.size(get(x, ns))}, numeric(1)))
      #send_index(indexdata)
    }
    
    #Get object. Try package namespace first (won't work for lazy data)
    ns <- asNamespace(reqpackage)
    myobject <- if(exists(reqobject, ns, inherits = FALSE)){
      get(reqobject, envir = ns, inherits = FALSE)
    } else {
      #Fall back on exported env
      get(reqobject, paste("package", reqpackage, sep=":"), inherits = FALSE)
    }
    
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
