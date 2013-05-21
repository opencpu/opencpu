httpget_pages <- function(){
  #only GET
  res$checkmethod();
  
  #windows doesn't like trailing slash
  filepath <- sub("/$", "", req$path_info());  
  
  #send it
  res$sendfile(system.file(filepath, package=packagename));    
}