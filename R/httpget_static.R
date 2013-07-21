httpget_static <- function(){
  #only GET
  res$checkmethod();
  
  #windows doesn't like trailing slash
  filepath <- sub("/$", "", req$path_info());  
  
  #set cache value
  res$setcache("static");   
  
  #send it
  res$sendfile(system.file(filepath, package=packagename));    
}