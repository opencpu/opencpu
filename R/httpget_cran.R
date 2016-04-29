httpget_cran <- function(uri){
  #check if API has been enabled
  check.enabled("api.cran");  

  #set cache value (both for list and package)
  res$setcache("cran");  
  
  #GET /ocpu/cran/mypackage
  cranpkg <- uri[1];
  if(is.na(cranpkg)){
    res$checkmethod();    
    pkglist <- utils::available.packages();
    res$sendlist(row.names(pkglist));
  }
  
  #init the gist
  pkgpath <- cran_load(cranpkg);
  
  #remaining of the api
  reqtail <- utils::tail(uri, -1)  
  
  #serve basic files
  httpget_package(pkgpath, reqtail);
}
