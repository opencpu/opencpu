httpget_bioc <- function(uri){

  #Load bioconductor
  biocpath <- bioc_load("BiocInstaller");
  library("BiocInstaller", lib.loc=dirname(biocpath));
  
  #set cache value
  res$setcache("bioc");    
  
  #GET /ocpu/bioc/mypackage
  biocpkg <- uri[1];
  if(is.na(biocpkg)){
    res$checkmethod();    
    pkglist <- available.packages(contrib.url(biocinstallRepos("http://bioconductor.org")));
    res$sendlist(row.names(pkglist));
  }
  
  #init the gist
  pkgpath <- bioc_load(biocpkg);
  
  #remaining of the api
  reqtail <- tail(uri, -1)  
  
  #serve basic files
  httpget_package(pkgpath, reqtail);
}
