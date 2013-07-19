httpget_cran <- function(uri){

  #GET /ocpu/cran/mypackage
  cranpkg <- uri[1];
  if(is.na(cranpkg)){
    res$checkmethod();    
    pkglist <- available.packages();
    res$sendlist(row.names(pkglist));
  }
  
  #init the gist
  pkgpath <- cran_load(cranpkg);
  
  #remaining of the api
  reqtail <- tail(uri, -1)  
  
  #set cache value
  res$setcache("cran");  
  
  #serve basic files
  httpget_package(pkgpath, reqtail);
}
