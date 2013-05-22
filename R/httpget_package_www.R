httpget_package_www <- function(pkgpath, requri){
  httpget_file(file.path(pkgpath, "www", paste(requri, collapse="/")));  
}
