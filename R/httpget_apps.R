httpget_apps <- function(lib.loc, requri){
  #check if API has been enabled
  check.enabled("api.apps");
  
  #list apps
  appname <- requri[1];
  if(is.na(appname)){
    res$checkmethod();
    allapps <- list.files(lib.loc);
    pkgnames <- unlist(lapply(strsplit(allapps, "_"), '[[', 1));
    res$sendlist(c(allapps, pkgnames));
  }
  
  #change .libPaths to ONLY contain app library
  fullpath <- file.path(lib.loc, appname); 
  if(!file.exists(fullpath)){
    newappname <- utils::tail(list.files(lib.loc, pattern=paste("^", appname, "_", sep="")),1);
    if(!length(newappname)) {
      stop("App not found: ", appname);
    }
    appname <- newappname;
    fullpath <- file.path(lib.loc, appname);
  }
  setLibPaths(fullpath);  
  
  #continue as regular library
  pkgname <- strsplit(appname, "_")[[1]][1];
  pkgpath <- find.package(pkgname)
  httpget_package(pkgpath, utils::tail(requri, -1));
}
