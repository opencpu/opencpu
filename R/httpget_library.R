httpget_library <- function(lib.loc, requri){
  #check if API has been enabled
  check.enabled("api.library");

  #set cache value
  res$setcache("lib");

  #extract the package name
  pkgname <- utils::head(requri, 1);
  if(!length(pkgname)){
    res$checkmethod()
    packages <- if(is.null(lib.loc)) {
      c(loadedNamespaces(), list.files(.libPaths()))
    } else {
      list.files(lib.loc)
    }
    res$sendlist(unique(packages))
  }

  #shorthand for pkg::object notation
  if(grepl("::", pkgname, fixed = TRUE)){
    parts <- strsplit(pkgname, "::", fixed = TRUE)[[1]]
    pkgname <- parts[1]
    requri <- c(parts[1], "R", parts[2], utils::tail(requri, -1))
  }

  #find the package is the specified library.
  pkgpath <- find.package(pkgname, lib.loc=lib.loc)
  httpget_package(pkgpath, utils::tail(requri, -1));
}
