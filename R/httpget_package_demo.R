httpget_package_demo <- function(pkgpath, requri){
  httpget_file(file.path(pkgpath, "demo", paste(requri, collapse="/")));
}
