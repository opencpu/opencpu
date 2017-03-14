#note: this function imitates the basic R help server, for backward compatibility.
#The /man api is more advanced.
httpget_package_html <- function(pkgpath, requri){
  
  #extract names
  reqpackage <- basename(pkgpath);
  reqlib <- dirname(pkgpath);  
  helpfile <- requri[1];
  
  #show a list of objects
  if(is.na(helpfile)){
    res$checktrail();
    res$sendfile(file.path(pkgpath, "html", "00Index.html"));
  }

  if(strsplit(helpfile, ".", fixed=TRUE)[[1]][2] != "html"){
    res$notfound();
  };
  
  reqobject <- strsplit(helpfile, ".", fixed=TRUE)[[1]][1];
  
  #get the help file
  getrd <- environment(httpget_package_man)$getrd;
  rdfile <- getrd(topic=reqobject, package=reqpackage, lib.loc=reqlib);

  #send html file
  mylinks <- tools::findHTMLlinks(pkgpath, lib.loc=reqlib);
  mytmp <- tempfile(fileext=".html");
  tools::Rd2HTML(rdfile, out=mytmp, package=reqpackage, Links=mylinks, stylesheet="R.css");
  res$sendfile(mytmp); 
}
