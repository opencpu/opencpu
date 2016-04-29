httpget_bioc <- function(uri){
  #check if API has been enabled
  check.enabled("api.bioc");  
  
  #the bioconductor library
  biocpath <- file.path(gettmpdir(), "bioc_library");
  
  inlib(biocpath, {
    #Load BiocInstaller
    bioc_load("BiocInstaller", biocpath);
    
    #set cache value
    res$setcache("bioc");    
    
    #GET /ocpu/bioc/mypackage
    biocpkg <- uri[1];
    if(is.na(biocpkg)){
      res$checkmethod();    
      pkglist <- utils::available.packages(utils::contrib.url(getExportedValue("BiocInstaller", "biocinstallRepos")("http://bioconductor.org")));
      res$sendlist(row.names(pkglist));
    }
    
    #load the actual package path
    pkgpath <- bioc_load(biocpkg, biocpath);
  });    
    
  #remaining of the api
  reqtail <- utils::tail(uri, -1)  
  
  #serve basic files
  httpget_package(pkgpath, reqtail);
}
