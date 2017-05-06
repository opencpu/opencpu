httpget_package <- function(pkgpath, requri){

  #double check
  stopifnot(file.exists(pkgpath))

  #reqhead is package api
  reqhead <- utils::head(requri, 1);
  reqtail <- utils::tail(requri, -1);

  #list contents
  if(!length(reqhead)){
    res$checktrail();
    reqpackage <- basename(pkgpath);
    reqlib <- dirname(pkgpath);
    wwwdir <- file.path(reqlib, reqpackage, "www")
    if(file.exists(wwwdir)){
      res$redirectpath("/www/")
    } else {
      res$redirectpath("/info")
    }
  }

  switch(reqhead,
    "R" = httpget_package_r(pkgpath, reqtail),
    "data" = httpget_package_data(pkgpath, reqtail),
    "html" = httpget_package_html(pkgpath, reqtail),
    "man" = httpget_package_man(pkgpath, reqtail),
    "info" = httpget_package_info(pkgpath),
    httpget_package_file(pkgpath, requri)
  );
}
