httpget_library <- function(lib.loc, requri){
  #extract the package name
  pkgname <- head(requri, 1);
  if(!length(pkgname)){
    res$checkmethod();
    res$sendlist(unique(row.names(installed.packages(lib.loc=lib.loc))));
  }
  
  #find the package is the specified library.
  pkgpath <- find.package(pkgname, lib.loc=lib.loc)
  httpget_package(pkgpath, tail(requri, -1));
}