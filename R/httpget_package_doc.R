httpget_package_doc <- function(pkgpath, requri){
  httpget_file(file.path(pkgpath, "doc", paste(requri, collapse="/")));
}
