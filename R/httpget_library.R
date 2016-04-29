httpget_library <- function(lib.loc, requri){
  #check if API has been enabled
  check.enabled("api.library");  

  #set cache value
  res$setcache("lib");    
  
  #extract the package name
  pkgname <- utils::head(requri, 1);
  if(!length(pkgname)){
    res$checkmethod();
    res$sendlist(list.files(lib.loc))
    #HTML:
    #indexdata <- installed.packages(lib.loc=lib.loc)[, c("Package", "Version", "Built")]
    #send_index(indexdata)
  }

  #find the package is the specified library.
  pkgpath <- find.package(pkgname, lib.loc=lib.loc)
  httpget_package(pkgpath, utils::tail(requri, -1));
}
