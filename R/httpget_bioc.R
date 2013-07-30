httpget_bioc <- function(uri){
  #check if API has been enabled
  check.enabled("api.bioc");  

  #Load BiocInstaller
  biocpath <- bioc_load("BiocInstaller");
  
  #set cache value
  res$setcache("bioc");    
  
  #GET /ocpu/bioc/mypackage
  biocpkg <- uri[1];
  if(is.na(biocpkg)){
    res$checkmethod();    
    pkglist <- available.packages(contrib.url(BiocInstaller::biocinstallRepos("http://bioconductor.org")));
    res$sendlist(row.names(pkglist));
  }
  
  #init the gist
  pkgpath <- bioc_load(biocpkg);
  
  #remaining of the api
  reqtail <- tail(uri, -1)  
  
  #serve basic files
  httpget_package(pkgpath, reqtail);
}
