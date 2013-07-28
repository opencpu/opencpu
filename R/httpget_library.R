httpget_library <- function(lib.loc, requri){
  #check if API has been enabled
  check.enabled("api.library");  
  
  #extract the package name
  pkgname <- head(requri, 1);
  if(!length(pkgname)){
    res$checkmethod();
    res$sendlist(unique(row.names(installed.packages(lib.loc=lib.loc))));
  }
  
  #set cache value
  res$setcache("lib");    
  
  #find the package is the specified library.
  pkgpath <- find.package(pkgname, lib.loc=lib.loc)
  httpget_package(pkgpath, tail(requri, -1));
}
