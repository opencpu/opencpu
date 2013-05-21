httpget_package_demo <- function(pkgpath, requri){
  res$sendfile(file.path(pkgpath, "demo", paste(requri, collapse="/")));
}
