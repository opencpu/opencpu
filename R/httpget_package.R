httpget_package <- function(pkgpath, requri){
  
  #double check
  stopifnot(file.exists(pkgpath))
  
  #reqhead is package api
  reqhead <- head(requri, 1);
  reqtail <- tail(requri, -1);  
    
  #list contents
  if(!length(reqhead)){
    res$checktrail();
    reqpackage <- basename(pkgpath);
    reqlib <- dirname(pkgpath);
    pkghelp <- eval(call("help", package=reqpackage, lib.loc=reqlib, help_type="text"))
    res$sendtext(format(pkghelp));
  }
  
  switch(reqhead,
    "R" = httpget_package_r(pkgpath, reqtail),
    "dpu" = httpget_package_dpu(pkgpath, reqtail),
    "html" = httpget_package_html(pkgpath, reqtail),
    "man" = httpget_package_man(pkgpath, reqtail),
    httpget_file(file.path(pkgpath, paste(requri, collapse="/")))     
    
    #"doc" = httpget_package_doc(pkgpath, reqtail),
    #"demo" = httpget_package_demo(pkgpath, reqtail),
    #"www" = httpget_package_www(pkgpath, reqtail),
    #"DESCRIPTION" = res$sendfile(file.path(pkgpath, "DESCRIPTION")),
    #"NEWS" = res$sendfile(file.path(pkgpath, "NEWS")),
    #stop("invalid package api:",reqhead)
  );
}