httpget_bioc <- function(uri){
  #Load bioconductor
  biocpath <- bioc_load("BiocInstaller");
  library("BiocInstaller", lib.loc=dirname(biocpath));
  
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
  
  #set cache value
  res$setcache("bioc");  
  
  #serve basic files
  httpget_package(pkgpath, reqtail);
}
