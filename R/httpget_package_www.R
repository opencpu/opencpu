httpget_package_www <- function(pkgpath, requri){
  res$sendfile(file.path(pkgpath, "www", paste(requri, collapse="/")));  
}
