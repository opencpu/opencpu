httpget_package_data <- function(pkgpath, requri){
  
  #load package
  reqpackage <- basename(pkgpath);
  reqlib <- dirname(pkgpath);
  
  #Package has to be loaded from reqlib, but dependencies might be loaded from global libs.
  inlib(reqlib,{
    loadPackageFrom(reqpackage, reqlib);
    
    #reqhead is function/object name
    reqobject <- utils::head(requri, 1);
    reqformat <- requri[2];    
    
    if(!length(reqobject)){
      res$checkmethod();
      res$sendlist(utils::data(package=reqpackage)$results[,"Item"]);
    }
    
    #if lazy load is enabled, then use it
    #we check the data promise to make sure it's really a dataset (and not a regular object)
    ns <- as.environment(paste0("package:", reqpackage));    
    if(islazydata(reqobject, ns)){
      myobject <- get(reqobject, ns, inherits=FALSE);
    } else {
      myenv <- new.env(parent=emptyenv());  
      withCallingHandlers({
        #Get object using data(). Throws error if object does not exist.        
        utils::data(list=reqobject, package=reqpackage, envir=myenv)
      }, warning = function(e) {stop(e$message, call.= FALSE)});
      myobject <- get(reqobject, myenv, inherits=FALSE);
    }
    
    #check method
    res$checkmethod("GET")
    
    #return object
    httpget_object(myobject, reqformat, reqobject);  
  });
}
