httpget_package_doc <- function(pkgpath, requri){
  res$sendfile(file.path(pkgpath, "doc", paste(requri, collapse="/")));
}
