httpget_package_file <- function(pkgpath, requri){
  #For file executions, we should load the package the file is in.
  if(req$method() == "POST"){
    reqpackage <- basename(pkgpath);
    reqlib <- dirname(pkgpath);
    
    #try to load package from reqlib, but otherwise other paths are OK
    inlib(reqlib,{
      library(reqpackage, character.only=TRUE);
      httpget_file(file.path(pkgpath, paste(requri, collapse="/")));       
    });
  } else {
    httpget_file(file.path(pkgpath, paste(requri, collapse="/"))); 
  }
}
